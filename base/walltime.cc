// The implementation of walltime functionalities.
#ifndef _GNU_SOURCE   // gcc3 at least defines it on the command line
#define _GNU_SOURCE   // Linux wants that for strptime in time.h
#endif

#define __STDC_FORMAT_MACROS 1

#include <atomic>
#include <csignal>
#include "base/walltime.h"
#include "base/logging.h"
#include "base/pthread_utils.h"

#include <sys/timerfd.h>
#include <cstdio>


namespace base {

void SleepMillis(uint32 milliseconds) {
 // Sleep for a few milliseconds
 struct timespec sleep_time;
 sleep_time.tv_sec = milliseconds / 1000;
 sleep_time.tv_nsec = (milliseconds % 1000) * 1000000;
 while (nanosleep(&sleep_time, &sleep_time) != 0 && errno == EINTR)
   ;  // Ignore signals and wait for the full interval to elapse.
}


static std::atomic<uint64_t> ms_long_counter = ATOMIC_VAR_INIT(0);
static std::atomic_int timer_fd = ATOMIC_VAR_INIT(-1);

static pthread_t timer_thread_id = 0;

static void* UpdateMsCounter(void*) {
  CHECK_EQ(0, pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, nullptr));
  int fd;
  uint64 missed;

  while ((fd = timer_fd.load(std::memory_order_relaxed)) > 0) {
    int ret = read(fd, &missed, sizeof missed);
    DCHECK_EQ(8, ret);
    ms_long_counter.fetch_add(missed, std::memory_order_release);
  }
  return nullptr;
}

void SetupJiffiesTimer() {
  if (timer_thread_id)
    return;

  timer_fd = timerfd_create(CLOCK_MONOTONIC, TFD_CLOEXEC);
  CHECK_GT(timer_fd, 0);
  struct itimerspec its;

  its.it_value.tv_sec = 0;
  its.it_value.tv_nsec = 100000;  // The first expiration in 0.1ms.

  // Setup periodic timer of the same interval.
  its.it_interval.tv_sec = its.it_value.tv_sec;
  its.it_interval.tv_nsec = its.it_value.tv_nsec;

  CHECK_EQ(0, timerfd_settime(timer_fd, 0, &its, NULL));
  timer_thread_id = base::StartThread("MsTimer", &UpdateMsCounter, nullptr);
  struct sched_param sparam;
  sparam.sched_priority = 1;

  pthread_setschedparam(timer_thread_id, SCHED_FIFO, &sparam);
}

void SleepMicros(uint32 usec) {
  struct timespec sleep_time;
  sleep_time.tv_sec = usec / kNumMicrosPerSecond;
  sleep_time.tv_nsec = (usec % kNumMicrosPerSecond) * 1000;
  while (nanosleep(&sleep_time, &sleep_time) != 0 && errno == EINTR) {}
}

void DestroyJiffiesTimer() {
  if (!timer_thread_id) return;

  int fd = timer_fd.exchange(0);
  pthread_join(timer_thread_id, nullptr);

  timer_thread_id = 0;
  CHECK_EQ(0, close(fd));
}

uint64 GetMonotonicJiffies() {
  return ms_long_counter.load(std::memory_order_acquire);
}

uint64 GetMonotonicMicrosFast() {
  return ms_long_counter.load(std::memory_order_acquire) * 100;
}

}  // namespace base
