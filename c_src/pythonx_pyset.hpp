#ifndef PYTHONX_PYSET_HPP
#define PYTHONX_PYSET_HPP
#pragma once

#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <erl_nif.h>
#include "nif_utils.hpp"
#include "pythonx_consts.hpp"
#include "pythonx_utils.hpp"
#include "pythonx_pyerr.hpp"

static ERL_NIF_TERM pythonx_py_set_check(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PySet_Check(res->val);
    if (result) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_set_new(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObject * iterable = nullptr;
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (res == nullptr) {
        if (!enif_is_identical(argv[0], kAtomNil)) {
            return enif_make_badarg(env);    
        }
    } else {
        iterable = res->val;
    }

    PyErr_Clear();
    PyObject * result = PySet_New(iterable);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_set_size(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (res == nullptr) return enif_make_badarg(env);

    PyErr_Clear();
    Py_ssize_t size = PySet_Size(res->val);
    // if (PyErr_Occurred()) return pythonx_current_pyerr(env);
    return enif_make_int64(env, size);
}

static ERL_NIF_TERM pythonx_py_set_contains(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (res == nullptr) return enif_make_badarg(env);

    PyObjectNifRes *key = get_resource<PyObjectNifRes>(env, argv[1]);
    if (key == nullptr) return enif_make_badarg(env);

    int result = PySet_Contains(res->val, key->val);
    if (result == -1) return pythonx_current_pyerr(env);
    if (result == 1) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_set_add(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (res == nullptr) return enif_make_badarg(env);

    PyObjectNifRes *key = get_resource<PyObjectNifRes>(env, argv[1]);
    if (key == nullptr) return enif_make_badarg(env);

    int result = PySet_Add(res->val, key->val);
    if (result == -1) return pythonx_current_pyerr(env);
    return kAtomTrue;
}

static ERL_NIF_TERM pythonx_py_set_discard(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (res == nullptr) return enif_make_badarg(env);

    PyObjectNifRes *key = get_resource<PyObjectNifRes>(env, argv[1]);
    if (key == nullptr) return enif_make_badarg(env);

    int result = PySet_Discard(res->val, key->val);
    if (result == -1) return pythonx_current_pyerr(env);
    if (result == 0) return kAtomFalse;
    return kAtomTrue;
}

static ERL_NIF_TERM pythonx_py_set_pop(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (res == nullptr) return enif_make_badarg(env);

    PyObject *result = PySet_Pop(res->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_set_clear(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (res == nullptr) return enif_make_badarg(env);

    int result = PySet_Clear(res->val);
    if (result == -1) return pythonx_current_pyerr(env);
    return kAtomTrue;
}

#endif  // PYTHONX_PYSET_HPP
