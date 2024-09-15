#ifndef PYTHONX_PYFLOAT_HPP
#define PYTHONX_PYFLOAT_HPP
#pragma once

#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <erl_nif.h>
#include "nif_utils.hpp"
#include "pythonx_consts.hpp"
#include "pythonx_utils.hpp"
#include "pythonx_pyerr.hpp"

static ERL_NIF_TERM pythonx_py_float_check(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PyFloat_Check(res->val);
    if (result) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_float_check_exact(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PyFloat_CheckExact(res->val);
    if (result) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_float_from_string(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ref = argv[0];
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, ref);

    if (unlikely(res == nullptr)) return enif_make_badarg(env);
    PyObject *result = PyFloat_FromString(res->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_float_from_double(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    double val;
    if (!erlang::nif::get(env, argv[0], &val)) return enif_make_badarg(env);

    PyObject *result = PyFloat_FromDouble(val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_float_as_double(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ref = argv[0];
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, ref);

    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    double result = PyFloat_AsDouble(res->val);
    return erlang::nif::make(env, result);
}

static ERL_NIF_TERM pythonx_py_float_get_info(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObject *result = PyFloat_GetInfo();
    return pyobject_to_nifres_or_nil(env, result);
}

static ERL_NIF_TERM pythonx_py_float_get_max(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    return erlang::nif::make(env, PyFloat_GetMax());
}

static ERL_NIF_TERM pythonx_py_float_get_min(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    return erlang::nif::make(env, PyFloat_GetMin());
}

#endif  // PYTHONX_PYFLOAT_HPP
