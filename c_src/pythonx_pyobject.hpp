#ifndef PYTHONX_PYOBJECT_HPP
#define PYTHONX_PYOBJECT_HPP
#pragma once

#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <erl_nif.h>
#include "nif_utils.hpp"
#include "pythonx_consts.hpp"
#include "pythonx_utils.hpp"
#include "pythonx_pyerr.hpp"

static ERL_NIF_TERM pythonx_py_object_has_attr(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *attr_res = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(attr_res == nullptr)) return enif_make_badarg(env);

    int result = PyObject_HasAttr(res->val, attr_res->val);
    if (result == 1) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_object_has_attr_string(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    std::string attr_name;
    if (!erlang::nif::get(env, argv[1], attr_name)) {
        return enif_make_badarg(env);
    }

    int result = PyObject_HasAttrString(res->val, attr_name.c_str());
    if (result == 1) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_object_get_attr(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *attr_res = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(attr_res == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyObject_GetAttr(res->val, attr_res->val);
    return pyobject_to_nifres_or_nil(env, result);
}

static ERL_NIF_TERM pythonx_py_object_get_attr_string(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    std::string attr_name;
    if (!erlang::nif::get(env, argv[1], attr_name)) {
        return enif_make_badarg(env);
    }

    PyObject *result = PyObject_GetAttrString(res->val, attr_name.c_str());
    return pyobject_to_nifres_or_nil(env, result);
}

static ERL_NIF_TERM pythonx_py_object_generic_get_attr(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *attr_res = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(attr_res == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyObject_GenericGetAttr(res->val, attr_res->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_object_set_attr(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *attr_res = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(attr_res == nullptr)) return enif_make_badarg(env);

    PyObject *v = NULL;
    PyObjectNifRes *val_res = get_resource<PyObjectNifRes>(env, argv[2]);
    if (unlikely(val_res == nullptr)) {
        if (!enif_is_identical(argv[2], kAtomNil)) {
            return enif_make_badarg(env);
        }
    } else {
        v = val_res->val;
    }

    int result = PyObject_SetAttr(res->val, attr_res->val, v);
    if (result == -1) return pythonx_current_pyerr(env);
    return kAtomTrue;
}

static ERL_NIF_TERM pythonx_py_object_set_attr_string(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    std::string attr_name;
    if (!erlang::nif::get(env, argv[1], attr_name)) {
        return enif_make_badarg(env);
    }

    PyObject *v = NULL;
    PyObjectNifRes *val_res = get_resource<PyObjectNifRes>(env, argv[2]);
    if (unlikely(val_res == nullptr)) {
        if (!enif_is_identical(argv[2], kAtomNil)) {
            return enif_make_badarg(env);
        }
    } else {
        v = val_res->val;
    }

    int result = PyObject_SetAttrString(res->val, attr_name.c_str(), v);
    if (result == -1) return pythonx_current_pyerr(env);
    return kAtomTrue;
}

static ERL_NIF_TERM pythonx_py_object_generic_set_attr(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *attr_res = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(attr_res == nullptr)) return enif_make_badarg(env);

    PyObject *v = NULL;
    PyObjectNifRes *val_res = get_resource<PyObjectNifRes>(env, argv[2]);
    if (unlikely(val_res == nullptr)) {
        if (!enif_is_identical(argv[2], kAtomNil)) {
            return enif_make_badarg(env);
        }
    } else {
        v = val_res->val;
    }

    int result = PyObject_GenericSetAttr(res->val, attr_res->val, v);
    if (result == -1) return pythonx_current_pyerr(env);
    return kAtomTrue;
}

static ERL_NIF_TERM pythonx_py_object_del_attr(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *attr_res = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(attr_res == nullptr)) return enif_make_badarg(env);

    int result = PyObject_DelAttr(res->val, attr_res->val);
    if (result == -1) return kAtomFalse;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_object_del_attr_string(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    std::string attr_name;
    if (!erlang::nif::get(env, argv[1], attr_name)) {
        return enif_make_badarg(env);
    }

    int result = PyObject_DelAttrString(res->val, attr_name.c_str());
    if (result == 1) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_object_is_true(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PyObject_IsTrue(res->val);
    if (result == 1) return kAtomTrue;
    else if (result == 0) return kAtomFalse;
    else return kAtomError;
}

static ERL_NIF_TERM pythonx_py_object_not(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PyObject_Not(res->val);
    if (result == 1) return kAtomTrue;
    else if (result == 0) return kAtomFalse;
    else return kAtomError;
}

static ERL_NIF_TERM pythonx_py_object_type(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObject * result = PyObject_Type(res->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_object_length(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    Py_ssize_t result = PyObject_Length(res->val);
    return enif_make_int64(env, result);
}

static ERL_NIF_TERM pythonx_py_object_repr(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyObject_Repr(res->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_object_ascii(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyObject_ASCII(res->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_object_str(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyObject_Str(res->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_object_bytes(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyObject_Bytes(res->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

#endif  // PYTHONX_PYOBJECT_HPP
