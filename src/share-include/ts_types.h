#ifndef _TS_TYPES_H_
#define _TS_TYPES_H_

#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <bits/types.h>
#include <limits.h>

typedef unsigned char		ts_uint8_t;
typedef signed char			ts_int8_t;
typedef unsigned short		ts_uint16_t;
typedef signed short		ts_int16_t;
typedef unsigned int		ts_uint32_t;
typedef signed int			ts_int32_t;
typedef unsigned long long	ts_uint64_t;
typedef signed long long	ts_int64_t;
typedef unsigned long		ts_uintptr_t;
typedef long				ts_intptr_t;

enum { ts_false=0, ts_true=1 };
typedef ts_int32_t ts_bool_t;
#endif 
