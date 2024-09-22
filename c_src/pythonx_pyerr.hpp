#ifndef PYTHONX_PY_ERR_HPP
#define PYTHONX_PY_ERR_HPP
#pragma once

#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <erl_nif.h>
#include "nif_utils.hpp"
#include "nif_utils.hpp"
#include "pythonx_utils.hpp"

static ERL_NIF_TERM pythonx_py_err_clear(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyErr_Clear();
    return kAtomOk;
}

static ERL_NIF_TERM pythonx_current_pyerr(ErlNifEnv *env);

static inline ERL_NIF_TERM nonnull_pyobject_to_nifres(ErlNifEnv *env, PyObject *result, bool borrowed = false) {
    PyObjectNifRes *result_res = allocate_resource<PyObjectNifRes>();
    if (unlikely(result_res == nullptr)) {
        Py_DECREF(result);
        return kAtomError;
    }

    result_res->val = result;
    result_res->borrowed = borrowed;
    ERL_NIF_TERM ret = enif_make_resource(env, result_res);
    enif_release_resource(result_res);
    return ret;
}

static inline ERL_NIF_TERM pyobject_to_nifres_or_pyerr(ErlNifEnv *env, PyObject *result, bool borrowed = false) {
    if (unlikely(result == nullptr)) return pythonx_current_pyerr(env);
    return nonnull_pyobject_to_nifres(env, result, borrowed);
}

static inline ERL_NIF_TERM pyobject_to_nifres_or_nil(ErlNifEnv *env, PyObject *result, bool borrowed = false) {
    if (unlikely(result == nullptr)) return kAtomNil;
    return nonnull_pyobject_to_nifres(env, result, borrowed);
}

ERL_NIF_TERM pythonx_current_pyerr(ErlNifEnv *env) {
    ERL_NIF_TERM ret = kAtomError;

    PyObject *type = nullptr, *value = nullptr, *traceback = nullptr;
    PyObjectNifRes *type_res = nullptr, *value_res = nullptr, *traceback_res = nullptr;
    PyErr_Fetch(&type, &value, &traceback);

    const size_t num_items = 4;

    ERL_NIF_TERM keys[num_items] = {
        kAtomStruct,
        kAtomType,
        kAtomValue,
        kAtomTraceback
    };
    ERL_NIF_TERM values[num_items] = {
        kModulePythonxRawPyErr,
        kAtomNil,
        kAtomNil,
        kAtomNil
    };

    if (type) {
        type_res = allocate_resource<PyObjectNifRes>();
        if (unlikely(type_res == nullptr)) goto failed;

        type_res->val = type;
        values[1] = enif_make_resource(env, type_res);
    }

    if (value) {
        value_res = allocate_resource<PyObjectNifRes>();
        if (unlikely(value_res == nullptr)) goto failed;

        value_res->val = value;
        values[2] = enif_make_resource(env, value_res);
    }

    if (traceback) {
        traceback_res = allocate_resource<PyObjectNifRes>();
        if (unlikely(traceback_res == nullptr)) goto failed;

        traceback_res->val = traceback;
        values[3] = enif_make_resource(env, traceback_res);
    }

    enif_make_map_from_arrays(env, keys, values, num_items, &ret);
    goto cleanup;

failed:
    Py_XDECREF(type);
    Py_XDECREF(value);
    Py_XDECREF(traceback);

cleanup:
    if (type_res != nullptr) enif_release_resource(type_res);
    if (value_res != nullptr) enif_release_resource(value_res);
    if (traceback_res != nullptr) enif_release_resource(traceback_res);
    PyErr_Clear();

    return ret;
}

#endif  // PYTHONX_PY_ERR_HPP
