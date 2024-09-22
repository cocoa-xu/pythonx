#ifndef PYTHONX_PYLIST_HPP
#define PYTHONX_PYLIST_HPP
#pragma once

#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <erl_nif.h>
#include "nif_utils.hpp"
#include "pythonx_consts.hpp"
#include "pythonx_utils.hpp"
#include "pythonx_pyerr.hpp"

static ERL_NIF_TERM pythonx_py_list_check(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PyList_Check(res->val);
    if (result) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_list_check_exact(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PyList_CheckExact(res->val);
    if (result) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_list_new(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    int64_t len;
    if (!erlang::nif::get(env, argv[0], &len)) {
        return enif_make_badarg(env);
    }

    PyObject *result = PyList_New(len);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_list_size(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    Py_ssize_t size = PyList_Size(res->val);
    if (size == -1) return pythonx_current_pyerr(env);
    return enif_make_int64(env, size);
}

static ERL_NIF_TERM pythonx_py_list_get_item(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int64_t index;
    if (!erlang::nif::get(env, argv[1], &index)) return enif_make_badarg(env);

    PyObject *result = PyList_GetItem(res->val, index);
    return pyobject_to_nifres_or_pyerr(env, result, true);
}

static ERL_NIF_TERM pythonx_py_list_set_item(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int64_t index;
    if (!erlang::nif::get(env, argv[1], &index)) {
        return enif_make_badarg(env);
    }

    PyObjectNifRes *item_res = get_resource<PyObjectNifRes>(env, argv[2]);
    if (unlikely(item_res == nullptr)) return enif_make_badarg(env);

    int result = PyList_SetItem(res->val, index, item_res->val);
    if (result == 0) return kAtomTrue;
    return pythonx_current_pyerr(env);
}

static ERL_NIF_TERM pythonx_py_list_insert(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int64_t index;
    if (!erlang::nif::get(env, argv[1], &index)) {
        return enif_make_badarg(env);
    }

    PyObjectNifRes *item_res = get_resource<PyObjectNifRes>(env, argv[2]);
    if (unlikely(item_res == nullptr)) return enif_make_badarg(env);

    int result = PyList_Insert(res->val, index, item_res->val);
    if (result == 0) return kAtomTrue;
    return pythonx_current_pyerr(env);
}

static ERL_NIF_TERM pythonx_py_list_append(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *item_res = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(item_res == nullptr)) return enif_make_badarg(env);

    int result = PyList_Append(res->val, item_res->val);
    if (result == 0) return kAtomTrue;
    return pythonx_current_pyerr(env);
}

static ERL_NIF_TERM pythonx_py_list_get_slice(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int64_t low, high;
    if (!erlang::nif::get(env, argv[1], &low)) return enif_make_badarg(env);
    if (!erlang::nif::get(env, argv[2], &high)) return enif_make_badarg(env);

    PyObject *result = PyList_GetSlice(res->val, low, high);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_list_set_slice(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int64_t low, high;
    if (!erlang::nif::get(env, argv[1], &low)) return enif_make_badarg(env);
    if (!erlang::nif::get(env, argv[2], &high)) return enif_make_badarg(env);

    PyObject *itemlist = nullptr;
    PyObjectNifRes *itemlist_res = get_resource<PyObjectNifRes>(env, argv[3]);
    if (unlikely(itemlist_res == nullptr)) {
        if (!enif_is_identical(argv[3], kAtomNil)) {
            return enif_make_badarg(env);
        }
    } else {
        itemlist = itemlist_res->val;
    }

    int result = PyList_SetSlice(res->val, low, high, itemlist);
    if (result == 0) return kAtomTrue;
    return pythonx_current_pyerr(env);
}

static ERL_NIF_TERM pythonx_py_list_sort(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PyList_Sort(res->val);
    if (result == 0) return kAtomTrue;
    return pythonx_current_pyerr(env);
}

static ERL_NIF_TERM pythonx_py_list_reverse(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PyList_Reverse(res->val);
    if (result == 0) return kAtomTrue;
    return pythonx_current_pyerr(env);
}

static ERL_NIF_TERM pythonx_py_list_as_tuple(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyList_AsTuple(res->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

#endif  // PYTHONX_PYLIST_HPP
