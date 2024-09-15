#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <erl_nif.h>
#include <algorithm>
#include <iostream>
#include <optional>
#include <string>
#include <vector>
#include <dlfcn.h>
#include "nif_utils.hpp"
#include "pythonx_consts.hpp"
#include "pyobject_nif_res.hpp"
#include "pythonx_pyerr.hpp"
#include "pythonx_pydict.hpp"
#include "pythonx_pylist.hpp"
#include "pythonx_pylong.hpp"
#include "pythonx_pyobject.hpp"
#include "pythonx_pytuple.hpp"
#include "pythonx_pyunicode.hpp"

char pythonx_mutex_name[] = {"python_mutex"};
static ErlNifMutex * python_mutex = nullptr;
static bool python_initialized = false;
static PyObject * local_dict;
static PyObject * global_dict;
static PyConfig config;

ErlNifResourceType * PyObjectNifRes::type = nullptr;

// ------- Helper functions for NIF -------
// Convert Python objects to Erlang terms
static std::optional<ERL_NIF_TERM> python_to(ErlNifEnv *env, PyObject * dict);
static std::optional<ERL_NIF_TERM> python_dict_to(ErlNifEnv *env, PyObject * dict);
static std::optional<ERL_NIF_TERM> python_tuple_to(ErlNifEnv *env, PyObject * dict);
static std::optional<ERL_NIF_TERM> python_list_to(ErlNifEnv *env, PyObject * list);

static std::optional<ERL_NIF_TERM> python_to(ErlNifEnv *env, PyObject * val) {
    auto ret = std::nullopt;
    if (val == nullptr) {
        return ret;
    }
    if (PyLong_Check(val)) {
        return enif_make_int64(env, PyLong_AsLong(val));
    }
    if (PyFloat_Check(val)) {
        return enif_make_double(env, PyFloat_AsDouble(val));
    }
    if (PyUnicode_Check(val)) {
        Py_ssize_t size;
        const char * data = PyUnicode_AsUTF8AndSize(val, &size);
        if (data == nullptr) {
            return ret;
        }
        ERL_NIF_TERM string_val;
        unsigned char * ptr;
        if ((ptr = enif_make_new_binary(env, size, &string_val)) != nullptr) {
            strncpy((char *)ptr, data, size);
            return string_val;
        }
        return ret;
    }
    if (PyDict_Check(val)) {
        return python_dict_to(env, val);
    }
    if (PyTuple_Check(val)) {
        return python_tuple_to(env, val);
    }
    if (val == Py_None) {
        return kAtomNil;
    }
    if (val == Py_False) {
        return kAtomFalse;
    }
    if (val == Py_True) {
        return kAtomTrue;
    }
    if (PyList_Check(val)) {
        return python_list_to(env, val);
    }

    PyObject* type_obj = PyObject_Type(val);
    PyObject* type_name_obj = PyObject_GetAttrString(type_obj, "__name__");
    const char* type_name = PyUnicode_AsUTF8(type_name_obj);
    // printf("[debug] type_name: %s\r\n", type_name);

    // Cleanup type objects
    Py_DECREF(type_obj);
    Py_DECREF(type_name_obj);

    return kAtomNil;
}

static std::optional<ERL_NIF_TERM> python_dict_to(ErlNifEnv *env, PyObject * dict) {
    auto ret = std::nullopt;
    PyObject *keys = PyDict_Keys(dict);
    if (keys == nullptr) {
        return ret;
    }

    Py_ssize_t size = PyList_Size(keys);
    std::vector<ERL_NIF_TERM> erl_keys, erl_values;
    for (Py_ssize_t i = 0; i < size; ++i) {
        PyObject *key = PyList_GetItem(keys, i);
        auto key_term = python_to(env, key);
        if (!key_term) return ret;
        erl_keys.emplace_back(key_term.value());

        auto val = PyDict_GetItem(dict, key);
        auto val_term = python_to(env, val);
        if (!val_term) return ret;
        erl_values.emplace_back(val_term.value());
    }
    Py_DECREF(keys);

    ERL_NIF_TERM erl_dict;
    if (enif_make_map_from_arrays(env, erl_keys.data(), erl_values.data(), erl_keys.size(), &erl_dict)) {
        return erl_dict;
    }
    return ret;
}

static std::optional<ERL_NIF_TERM> python_tuple_to(ErlNifEnv *env, PyObject * tuple) {
    auto ret = std::nullopt;
    Py_ssize_t size = PyTuple_Size(tuple);
    std::vector<ERL_NIF_TERM> erl_values;
    for (Py_ssize_t i = 0; i < size; ++i) {
        PyObject * item = PyTuple_GetItem(tuple, i);
        auto item_term = python_to(env, item);
        if (!item_term) return ret;
        erl_values.emplace_back(item_term.value());
    }
    ERL_NIF_TERM erl_tuple = enif_make_tuple_from_array(env, erl_values.data(), erl_values.size());
    return erl_tuple;
}

static std::optional<ERL_NIF_TERM> python_list_to(ErlNifEnv *env, PyObject * list) {
    auto ret = std::nullopt;
    Py_ssize_t size = PyList_Size(list);
    std::vector<ERL_NIF_TERM> erl_values;
    for (Py_ssize_t i = 0; i < size; ++i) {
        PyObject * item = PyList_GetItem(list, i);
        auto item_term = python_to(env, item);
        if (!item_term) return ret;
        erl_values.emplace_back(item_term.value());
    }
    ERL_NIF_TERM erl_list = enif_make_list_from_array(env, erl_values.data(), erl_values.size());
    return erl_list;
}

static std::optional<ERL_NIF_TERM> python_items_in_dict_to(ErlNifEnv *env, PyObject * dict, std::vector<std::string> &keys) {
    auto ret = std::nullopt;
    Py_ssize_t keys_size = keys.size();
    if (keys_size == 0) {
        return ret;
    }

    PyObject *dict_keys = PyDict_Keys(dict);
    if (dict_keys == nullptr) {
        return ret;
    }

    std::vector<ERL_NIF_TERM> erl_values(keys.size(), kAtomNil);
    Py_ssize_t dict_keys_size = PyList_Size(dict_keys);
    if (dict_keys_size != 0) {
        for (Py_ssize_t i = 0; i < dict_keys_size; ++i) {
            PyObject *dict_key = PyList_GetItem(dict_keys, i);
            if (dict_key != nullptr && PyUnicode_Check(dict_key)) {
                const char* dict_key_str = PyUnicode_AsUTF8(dict_key);
                auto it = std::find(keys.begin(), keys.end(), dict_key_str);
                if (it != keys.end()) {
                    size_t index = it - keys.begin();
                    auto val = PyDict_GetItem(dict, dict_key);
                    auto val_term = python_to(env, val);
                    if (!val_term) return ret;
                    erl_values[index] = val_term.value();
                }
            }
        }
    }
    Py_DECREF(dict_keys);

    ERL_NIF_TERM erl_dict = enif_make_list_from_array(env, erl_values.data(), erl_values.size());
    return erl_dict;
}

// Convert Erlang NIF terms to Python objects
static std::optional<PyObject *> erl_to_python(ErlNifEnv *env, ERL_NIF_TERM term) {
    if (enif_is_atom(env, term)) {
        if (enif_is_identical(term, kAtomNil)) {
            Py_RETURN_NONE;
        }
        if (enif_is_identical(term, kAtomTrue)) {
            Py_RETURN_TRUE;
        }
        if (enif_is_identical(term, kAtomFalse)) {
            Py_RETURN_FALSE;
        }

        std::string atom;
        if (erlang::nif::get_atom(env, term, atom)) {
            return PyUnicode_DecodeUTF8(atom.c_str(), atom.size(), "strict");
        } else {
            // todo: better error handling
            // return None if get_atom fails for now
            Py_RETURN_NONE;
        }
    } else if (enif_is_binary(env, term)) {
        ErlNifBinary binary;
        if (enif_inspect_binary(env, term, &binary)) {
            return PyUnicode_DecodeUTF8((const char *)binary.data, binary.size, "strict");
        } else {
            // todo: return None if enif_inspect_binary fails
            Py_RETURN_NONE;
        }
    } else if (enif_is_list(env, term)) {
        ERL_NIF_TERM head, tail;
        if (enif_get_list_cell(env, term, &head, &tail)) {
            std::vector<PyObject *> list;
            while (enif_get_list_cell(env, term, &head, &tail)) {
                auto item = erl_to_python(env, head);
                if (item) {
                    list.emplace_back(item.value());
                } else {
                    // todo: return None for unsupported types for now
                    Py_RETURN_NONE;
                }
                term = tail;
            }
            PyObject *py_list = PyList_New(list.size());
            for (size_t i = 0; i < list.size(); ++i) {
                PyList_SetItem(py_list, i, list[i]);
            }
            return py_list;
        }
    } else if (enif_is_tuple(env, term)) {
        int arity;
        const ERL_NIF_TERM *arr;
        if (enif_get_tuple(env, term, &arity, &arr)) {
            // n-tuple maps to n-ary tuple in Python
            PyObject *py_tuple = PyTuple_New(arity);
            for (int i = 0; i < arity; ++i) {
                auto item = erl_to_python(env, arr[i]);
                if (item) {
                    PyTuple_SetItem(py_tuple, i, item.value());
                } else {
                    // todo: set None for unsupported types for now
                    PyTuple_SetItem(py_tuple, i, Py_None);
                }
            }
        } else {
            // todo: this should not happen
            // but if it does, return None for now
            Py_RETURN_NONE;
        }
    } else if (enif_is_number(env, term)) {
        ErlNifUInt64 u64;
        if (enif_get_uint64(env, term, &u64)) {
            return PyLong_FromUnsignedLongLong(u64);
        }
        ErlNifSInt64 i64;
        if (enif_get_int64(env, term, &i64)) {
            return PyLong_FromLongLong(i64);
        }
        double num;
        if (enif_get_double(env, term, &num)) {
            return PyFloat_FromDouble(num);
        }

        // todo: return None for unsupported types for now
        Py_RETURN_NONE;
    }

    // todo: return None for unsupported types for now
    Py_RETURN_NONE;
}

// ------- Python C API functions -------

static void init_locals_and_globals() {
    if (!python_initialized) {
        PyStatus status = Py_InitializeFromConfig(&config);
        if (PyStatus_Exception(status)) {
            Py_ExitStatusException(status);
        }

        local_dict = PyDict_New();
        global_dict = PyDict_New();

        // Initialize globals with the __builtins__ module to enable built-in functions
        PyDict_SetItemString(global_dict, "__builtins__", PyEval_GetBuiltins());

        python_initialized = true;
    }
}

static int pythonx_c_api_initialize(std::optional<std::string> user_python_home) {
    python_mutex = enif_mutex_create(pythonx_mutex_name);
    if (python_mutex == nullptr) {
        return -1;
    }

    PyConfig_InitPythonConfig(&config);
    config.isolated = 1;

    std::string python_home;
    if (!user_python_home) {
        Dl_info info{};
        if (dladdr((const void *)&pythonx_c_api_initialize, &info)) {
            std::string path = info.dli_fname;
            std::string dir = path.substr(0, path.find_last_of("/"));
            python_home = dir + "/python3";
        } else {
            fprintf(stderr, "Cannot find any libpython in pythonx\r\n");
            return -1;
        }
    } else {
        python_home = user_python_home.value();
    }

    PyConfig_SetBytesString(&config, &config.home, python_home.c_str());
    PyConfig_SetBytesString(&config, &config.base_prefix, python_home.c_str());
    PyConfig_SetBytesString(&config, &config.base_exec_prefix, python_home.c_str());
    PyConfig_SetBytesString(&config, &config.prefix, python_home.c_str());
    PyConfig_SetBytesString(&config, &config.exec_prefix, python_home.c_str());

#ifndef __APPLE__
    std::string so_file = python_home + "/lib/libpython3.so";
    void *handle = dlopen(so_file.c_str(), RTLD_LAZY | RTLD_GLOBAL);
    if (!handle) {
        fprintf(stderr, "Error loading libpython: %s\r\n", dlerror());
        return -1;
    }
#endif

    enif_mutex_lock(python_mutex);
    init_locals_and_globals();
    enif_mutex_unlock(python_mutex);

    return 0;
}

// ------- NIF functions -------

static ERL_NIF_TERM pythonx_initialize(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    std::string python_home;
    if (!erlang::nif::get(env, argv[0], python_home)) {
        return enif_make_badarg(env);
    }

    if (!pythonx_c_api_initialize(python_home)) {
        return kAtomOk;
    } else {
        return erlang::nif::error(env, "Cannot initialize Python");
    }
}

static ERL_NIF_TERM pythonx_inline(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    if (python_mutex == nullptr) pythonx_c_api_initialize(std::nullopt);

    std::string python_code;
    if (!erlang::nif::get(env, argv[0], python_code)) {
        return enif_make_badarg(env);
    }
    std::vector<std::string> var_names;
    if (!erlang::nif::get_list(env, argv[1], var_names)) {
        return enif_make_badarg(env);
    }
    bool get_locals = false;
    if (!erlang::nif::get(env, argv[2], &get_locals)) {
        return enif_make_badarg(env);
    }
    bool get_globals = false;
    if (!erlang::nif::get(env, argv[3], &get_globals)) {
        return enif_make_badarg(env);
    }
    std::map<std::string, ERL_NIF_TERM> elixir_vars;
    if (!erlang::nif::parse_arg(env, 4, argv, elixir_vars)) {
        return enif_make_badarg(env);
    }
    ERL_NIF_TERM ret{};

    enif_mutex_lock(python_mutex);

    init_locals_and_globals();

    for (auto& var : elixir_vars) {
        // send elixir variables to python
        PyDict_SetItemString(local_dict, var.first.c_str(), erl_to_python(env, var.second).value());
    }

    PyObject *result = PyRun_String(python_code.c_str(), Py_file_input, global_dict, local_dict);
    if (result == NULL) {
        // Handle error (print traceback, etc.)
        PyErr_Print();
        ret = erlang::nif::error(env, "python_error");
    } else {
        ERL_NIF_TERM vars_map, result_erl;
        auto return_vars = python_items_in_dict_to(env, local_dict, var_names);
        if (return_vars) {
            result_erl = return_vars.value();
        } else {
            result_erl = enif_make_list(env, 0, NULL);
        }

        if (get_locals || get_globals) {
            std::vector<ERL_NIF_TERM> keys, values;
            if (get_locals) {
                auto local_vars = python_to(env, local_dict);
                if (local_vars) {
                    keys.emplace_back(enif_make_atom(env, "locals"));
                    values.emplace_back(local_vars.value());
                }
            }
            if (get_globals) {
                auto global_vars = python_to(env, global_dict);
                if (global_vars) {
                    keys.emplace_back(enif_make_atom(env, "globals"));
                    values.emplace_back(global_vars.value());
                }
            }
            enif_make_map_from_arrays(env, keys.data(), values.data(), keys.size(), &vars_map);
            ret = erlang::nif::ok(env, enif_make_tuple2(env, result_erl, vars_map));
        } else {
            ret = erlang::nif::ok(env, result_erl);
        }

        Py_DECREF(result);
    }

    enif_mutex_unlock(python_mutex);
    return ret;
}

static ERL_NIF_TERM pythonx_finalize(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    enif_mutex_lock(python_mutex);

    if (python_initialized) {
        Py_DECREF(global_dict);
        Py_DECREF(local_dict);
        Py_DECREF(global_dict);
        Py_DECREF(local_dict);
        Py_Finalize();
        python_initialized = false;
    }

    enif_mutex_unlock(python_mutex);
    return kAtomOk;
}

static ERL_NIF_TERM pythonx_nif_loaded(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    return kAtomOk;
}

static ERL_NIF_TERM pythonx_py_none(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ret{};
    PyObjectNifRes *res = allocate_resource<PyObjectNifRes>();
    if (unlikely(res == nullptr)) return kAtomError;

    Py_INCREF(Py_None);
    res->val = Py_None;
    ret = enif_make_resource(env, res);
    enif_release_resource(res);
    return ret;
}

static ERL_NIF_TERM pythonx_py_true(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ret{};
    PyObjectNifRes *res = allocate_resource<PyObjectNifRes>();
    if (unlikely(res == nullptr)) return kAtomError;

    Py_INCREF(Py_True);
    res->val = Py_True;
    ret = enif_make_resource(env, res);
    enif_release_resource(res);
    return ret;
}

static ERL_NIF_TERM pythonx_py_false(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ret{};
    PyObjectNifRes *res = allocate_resource<PyObjectNifRes>();
    if (unlikely(res == nullptr)) return kAtomError;

    Py_INCREF(Py_False);
    res->val = Py_False;
    ret = enif_make_resource(env, res);
    enif_release_resource(res);
    return ret;
}

static ERL_NIF_TERM pythonx_py_incref(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ref = argv[0];
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, ref);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    Py_XINCREF(res->val);
    return ref;
}

static ERL_NIF_TERM pythonx_py_decref(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ref = argv[0];
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, ref);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    Py_XDECREF(res->val);
    return ref;
}

static int on_load(ErlNifEnv *env, void **_sth1, ERL_NIF_TERM _sth2) {
    init_pythonx_consts(env);

    ErlNifResourceType *rt;
    {
        using res_type = PyObjectNifRes;
        rt = enif_open_resource_type(env, "Elixir.Pythonx.Nif", "Pythonx.PyObject", destruct_py_object, ERL_NIF_RT_CREATE, NULL);
        if (!rt) return -1;
        res_type::type = rt;
    }

    return 0;
}

static int on_reload(ErlNifEnv *_sth0, void **_sth1, ERL_NIF_TERM _sth2) {
    return 0;
}

static int on_upgrade(ErlNifEnv *_sth0, void **_sth1, void **_sth2, ERL_NIF_TERM _sth3) {
    return 0;
}

static ErlNifFunc nif_functions[] = {
    {"initialize", 1, pythonx_initialize, 0},
    {"inline", 5, pythonx_inline, 0},
    {"finalize", 0, pythonx_finalize, 0},
    {"nif_loaded", 0, pythonx_nif_loaded, 0},

    {"py_none", 0, pythonx_py_none, 0},
    {"py_true", 0, pythonx_py_true, 0},
    {"py_false", 0, pythonx_py_false, 0},
    {"py_incref", 1, pythonx_py_incref, 0},
    {"py_decref", 1, pythonx_py_decref, 0},

    {"py_dict_check", 1, pythonx_py_dict_check, 0},
    {"py_dict_check_exact", 1, pythonx_py_dict_check_exact, 0},
    {"py_dict_new", 0, pythonx_py_dict_new, 0},
    {"py_dict_clear", 1, pythonx_py_dict_clear, 0},
    {"py_dict_contains", 2, pythonx_py_dict_contains, 0},
    {"py_dict_copy", 1, pythonx_py_dict_copy, 0},
    {"py_dict_set_item", 3, pythonx_py_dict_set_item, 0},
    {"py_dict_set_item_string", 3, pythonx_py_dict_set_item_string, 0},
    {"py_dict_del_item", 2, pythonx_py_dict_del_item, 0},
    {"py_dict_del_item_string", 2, pythonx_py_dict_del_item_string, 0},
    {"py_dict_get_item", 2, pythonx_py_dict_get_item, 0},
    {"py_dict_get_item_with_error", 2, pythonx_py_dict_get_item_with_error, 0},
    {"py_dict_get_item_string", 2, pythonx_py_dict_get_item_string, 0},
    {"py_dict_set_default", 3, pythonx_py_dict_set_default, 0},
    {"py_dict_items", 1, pythonx_py_dict_items, 0},
    {"py_dict_keys", 1, pythonx_py_dict_keys, 0},
    {"py_dict_values", 1, pythonx_py_dict_values, 0},
    {"py_dict_size", 1, pythonx_py_dict_size, 0},
    {"py_dict_merge", 3, pythonx_py_dict_merge, 0},
    {"py_dict_update", 2, pythonx_py_dict_update, 0},
    {"py_dict_merge_from_seq2", 3, pythonx_py_dict_merge_from_seq2, 0},

    {"py_list_check", 1, pythonx_py_list_check, 0},
    {"py_list_check_exact", 1, pythonx_py_list_check_exact, 0},
    {"py_list_new", 1, pythonx_py_list_new, 0},
    {"py_list_size", 1, pythonx_py_list_size, 0},
    {"py_list_get_item", 2, pythonx_py_list_get_item, 0},
    {"py_list_set_item", 3, pythonx_py_list_set_item, 0},
    {"py_list_insert", 3, pythonx_py_list_insert, 0},
    {"py_list_append", 2, pythonx_py_list_append, 0},
    {"py_list_get_slice", 3, pythonx_py_list_get_slice, 0},
    {"py_list_set_slice", 4, pythonx_py_list_set_slice, 0},
    {"py_list_sort", 1, pythonx_py_list_sort, 0},
    {"py_list_reverse", 1, pythonx_py_list_reverse, 0},
    {"py_list_as_tuple", 1, pythonx_py_list_as_tuple, 0},

    {"py_long_check", 1, pythonx_py_long_check, 0},
    {"py_long_check_exact", 1, pythonx_py_long_check_exact, 0},
    {"py_long_from_long", 1, pythonx_py_long_from_long, 0},
    {"py_long_from_unsigned_long", 1, pythonx_py_long_from_unsigned_long, 0},
    {"py_long_from_ssize_t", 1, pythonx_py_long_from_ssize_t, 0},
    {"py_long_from_size_t", 1, pythonx_py_long_from_size_t, 0},
    {"py_long_from_long_long", 1, pythonx_py_long_from_long_long, 0},
    {"py_long_from_unsigned_long_long", 1, pythonx_py_long_from_unsigned_long_long, 0},
    {"py_long_from_double", 1, pythonx_py_long_from_double, 0},
    {"py_long_from_string", 2, pythonx_py_long_from_string, 0},
    {"py_long_as_long", 1, pythonx_py_long_as_long, 0},
    {"py_long_as_long_and_overflow", 1, pythonx_py_long_as_long_and_overflow, 0},
    {"py_long_as_long_long", 1, pythonx_py_long_as_long_long, 0},
    {"py_long_as_long_long_and_overflow", 1, pythonx_py_long_as_long_long_and_overflow, 0},
    {"py_long_as_ssize_t", 1, pythonx_py_long_as_ssize_t, 0},
    {"py_long_as_unsigned_long", 1, pythonx_py_long_as_unsigned_long, 0},
    {"py_long_as_size_t", 1, pythonx_py_long_as_size_t, 0},
    {"py_long_as_unsigned_long_long", 1, pythonx_py_long_as_unsigned_long_long, 0},
    {"py_long_as_unsigned_long_mask", 1, pythonx_py_long_as_unsigned_long_mask, 0},
    {"py_long_as_unsigned_long_long_mask", 1, pythonx_py_long_as_unsigned_long_long_mask, 0},
    {"py_long_as_double", 1, pythonx_py_long_as_double, 0},
    {"py_long_get_info", 0, pythonx_py_long_get_info, 0},

    {"py_object_has_attr", 2, pythonx_py_object_has_attr, 0},
    {"py_object_has_attr_string", 2, pythonx_py_object_has_attr_string, 0},
    {"py_object_get_attr", 2, pythonx_py_object_get_attr, 0},
    {"py_object_get_attr_string", 2, pythonx_py_object_get_attr_string, 0},
    {"py_object_generic_get_attr", 2, pythonx_py_object_generic_get_attr, 0},
    {"py_object_set_attr", 3, pythonx_py_object_get_attr, 0},
    {"py_object_set_attr_string", 3, pythonx_py_object_get_attr_string, 0},
    {"py_object_generic_set_attr", 3, pythonx_py_object_generic_set_attr, 0},
    {"py_object_del_attr", 2, pythonx_py_object_del_attr, 0},
    {"py_object_del_attr_string", 2, pythonx_py_object_del_attr_string, 0},
    {"py_object_is_true", 1, pythonx_py_object_is_true, 0},
    {"py_object_not", 1, pythonx_py_object_not, 0},
    {"py_object_type", 1, pythonx_py_object_type, 0},
    {"py_object_length", 1, pythonx_py_object_length, 0},
    {"py_object_repr", 1, pythonx_py_object_repr, 0},
    {"py_object_ascii", 1, pythonx_py_object_ascii, 0},
    {"py_object_str", 1, pythonx_py_object_str, 0},
    {"py_object_bytes", 1, pythonx_py_object_bytes, 0},

    {"py_tuple_check", 1, pythonx_py_tuple_check, 0},
    {"py_tuple_check_exact", 1, pythonx_py_tuple_check_exact, 0},
    {"py_tuple_new", 1, pythonx_py_tuple_new, 0},
    {"py_tuple_size", 1, pythonx_py_tuple_size, 0},
    {"py_tuple_get_item", 2, pythonx_py_tuple_get_item, 0},
    {"py_tuple_get_slice", 3, pythonx_py_tuple_get_slice, 0},
    // {"py_tuple_set_item", 3, pythonx_py_tuple_set_item, 0},

    {"py_unicode_from_string", 1, pythonx_py_unicode_from_string, 0},
    {"py_unicode_as_utf8", 1, pythonx_py_unicode_as_utf8, 0}
};

ERL_NIF_INIT(Elixir.Pythonx.Nif, nif_functions, on_load, on_reload, on_upgrade, NULL);
