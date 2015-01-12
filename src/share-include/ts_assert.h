#ifndef _TS_ASSERT_H_
#define _TS_ASSERT_H_

#include "ts_types.h"


#ifdef __cplusplus
extern "C" {
#endif

#ifdef BUILD_DEBUG
    #define ts_assert(expr) ((void) ((expr) ? 0 : (__ts_assert (#expr, __FILE__, __LINE__), 0)))
    void __ts_assert(const char *expr, const char *file, ts_uint32_t line);
#else
    #define ts_assert(expr) do {} while (0)
#endif 

#ifdef __cplusplus
}
#endif

#endif 
