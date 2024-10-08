#ifndef NIF_UTILS_HPP
#define NIF_UTILS_HPP
#pragma once

#include <erl_nif.h>
#include <stdarg.h>
#include <map>
#include <string>
#include <vector>
#include <cstdint>
#include <optional>
#include <unordered_set>

#define STATIC_ATOM(name) static ERL_NIF_TERM kAtom##name

namespace erlang
{
  namespace nif
  {
    ERL_NIF_TERM atom(ErlNifEnv *env, const char *msg)
    {
      ERL_NIF_TERM a;
      if (enif_make_existing_atom(env, msg, &a, ERL_NIF_LATIN1)) {
        return a;
      } else {
        return enif_make_atom(env, msg);
      }
    }

    // Status helpers

    // Helper for returning `{:error, msg}` from NIF.
    ERL_NIF_TERM error(ErlNifEnv *env, const char *msg)
    {
      ERL_NIF_TERM atom_error = atom(env, "error");
      ERL_NIF_TERM reason;
      unsigned char * ptr;
      size_t len = strlen(msg);
      if ((ptr = enif_make_new_binary(env, len, &reason)) != nullptr) {
          strcpy((char *)ptr, msg);
          return enif_make_tuple2(env, atom_error, reason);
      } else {
          ERL_NIF_TERM msg_term = enif_make_string(env, msg, ERL_NIF_LATIN1);
          return enif_make_tuple2(env, atom_error, msg_term);
      }
    }

    ERL_NIF_TERM error(ErlNifEnv *env, ERL_NIF_TERM atom_error, const char *msg)
    {
      ERL_NIF_TERM reason;
      unsigned char * ptr;
      size_t len = strlen(msg);
      if ((ptr = enif_make_new_binary(env, len, &reason)) != nullptr) {
          strcpy((char *)ptr, msg);
          return enif_make_tuple2(env, atom_error, reason);
      } else {
          ERL_NIF_TERM msg_term = enif_make_string(env, msg, ERL_NIF_LATIN1);
          return enif_make_tuple2(env, atom_error, msg_term);
      }
    }

    // Helper for returning `{:ok, term}` from NIF.
    ERL_NIF_TERM ok(ErlNifEnv *env)
    {
      return atom(env, "ok");
    }

    // Helper for returning `:ok` from NIF.
    ERL_NIF_TERM ok(ErlNifEnv *env, ERL_NIF_TERM term)
    {
      return enif_make_tuple2(env, ok(env), term);
    }

    // Numeric types

    int get(ErlNifEnv *env, ERL_NIF_TERM term, int *var)
    {
      return enif_get_int(env, term,
                          reinterpret_cast<int *>(var));
    }

    int get(ErlNifEnv *env, ERL_NIF_TERM term, int64_t *var)
    {
      return enif_get_int64(env, term,
                            reinterpret_cast<ErlNifSInt64 *>(var));
    }

    int get(ErlNifEnv *env, ERL_NIF_TERM term, uint64_t *var)
    {
      return enif_get_uint64(env, term,
                             reinterpret_cast<ErlNifUInt64 *>(var));
    }

    int get(ErlNifEnv *env, ERL_NIF_TERM term, double *var)
    {
      return enif_get_double(env, term, var);
    }

    int get_number(ErlNifEnv *env, ERL_NIF_TERM term, double *var)
    {
      if (!enif_get_double(env, term, var)) {
        ErlNifSInt64 i64;
        if (!enif_get_int64(env, term, &i64)) {
          return 0;
        }
        *var = (double)i64;
      }
      return 1;
    }

    // Standard types

    int get(ErlNifEnv *env, ERL_NIF_TERM term, std::string &var)
    {
      unsigned len;
      int ret = enif_get_list_length(env, term, &len);

      if (!ret)
      {
        ErlNifBinary bin;
        ret = enif_inspect_binary(env, term, &bin);
        if (!ret)
        {
          return 0;
        }
        var = std::string((const char *)bin.data, bin.size);
        return ret;
      }

      var.resize(len + 1);
      ret = enif_get_string(env, term, &*(var.begin()), var.size(), ERL_NIF_LATIN1);

      if (ret > 0)
      {
        var.resize(ret - 1);
      }
      else if (ret == 0)
      {
        var.resize(0);
      }
      else
      {
      }

      return ret;
    }

    ERL_NIF_TERM make(ErlNifEnv *env, bool var)
    {
        return var ? atom(env, "true") : atom(env, "false");
    }

    ERL_NIF_TERM make(ErlNifEnv *env, long var)
    {
      return enif_make_int64(env, var);
    }

    ERL_NIF_TERM make(ErlNifEnv *env, int var)
    {
      return enif_make_int(env, var);
    }

    ERL_NIF_TERM make(ErlNifEnv *env, double var)
    {
      return enif_make_double(env, var);
    }

    ERL_NIF_TERM make(ErlNifEnv *env, ErlNifBinary var)
    {
      return enif_make_binary(env, &var);
    }

    ERL_NIF_TERM make(ErlNifEnv *env, std::string var)
    {
      return enif_make_string(env, var.c_str(), ERL_NIF_LATIN1);
    }

    ERL_NIF_TERM make(ErlNifEnv *env, const char *string)
    {
      return enif_make_string(env, string, ERL_NIF_LATIN1);
    }

    std::optional<ERL_NIF_TERM> make_binary(ErlNifEnv *env, const char *string, size_t length)
    {
      ERL_NIF_TERM term;
      unsigned char * data = enif_make_new_binary(env, length, &term);
      if (data != nullptr) {
        memcpy(data, string, length);
        return term;
      } else {
        return std::nullopt;
      }
    }

    std::optional<ERL_NIF_TERM> make_binary(ErlNifEnv *env, const char *string)
    {
      ERL_NIF_TERM term;
      size_t length = strlen(string);
      return make_binary(env, string, length);
    }

    template<typename T>
    int make_f64_list_from_c_array(ErlNifEnv *env, size_t count, T *data, ERL_NIF_TERM &out) {
      if (count == 0) {
        out = enif_make_list_from_array(env, nullptr, 0);
        return 0;
      }

      ERL_NIF_TERM *terms = (ERL_NIF_TERM *)enif_alloc(sizeof(ERL_NIF_TERM) * count);
      if (terms == nullptr) {
        return 1;
      }
      for (size_t i = 0; i < count; ++i) {
        terms[i] = enif_make_double(env, (double)(data[i]));
      }
      out = enif_make_list_from_array(env, terms, (unsigned) count);
      enif_free(terms);
      return 0;
    }

    template<typename T>
    int make_i64_list_from_c_array(ErlNifEnv *env, size_t count, T *data, ERL_NIF_TERM &out) {
      if (count == 0) {
        out = enif_make_list_from_array(env, nullptr, 0);
        return 0;
      }

      ERL_NIF_TERM *terms = (ERL_NIF_TERM *)enif_alloc(sizeof(ERL_NIF_TERM) * count);
      if (terms == nullptr) {
        return 1;
      }
      for (size_t i = 0; i < count; ++i) {
        terms[i] = enif_make_int64(env, (int64_t)(data[i]));
      }
      out = enif_make_list_from_array(env, terms, (unsigned) count);
      enif_free(terms);
      return 0;
    }

    template<typename T>
    int make_u64_list_from_c_array(ErlNifEnv *env, size_t count, T *data, ERL_NIF_TERM &out) {
      if (count == 0) {
        out = enif_make_list_from_array(env, nullptr, 0);
        return 0;
      }

      ERL_NIF_TERM *terms = (ERL_NIF_TERM *)enif_alloc(sizeof(ERL_NIF_TERM) * count);
      if (terms == nullptr) {
        return 1;
      }
      for (size_t i = 0; i < count; ++i) {
        terms[i] = enif_make_uint64(env, (uint64_t)(data[i]));
      }
      out = enif_make_list_from_array(env, terms, (unsigned) count);
      enif_free(terms);
      return 0;
    }

    template<typename T>
    int make_i32_list_from_c_array(ErlNifEnv *env, size_t count, T *data, ERL_NIF_TERM &out) {
      if (count == 0) {
        out = enif_make_list_from_array(env, nullptr, 0);
        return 0;
      }

      ERL_NIF_TERM *terms = (ERL_NIF_TERM *)enif_alloc(sizeof(ERL_NIF_TERM) * count);
      if (terms == nullptr) {
          return 1;
      }
      for (size_t i = 0; i < count; ++i) {
        terms[i] = enif_make_int(env, (int32_t)(data[i]));
      }
      out = enif_make_list_from_array(env, terms, (unsigned) count);
      enif_free(terms);
      return 0;
    }

    template<typename T>
    int make_u32_list_from_c_array(ErlNifEnv *env, size_t count, T *data, ERL_NIF_TERM &out) {
      if (count == 0) {
        out = enif_make_list_from_array(env, nullptr, 0);
        return 0;
      }

      ERL_NIF_TERM *terms = (ERL_NIF_TERM *)enif_alloc(sizeof(ERL_NIF_TERM) * count);
      if (terms == nullptr) {
        return 1;
      }
      for (size_t i = 0; i < count; ++i) {
        terms[i] = enif_make_uint(env, (uint32_t)(data[i]));
      }
      out = enif_make_list_from_array(env, terms, (unsigned) count);
      enif_free(terms);
      return 0;
    }

    // Atoms

    int get_atom(ErlNifEnv *env, ERL_NIF_TERM term, std::string &var)
    {
      unsigned atom_length;
      if (!enif_get_atom_length(env, term, &atom_length, ERL_NIF_LATIN1))
      {
        return 0;
      }

      var.resize(atom_length + 1);

      if (!enif_get_atom(env, term, &(*(var.begin())), var.size(), ERL_NIF_LATIN1))
        return 0;

      var.resize(atom_length);

      return 1;
    }

    // Check if :nil
    int check_nil(ErlNifEnv *env, ERL_NIF_TERM term) {
      return enif_is_identical(term, atom(env, "nil"));
    }

    // Boolean

    int get(ErlNifEnv *env, ERL_NIF_TERM term, bool *var)
    {
      if (!enif_is_atom(env, term))
        return 0;
      *var = enif_is_identical(term, atom(env, "true"));
      return 1;
    }

    // Containers

    int get_tuple(ErlNifEnv *env, ERL_NIF_TERM tuple, std::vector<int64_t> &var)
    {
      const ERL_NIF_TERM *terms;
      int length;
      if (!enif_get_tuple(env, tuple, &length, &terms))
        return 0;
      var.reserve(length);

      for (int i = 0; i < length; i++)
      {
        int data;
        if (!get(env, terms[i], &data))
          return 0;
        var.push_back(data);
      }
      return 1;
    }

    int get_list(ErlNifEnv *env,
                 ERL_NIF_TERM list,
                 std::vector<ErlNifBinary> &var)
    {
      unsigned int length;
      if (!enif_get_list_length(env, list, &length))
        return 0;
      var.reserve(length);
      ERL_NIF_TERM head, tail;

      while (enif_get_list_cell(env, list, &head, &tail))
      {
        ErlNifBinary elem;
        if (!enif_inspect_binary(env, head, &elem))
          return 0;
        var.push_back(elem);
        list = tail;
      }
      return 1;
    }

    int get_unordered_set(ErlNifEnv *env,
                 ERL_NIF_TERM list,
                 std::unordered_set<std::string> &var)
    {
      unsigned int length;
      if (!enif_get_list_length(env, list, &length)) return 0;
      ERL_NIF_TERM head, tail;

      std::string elem;
      ErlNifBinary binary_term;
      while (enif_get_list_cell(env, list, &head, &tail)) {
        if (get_atom(env, head, elem)) {
          var.insert(elem);
        } else if (enif_inspect_binary(env, head, &binary_term)) {
          var.insert(std::string((const char *)binary_term.data, binary_term.size));
        } else {
          return 0;
        }
        list = tail;
      }
      return 1;
    }

    int get_list(ErlNifEnv *env,
                 ERL_NIF_TERM list,
                 std::vector<std::string> &var)
    {
      unsigned int length;
      if (!enif_get_list_length(env, list, &length)) return 0;
      var.reserve(length);
      ERL_NIF_TERM head, tail;

      std::string elem;
      ErlNifBinary binary_term;
      while (enif_get_list_cell(env, list, &head, &tail)) {
        if (get_atom(env, head, elem)) {
          var.emplace_back(elem);
        } else if (enif_inspect_binary(env, head, &binary_term)) {
          var.emplace_back(std::string((const char *)binary_term.data, binary_term.size));  
        } else {
          return 0;
        }
        list = tail;
      }
      return 1;
    }

    int get_list(ErlNifEnv *env, ERL_NIF_TERM list, std::vector<int64_t> &var)
    {
      unsigned int length;
      if (!enif_get_list_length(env, list, &length))
        return 0;
      var.reserve(length);
      ERL_NIF_TERM head, tail;

      while (enif_get_list_cell(env, list, &head, &tail))
      {
        int64_t elem;
        if (!get(env, head, &elem))
          return 0;
        var.push_back(elem);
        list = tail;
      }
      return 1;
    }

    int get_list(ErlNifEnv *env, ERL_NIF_TERM list, std::vector<int> &var)
    {
      unsigned int length;
      if (!enif_get_list_length(env, list, &length))
        return 0;
      var.reserve(length);
      ERL_NIF_TERM head, tail;

      while (enif_get_list_cell(env, list, &head, &tail))
      {
        int elem;
        if (!get(env, head, &elem))
          return 0;
        var.push_back(elem);
        list = tail;
      }
      return 1;
    }

      int get_list(ErlNifEnv *env, ERL_NIF_TERM list, std::vector<double> &var)
      {
          unsigned int length;
          if (!enif_get_list_length(env, list, &length))
              return 0;
          var.reserve(length);
          ERL_NIF_TERM head, tail;

          while (enif_get_list_cell(env, list, &head, &tail))
          {
              double elem;
              if (!get(env, head, &elem))
                  return 0;
              var.push_back(elem);
              list = tail;
          }
          return 1;
      }

      int get_list(ErlNifEnv *env, ERL_NIF_TERM list, std::vector<float> &var)
      {
          unsigned int length;
          if (!enif_get_list_length(env, list, &length))
              return 0;
          var.reserve(length);
          ERL_NIF_TERM head, tail;

          while (enif_get_list_cell(env, list, &head, &tail))
          {
              double elem;
              if (!get(env, head, &elem))
                  return 0;
              var.push_back(static_cast<float>(elem));
              list = tail;
          }
          return 1;
      }

    inline int parse_arg(ErlNifEnv *env, int opt_arg_index, const ERL_NIF_TERM * argv, std::map<std::string, ERL_NIF_TERM>& erl_terms) {
        ERL_NIF_TERM opts = argv[opt_arg_index];
        if (enif_is_list(env, opts)) {
            unsigned length = 0;
            if (!enif_get_list_length(env, opts, &length)) {
              return false;
            }
            unsigned list_index = 0;

            ERL_NIF_TERM term, rest;
            while (list_index != length) {
                if (!enif_get_list_cell(env, opts, &term, &rest)) {
                  return false;
                }
                if (enif_is_tuple(env, term)) {
                    int arity;
                    const ERL_NIF_TERM * arr = nullptr;
                    if (enif_get_tuple(env, term, &arity, &arr)) {
                        if (arity == 2) {
                            std::string ckey;
                            if (get_atom(env, arr[0], ckey)) {
                                erl_terms[ckey] = arr[1];
                            }
                        }
                    }
                    list_index++;
                    opts = rest;
                } else {
                  return false;
                }
            }
            return true;
        }
        return false;
    }
  }
}

#endif // NIF_UTILS_HPP
