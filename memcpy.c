#include <string.h>
#include <stdatomic.h>
#include "caml/mlvalues.h"

void hector_memcpy (
  volatile value* const dst,
  volatile const value* const src,
  mlsize_t nvals
)
{
  atomic_thread_fence(memory_order_acquire);
  memcpy ((value*) dst, (value*) src, nvals * sizeof(value));
}
