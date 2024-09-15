#ifndef PYTHONX_PYEVAL_HPP
#define PYTHONX_PYEVAL_HPP
#pragma once

#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <erl_nif.h>
#include "nif_utils.hpp"
#include "pythonx_consts.hpp"
#include "pythonx_utils.hpp"
#include "pythonx_pyerr.hpp"

static ERL_NIF_TERM pythonx_py_eval_get_builtins(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObject *result = PyEval_GetBuiltins();
    return pyobject_to_nifres_or_nil(env, result);
}

static ERL_NIF_TERM pythonx_py_eval_get_locals(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObject *result = PyEval_GetLocals();
    return pyobject_to_nifres_or_nil(env, result);
}

static ERL_NIF_TERM pythonx_py_eval_get_globals(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObject *result = PyEval_GetGlobals();
    return pyobject_to_nifres_or_nil(env, result);
}

static ERL_NIF_TERM pythonx_py_eval_get_func_name(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *func_res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(func_res == nullptr)) return enif_make_badarg(env);

    const char *result = PyEval_GetFuncName(func_res->val);
    std::optional<ERL_NIF_TERM> ret = erlang::nif::make_binary(env, result);
    if (!ret) return kAtomError;
    return ret.value();
}

static ERL_NIF_TERM pythonx_py_eval_get_func_desc(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *func_res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(func_res == nullptr)) return enif_make_badarg(env);

    const char *result = PyEval_GetFuncDesc(func_res->val);
    std::optional<ERL_NIF_TERM> ret = erlang::nif::make_binary(env, result);
    if (!ret) return kAtomError;
    return ret.value();
}

#endif  // PYTHONX_PYEVAL_HPP
