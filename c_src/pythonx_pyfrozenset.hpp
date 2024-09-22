#ifndef PYTHONX_PYFROZENSET_HPP
#define PYTHONX_PYFROZENSET_HPP
#pragma once

#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <erl_nif.h>
#include "nif_utils.hpp"
#include "pythonx_consts.hpp"
#include "pythonx_utils.hpp"
#include "pythonx_pyerr.hpp"

static ERL_NIF_TERM pythonx_py_frozenset_check(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PyFrozenSet_Check(res->val);
    if (result) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_frozenset_check_exact(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PyFrozenSet_CheckExact(res->val);
    if (result) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_frozenset_new(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObject * iterable = nullptr;
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (res == nullptr) {
        if (!enif_is_identical(argv[0], kAtomNil)) {
            return enif_make_badarg(env);    
        }
    } else {
        iterable = res->val;
    }

    PyObject * result = PyFrozenSet_New(iterable);
    return pyobject_to_nifres_or_pyerr(env, result);
}

#endif  // PYTHONX_PYFROZENSET_HPP
