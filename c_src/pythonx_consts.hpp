#ifndef PYTHONX_CONSTS_HPP
#define PYTHONX_CONSTS_HPP
#pragma once

#include "nif_utils.hpp"

// Atoms
STATIC_ATOM(Ok);
STATIC_ATOM(Nil);
STATIC_ATOM(True);
STATIC_ATOM(False);
STATIC_ATOM(Error);
STATIC_ATOM(Struct);
STATIC_ATOM(Type);
STATIC_ATOM(Value);
STATIC_ATOM(Traceback);
static ERL_NIF_TERM kModulePythonxRawPyErr;

static void init_pythonx_consts(ErlNifEnv *env) {
    kAtomOk = erlang::nif::atom(env, "ok");
    kAtomNil = erlang::nif::atom(env, "nil");
    kAtomTrue = erlang::nif::atom(env, "true");
    kAtomFalse = erlang::nif::atom(env, "false");
    kAtomError = erlang::nif::atom(env, "error");
    kAtomStruct = erlang::nif::atom(env, "__struct__");
    kAtomType = erlang::nif::atom(env, "type");
    kAtomValue = erlang::nif::atom(env, "value");
    kAtomTraceback = erlang::nif::atom(env, "traceback");

    kModulePythonxRawPyErr = enif_make_atom(env, "Elixir.Pythonx.C.PyErr");
}

#endif  // PYTHONX_CONSTS_HPP
