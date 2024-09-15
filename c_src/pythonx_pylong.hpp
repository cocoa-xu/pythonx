#ifndef PYTHONX_PYLONG_HPP
#define PYTHONX_PYLONG_HPP
#pragma once

#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <erl_nif.h>
#include "nif_utils.hpp"
#include "pythonx_consts.hpp"
#include "pythonx_utils.hpp"
#include "pythonx_pyerr.hpp"

static ERL_NIF_TERM pythonx_py_long_check(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PyLong_Check(res->val);
    if (result) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_long_check_exact(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PyLong_CheckExact(res->val);
    if (result) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_long_from_long(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    long val;
    if (!enif_get_long(env, argv[0], &val)) return enif_make_badarg(env);

    PyObject *result = PyLong_FromLong(val);
    return pyobject_to_nifres_or_nil(env, result);
}

static ERL_NIF_TERM pythonx_py_long_from_unsigned_long(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    unsigned long val;
    if (!enif_get_ulong(env, argv[0], &val)) return enif_make_badarg(env);

    PyObject *result = PyLong_FromUnsignedLong(val);
    return pyobject_to_nifres_or_nil(env, result);
}

static ERL_NIF_TERM pythonx_py_long_from_ssize_t(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    Py_ssize_t val;
    if (!enif_get_int64(env, argv[0], &val)) return enif_make_badarg(env);

    PyObject *result = PyLong_FromSsize_t(val);
    return pyobject_to_nifres_or_nil(env, result);
}

static ERL_NIF_TERM pythonx_py_long_from_size_t(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    size_t val;
    if (!enif_get_uint64(env, argv[0], &val)) return enif_make_badarg(env);

    PyObject *result = PyLong_FromSize_t(val);
    return pyobject_to_nifres_or_nil(env, result);
}

static ERL_NIF_TERM pythonx_py_long_from_long_long(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    long long val;
    if (!erlang::nif::get(env, argv[0], &val)) return enif_make_badarg(env);

    PyObject *result = PyLong_FromLongLong(val);
    return pyobject_to_nifres_or_nil(env, result);
}

static ERL_NIF_TERM pythonx_py_long_from_unsigned_long_long(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    unsigned long long val;
    if (!erlang::nif::get(env, argv[0], &val)) return enif_make_badarg(env);

    PyObject *result = PyLong_FromUnsignedLongLong(val);
    return pyobject_to_nifres_or_nil(env, result);
}

static ERL_NIF_TERM pythonx_py_long_from_double(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    double val;
    if (!erlang::nif::get_number(env, argv[0], &val)) return enif_make_badarg(env);

    PyObject *result = PyLong_FromDouble(val);
    return pyobject_to_nifres_or_nil(env, result);
}

static ERL_NIF_TERM pythonx_py_long_from_string(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    std::string str;
    if (!erlang::nif::get(env, argv[0], str)) return enif_make_badarg(env);

    int base;
    if (!erlang::nif::get(env, argv[1], &base)) return enif_make_badarg(env);

    const char *pstr = str.c_str();
    char *pend = nullptr;
    PyObject *result = PyLong_FromString(pstr, &pend, base);
    if (result == nullptr) {
        if (pstr == pend) return pythonx_current_pyerr(env);
        auto tmp = str[pend - pstr];
        str[pend - pstr] = '\0';
        result = PyLong_FromString(pstr, nullptr, base);
        str[pend - pstr] = tmp;
    }

    size_t len = 0;
    if (pend != nullptr) len = strlen(pend);

    std::optional<ERL_NIF_TERM> pending = erlang::nif::make_binary(env, pend, len);
    if (!pending) {
        Py_DECREF(result);
        return kAtomError;
    }

    ERL_NIF_TERM parsed = nonnull_pyobject_to_nifres(env, result, false);
    return enif_make_tuple2(env, parsed, pending.value());
}

static ERL_NIF_TERM pythonx_py_long_as_long(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ref = argv[0];
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, ref);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    long result = PyLong_AsLong(res->val);
    if (result == -1 && PyErr_Occurred()) return pythonx_current_pyerr(env);
    return enif_make_long(env, result);
}

static ERL_NIF_TERM pythonx_py_long_as_long_and_overflow(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ref = argv[0];
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, ref);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int overflow = 0;

    long result = PyLong_AsLongAndOverflow(res->val, &overflow);
    if (overflow != 0) {
        return enif_make_tuple2(env, enif_make_long(env, result), enif_make_int(env, overflow));
    }

    if (result == -1 && PyErr_Occurred()) return pythonx_current_pyerr(env);
    return enif_make_tuple2(env, enif_make_long(env, result), enif_make_int(env, overflow));
}

static ERL_NIF_TERM pythonx_py_long_as_long_long(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ref = argv[0];
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, ref);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    long long result = PyLong_AsLongLong(res->val);
    if (result == -1 && PyErr_Occurred()) return pythonx_current_pyerr(env);
    return enif_make_int64(env, result);
}

static ERL_NIF_TERM pythonx_py_long_as_long_long_and_overflow(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ref = argv[0];
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, ref);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int overflow = 0;

    long long result = PyLong_AsLongLongAndOverflow(res->val, &overflow);
    if (overflow != 0) {
        return enif_make_tuple2(env, enif_make_int64(env, result), enif_make_int(env, overflow));
    }

    if (result == -1 && PyErr_Occurred()) return pythonx_current_pyerr(env);
    return enif_make_tuple2(env, enif_make_int64(env, result), enif_make_int(env, overflow));
}

static ERL_NIF_TERM pythonx_py_long_as_ssize_t(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ref = argv[0];
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, ref);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    Py_ssize_t result = PyLong_AsSsize_t(res->val);
    if (result == -1 && PyErr_Occurred()) return pythonx_current_pyerr(env);
    return enif_make_int64(env, result);
}

static ERL_NIF_TERM pythonx_py_long_as_unsigned_long(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ref = argv[0];
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, ref);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    unsigned long result = PyLong_AsUnsignedLong(res->val);
    if (result == (unsigned long)-1 && PyErr_Occurred()) return pythonx_current_pyerr(env);
    return enif_make_uint64(env, result);
}

static ERL_NIF_TERM pythonx_py_long_as_size_t(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ref = argv[0];
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, ref);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    size_t result = PyLong_AsSize_t(res->val);
    if (result == (size_t)-1 && PyErr_Occurred()) return pythonx_current_pyerr(env);
    return enif_make_uint64(env, result);
}

static ERL_NIF_TERM pythonx_py_long_as_unsigned_long_long(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ref = argv[0];
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, ref);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    unsigned long long result = PyLong_AsUnsignedLongLong(res->val);
    if (result == (unsigned long long)-1 && PyErr_Occurred()) return pythonx_current_pyerr(env);
    return enif_make_uint64(env, result);
}

static ERL_NIF_TERM pythonx_py_long_as_unsigned_long_mask(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ref = argv[0];
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, ref);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    unsigned long result = PyLong_AsUnsignedLongMask(res->val);
    if (result == (unsigned long)-1 && PyErr_Occurred()) return pythonx_current_pyerr(env);
    return enif_make_uint64(env, result);
}

static ERL_NIF_TERM pythonx_py_long_as_unsigned_long_long_mask(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ref = argv[0];
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, ref);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    unsigned long long result = PyLong_AsUnsignedLongLongMask(res->val);
    if (result == (unsigned long long)-1 && PyErr_Occurred()) return pythonx_current_pyerr(env);
    return enif_make_uint64(env, result);
}

static ERL_NIF_TERM pythonx_py_long_as_double(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ERL_NIF_TERM ref = argv[0];
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, ref);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    double result = PyLong_AsUnsignedLongLongMask(res->val);
    if (result == -1.0 && PyErr_Occurred()) return pythonx_current_pyerr(env);
    return enif_make_double(env, result);
}

static ERL_NIF_TERM pythonx_py_long_get_info(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObject *result = PyLong_GetInfo();
    return pyobject_to_nifres_or_pyerr(env, result);
}

#endif  // PYTHONX_PYLONG_HPP
