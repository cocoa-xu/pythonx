#ifndef PYTHONX_PYNUMBER_HPP
#define PYTHONX_PYNUMBER_HPP
#pragma once

#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <erl_nif.h>
#include "nif_utils.hpp"
#include "pythonx_consts.hpp"
#include "pythonx_utils.hpp"
#include "pythonx_pyerr.hpp"

static ERL_NIF_TERM pythonx_py_number_check(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *res = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(res == nullptr)) return enif_make_badarg(env);

    int result = PyNumber_Check(res->val);
    if (result) return kAtomTrue;
    return kAtomFalse;
}

static ERL_NIF_TERM pythonx_py_number_add(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_Add(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_subtract(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_Subtract(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_multiply(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_Multiply(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_matrix_multiply(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_MatrixMultiply(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_floor_divide(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_FloorDivide(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_true_divide(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_TrueDivide(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_remainder(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_Remainder(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_divmod(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_Divmod(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_power(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o3 = get_resource<PyObjectNifRes>(env, argv[2]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_Power(o1->val, o2->val, o3->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_negative(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_Negative(o->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_positive(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_Positive(o->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_absolute(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_Absolute(o->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_invert(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_Invert(o->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_lshift(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_Lshift(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_rshift(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_Rshift(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_and(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_And(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_xor(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_Xor(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_or(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_Or(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_in_place_add(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_InPlaceAdd(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result, result == o1->val);
}

static ERL_NIF_TERM pythonx_py_number_in_place_subtract(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_InPlaceSubtract(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_in_place_multiply(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_InPlaceMultiply(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_in_place_matrix_multiply(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_InPlaceMatrixMultiply(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_in_place_floor_divide(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_InPlaceFloorDivide(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_in_place_true_divide(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_InPlaceTrueDivide(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_in_place_remainder(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_InPlaceRemainder(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_in_place_power(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o3 = get_resource<PyObjectNifRes>(env, argv[2]);
    if (unlikely(o3 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_InPlacePower(o1->val, o2->val, o3->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_in_place_lshift(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_InPlaceLshift(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_in_place_rshift(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_InPlaceRshift(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_in_place_and(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_InPlaceAnd(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_in_place_xor(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_InPlaceXor(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_in_place_or(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o1 = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o1 == nullptr)) return enif_make_badarg(env);

    PyObjectNifRes *o2 = get_resource<PyObjectNifRes>(env, argv[1]);
    if (unlikely(o2 == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_InPlaceOr(o1->val, o2->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_long(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_Long(o->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_float(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_Float(o->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_index(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o == nullptr)) return enif_make_badarg(env);

    PyObject *result = PyNumber_Index(o->val);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_to_base(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *n = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(n == nullptr)) return enif_make_badarg(env);

    int base;
    if (!erlang::nif::get(env, argv[1], &base)) return enif_make_badarg(env);

    PyObject *result = PyNumber_ToBase(n->val, base);
    return pyobject_to_nifres_or_pyerr(env, result);
}

static ERL_NIF_TERM pythonx_py_number_as_ssize_t(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    PyObjectNifRes *o = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(o == nullptr)) return enif_make_badarg(env);

    PyObject *val = NULL;
    PyObjectNifRes *exc = get_resource<PyObjectNifRes>(env, argv[0]);
    if (unlikely(exc == nullptr)) {
        if (!enif_is_identical(argv[1], kAtomNil)) {
            return enif_make_badarg(env);
        }
    } else {
        val = exc->val;
    }

    Py_ssize_t result = PyNumber_AsSsize_t(o->val, val);
    return erlang::nif::make(env, result);
}

#endif  // PYTHONX_PYNUMBER_HPP
