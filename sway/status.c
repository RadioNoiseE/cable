#define _POSIX_C_SOURCE 200112L
#include <stdio.h>
#include <time.h>

int main(void) {
  char date[64];
  FILE *node;
  int battery;
  int carrier;

  struct timespec now;

  clock_gettime(CLOCK_REALTIME, &now);
  now.tv_sec += 1;
  now.tv_nsec = 0;

  for (;;) {
    clock_nanosleep(CLOCK_REALTIME, TIMER_ABSTIME, &now, NULL);

    strftime(date, sizeof(date), "%a %b %d %T", localtime(&now.tv_sec));

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

    now.tv_sec++;
  }
}
