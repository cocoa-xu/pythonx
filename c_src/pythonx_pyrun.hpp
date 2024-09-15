#ifndef PYTHONX_PYRUN_HPP
#define PYTHONX_PYRUN_HPP
#pragma once

#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <erl_nif.h>
#include "nif_utils.hpp"
#include "pythonx_consts.hpp"
#include "pythonx_utils.hpp"
#include "pythonx_pyerr.hpp"

static ERL_NIF_TERM pythonx_py_run_simple_string(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    std::string command;
    if (!erlang::nif::get(env, argv[0], command)) return enif_make_badarg(env);

    int result = PyRun_SimpleString(command.c_str());
    return enif_make_int(env, result);
}

static ERL_NIF_TERM pythonx_py_run_string(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    std::string str;
    if (!erlang::nif::get(env, argv[0], str)) return enif_make_badarg(env);

    int start;
    if (!erlang::nif::get(env, argv[1], &start)) return enif_make_badarg(env);

    PyObjectNifRes *globals_res = get_resource<PyObjectNifRes>(env, argv[2]);
    if (unlikely(globals_res == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *locals_res = get_resource<PyObjectNifRes>(env, argv[3]);
    if (unlikely(locals_res == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyRun_String(str.c_str(), start, globals_res->val, locals_res->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

#endif  // PYTHONX_PYRUN_HPP
