#ifndef PYTHONX_PYUNICODE_HPP
#define PYTHONX_PYUNICODE_HPP
#pragma once

#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <erl_nif.h>
#include "nif_utils.hpp"
#include "pythonx_consts.hpp"
#include "pythonx_utils.hpp"
#include "pythonx_pyerr.hpp"

static ERL_NIF_TERM pythonx_py_unicode_from_string(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    std::string str;
    if (!erlang::nif::get(env, argv[0], str)) {
        return enif_make_badarg(env);
    }

    PyObject *py_str = PyUnicode_FromString(str.c_str());
    if (unlikely(py_str == nullptr)) return kAtomNil;

    PyObjectNifRes *res = allocate_resource<PyObjectNifRes>();
    if (unlikely(res == nullptr)) {
        Py_DECREF(py_str);
        return kAtomError;
    }

    res->val = py_str;
    ERL_NIF_TERM ret = enif_make_resource(env, res);
    enif_release_resource(res);
    return ret;
}

static ERL_NIF_TERM pythonx_py_unicode_as_utf8(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    const char* py_utf8 = PyUnicode_AsUTF8(res->val);
    if (unlikely(py_utf8 == nullptr)) return kAtomNil;

    auto data = erlang::nif::make_binary(env, py_utf8);
    if (unlikely(!data.has_value())) return kAtomError;
    return data.value();
}

#endif  // PYTHONX_PYUNICODE_HPP
