#ifndef PYTHONX_PYDICT_HPP
#define PYTHONX_PYDICT_HPP
#pragma once

#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <erl_nif.h>
#include "nif_utils.hpp"
#include "pythonx_consts.hpp"
#include "pythonx_utils.hpp"
#include "pythonx_pyerr.hpp"

static ERL_NIF_TERM pythonx_py_dict_check(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PyDict_Check(res->val);
    if (result) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_dict_check_exact(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PyDict_CheckExact(res->val);
    if (result) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_dict_new(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObject *result = PyDict_New();
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_dict_clear(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyDict_Clear(res->val);
    return kAtomOk;
}

static ERL_NIF_TERM pythonx_py_dict_contains(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *key_res = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(key_res == nullptr)) return enif_make_badarg(env);

    int result = PyDict_Contains(res->val, key_res->val);
    if (result == -1) return pythonx_current_pyerr(env);
    if (result) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_dict_copy(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyDict_Copy(res->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_dict_set_item(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *key_res = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(key_res == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *val_res = get_resource<PyObjectNifRes>(env, argv[2]);
    if (unlikely(val_res == nullptr)) return enif_make_badarg(env);

    int result = PyDict_SetItem(res->val, key_res->val, val_res->val);
    if (result == -1) return pythonx_current_pyerr(env);
    return kAtomTrue;
}

static ERL_NIF_TERM pythonx_py_dict_set_item_string(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    std::string key;
    if (!erlang::nif::get(env, argv[1], key)) return enif_make_badarg(env);

    PyObjectNifRes *val_res = get_resource<PyObjectNifRes>(env, argv[2]);
    if (unlikely(val_res == nullptr)) return enif_make_badarg(env);

    int result = PyDict_SetItemString(res->val, key.c_str(), val_res->val);
    if (result == -1) return pythonx_current_pyerr(env);
    return kAtomTrue;
}

static ERL_NIF_TERM pythonx_py_dict_del_item(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *key_res = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(key_res == nullptr)) return enif_make_badarg(env);

    int result = PyDict_DelItem(res->val, key_res->val);
    if (result == -1) return pythonx_current_pyerr(env);
    return kAtomOk;
}

static ERL_NIF_TERM pythonx_py_dict_del_item_string(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    std::string key;
    if (!erlang::nif::get(env, argv[1], key)) return enif_make_badarg(env);

    int result = PyDict_DelItemString(res->val, key.c_str());
    if (result == -1) return pythonx_current_pyerr(env);
    return kAtomOk;
}

static ERL_NIF_TERM pythonx_py_dict_get_item(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *key_res = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(key_res == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyDict_GetItem(res->val, key_res->val);
    return pyobject_to_nifres_or_nil(env, result, true);
}

static ERL_NIF_TERM pythonx_py_dict_get_item_with_error(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *key_res = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(key_res == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyDict_GetItemWithError(res->val, key_res->val);
    return pyobject_to_nifres_or_pyerr(env, result, true);
}

static ERL_NIF_TERM pythonx_py_dict_get_item_string(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    std::string key;
    if (!erlang::nif::get(env, argv[1], key)) return enif_make_badarg(env);

    PyObject *result = PyDict_GetItemString(res->val, key.c_str());
    return pyobject_to_nifres_or_nil(env, result, true);
}

static ERL_NIF_TERM pythonx_py_dict_set_default(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *key_res = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(key_res == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *default_res = get_resource<PyObjectNifRes>(env, argv[2]);
    if (unlikely(default_res == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyDict_SetDefault(res->val, key_res->val, default_res->val);
    return pyobject_to_nifres_or_pyerr(env, result, true);
}

static ERL_NIF_TERM pythonx_py_dict_items(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyDict_Items(res->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_dict_keys(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyDict_Keys(res->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_dict_values(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyDict_Values(res->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_dict_size(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    Py_ssize_t size = PyDict_Size(res->val);
    if (size == -1) return pythonx_current_pyerr(env);
    return enif_make_int64(env, size);
}

static ERL_NIF_TERM pythonx_py_dict_merge(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *res2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(res2 == nullptr)) return enif_make_badarg(env);

    int override = enif_is_identical(argv[2], kAtomTrue) ? 1 : 0;

    int result = PyDict_Merge(res1->val, res2->val, override);
    if (result == -1) return pythonx_current_pyerr(env);
    return kAtomOk;
}

static ERL_NIF_TERM pythonx_py_dict_update(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *res2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(res2 == nullptr)) return enif_make_badarg(env);

    int result = PyDict_Update(res1->val, res2->val);
    if (result == -1) return pythonx_current_pyerr(env);
    return kAtomOk;
}

static ERL_NIF_TERM pythonx_py_dict_merge_from_seq2(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *res2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(res2 == nullptr)) return enif_make_badarg(env);

    int override = enif_is_identical(argv[2], kAtomTrue) ? 1 : 0;

    int result = PyDict_MergeFromSeq2(res1->val, res2->val, override);
    if (result == -1) return pythonx_current_pyerr(env);
    return kAtomOk;
}

#endif  // PYTHONX_PYDICT_HPP
