#ifndef PYOBJECT_NIF_RES_HPP
#define PYOBJECT_NIF_RES_HPP
#pragma once

#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <erl_nif.h>
#include "nif_utils.hpp"
#include "pythonx_consts.hpp"

struct PyObjectNifRes {
    PyObject * val;
    bool borrowed = false;
    static ErlNifResourceType *type;
};

static void destruct_py_object(ErlNifEnv *env, void * args) {
    // args can't be nullptr
    // Py_XDECREF check if val is nullptr before decrementing the reference count
    auto res = (struct PyObjectNifRes *)args;
    if (!res->borrowed) Py_XDECREF(res->val);
}

template <typename T>
auto allocate_resource() -> T * {
    return (T *)enif_alloc_resource(T::type, sizeof(T));
}

template <typename T>
auto allocate_resource(ErlNifEnv *env, ERL_NIF_TERM &error) -> T * {
    T *res = allocate_resource<T>();
    if (unlikely(res == nullptr)) {
      error = erlang::nif::error(env, kAtomError, "cannot allocate Nif resource");
      return res;
    }
    return res;
}

template <typename T>
auto get_resource(ErlNifEnv *env, ERL_NIF_TERM term) -> T * {
    T *res = nullptr;
    enif_get_resource(env, term, T::type, reinterpret_cast<void **>(&res));
    return res;
}

#endif  // PYOBJECT_NIF_RES_HPP
