#define _POSIX_C_SOURCE 200112L
#include <stdio.h>
#include <time.h>

int main(void) {
  char date[64];
  FILE *node;
  int battery;
  int carrier;

  struct timespec wake;

  clock_gettime(CLOCK_MONOTONIC, &wake);
  wake.tv_sec += 1;
  wake.tv_nsec = 0;

  for (;;) {
    clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &wake, NULL);

    time_t now = time(NULL);
    strftime(date, sizeof(date), "%a %b %d %T", localtime(&now));

    if ((node = fopen("/sys/class/power_supply/BAT0/capacity", "r"))) {
      fscanf(node, "%d", &battery);
      fclose(node);
    }

    if ((node = fopen("/sys/class/net/wlan0/carrier", "r"))) {
      fscanf(node, "%d", &carrier);
      fclose(node);
    }

    printf("%s (Pwr %d, Car %d)\n", date, battery, carrier);
    fflush(stdout);

    wake.tv_sec++;
  }
}
