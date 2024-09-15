#ifndef PYTHONX_UTILS_HPP
#define PYTHONX_UTILS_HPP
#pragma once

#include "nif_utils.hpp"

#ifndef likely
#define likely(x)       __builtin_expect(!!(x), 1)
#endif
#ifndef unlikely
#define unlikely(x)     __builtin_expect(!!(x), 0)
#endif

#endif  // PYTHONX_UTILS_HPP
