#pragma once

#include <sys/time.h>

#include <string>

#include "base/integral_types.h"

namespace base {

typedef int64 MicrosecondsInt64;


// Time conversion utilities.
static constexpr MicrosecondsInt64 kNumMillisPerSecond = 1000LL;

static constexpr MicrosecondsInt64 kNumMicrosPerMilli = 1000LL;
static constexpr MicrosecondsInt64 kNumMicrosPerSecond = kNumMicrosPerMilli * 1000LL;

inline MicrosecondsInt64 ToMicros(const timespec& ts) {
  return ts.tv_sec * kNumMicrosPerSecond + ts.tv_nsec / 1000;
}

void SleepMicros(uint32 usec);
void SleepMillis(uint32 milliseconds);


// Sets up 100usec precision fast timer.
void SetupJiffiesTimer();
void DestroyJiffiesTimer();

// Thread-safe. Very fast 100 microsecond precision monotonic clock.
uint64 GetMonotonicMicrosFast();

}  // namespace base
