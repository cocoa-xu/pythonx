#ifndef PYTHONX_PYTUPLE_HPP
#define PYTHONX_PYTUPLE_HPP
#pragma once

#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <erl_nif.h>
#include "nif_utils.hpp"
#include "pythonx_consts.hpp"
#include "pythonx_utils.hpp"
#include "pythonx_pyerr.hpp"

static ERL_NIF_TERM pythonx_py_tuple_check(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PyTuple_Check(res->val);
    if (result) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_tuple_check_exact(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PyTuple_CheckExact(res->val);
    if (result) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_tuple_new(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    int64_t len;
    if (!erlang::nif::get(env, argv[0], &len)) {
        return enif_make_badarg(env);
    }

    PyObject *result = PyTuple_New(len);
    if (unlikely(result == nullptr)) return pythonx_current_pyerr(env);

    PyObjectNifRes *result_res = allocate_resource<PyObjectNifRes>();
    if (unlikely(result_res == nullptr)) {
        Py_DECREF(result);
        return kAtomError;
    }

    result_res->val = result;
    ERL_NIF_TERM ret = enif_make_resource(env, result_res);
    enif_release_resource(result_res);
    return ret;
}

static ERL_NIF_TERM pythonx_py_tuple_size(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    Py_ssize_t size = PyTuple_Size(res->val);
    if (size == -1) return pythonx_current_pyerr(env);
    return enif_make_int64(env, size);
}

static ERL_NIF_TERM pythonx_py_tuple_get_item(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int64_t pos;
    if (!erlang::nif::get(env, argv[1], &pos)) return enif_make_badarg(env);

    PyObject * result = PyTuple_GetItem(res->val, pos);
    if (unlikely(result == nullptr)) return pythonx_current_pyerr(env);

    PyObjectNifRes *result_res = allocate_resource<PyObjectNifRes>();
    if (unlikely(result_res == nullptr)) {
        Py_DECREF(result);
        return kAtomError;
    }

    result_res->val = result;
    ERL_NIF_TERM ret = enif_make_resource(env, result_res);
    enif_release_resource(result_res);
    return ret;
}

static ERL_NIF_TERM pythonx_py_tuple_get_slice(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int64_t low, high;
    if (!erlang::nif::get(env, argv[1], &low)) return enif_make_badarg(env);
    if (!erlang::nif::get(env, argv[2], &high)) return enif_make_badarg(env);

    PyObject * result = PyTuple_GetSlice(res->val, low, high);
    if (unlikely(result == nullptr)) return pythonx_current_pyerr(env);

    PyObjectNifRes *result_res = allocate_resource<PyObjectNifRes>();
    if (unlikely(result_res == nullptr)) {
        Py_DECREF(result);
        return kAtomError;
    }

    result_res->val = result;
    ERL_NIF_TERM ret = enif_make_resource(env, result_res);
    enif_release_resource(result_res);
    return ret;
}

#endif  // PYTHONX_PYTUPLE_HPP
