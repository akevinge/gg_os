#ifndef UTILS_H
#define UTILS_H

#include <uefi.h>

#define RETURN_IF_NULL(ptr, status) \
    if (ptr == NULL)                \
    {                               \
        return status;              \
    }

#define RETURN_AND_LOG_IF_NULL(ptr, status, msg) \
    if (ptr == NULL)                             \
    {                                            \
        fprintf(stderr, msg);                    \
        fflush(stderr);                          \
        return status;                           \
    }

#define RETURN_IF_ERROR(status) \
    if (EFI_ERROR(status))      \
    {                           \
        return status;          \
    }

#define RETURN_AND_LOG_IF_ERROR(status, msg) \
    if (EFI_ERROR(status))                   \
    {                                        \
        fprintf(stderr, msg);                \
        fflush(stderr);                      \
        return status;                       \
    }

#endif // UTILS_H