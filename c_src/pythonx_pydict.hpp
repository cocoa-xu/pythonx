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

static ERL_NIF_TERM pythonx_py_dict_set_item(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ref = argv[0];
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, ref);
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
    ERL_NIF_TERM ref = argv[0];
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, ref);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    std::string key;
    if (!erlang::nif::get(env, argv[1], key)) return enif_make_badarg(env);

    PyObjectNifRes *val_res = get_resource<PyObjectNifRes>(env, argv[2]);
    if (unlikely(val_res == nullptr)) return enif_make_badarg(env);

    int result = PyDict_SetItemString(res->val, key.c_str(), val_res->val);
    if (result == -1) return pythonx_current_pyerr(env);
    return kAtomTrue;
}

#endif  // PYTHONX_PYDICT_HPP
