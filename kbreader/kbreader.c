#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/input.h>
#include "_keymap.c"

static struct input_event ev;
int main(int argc, char* argv[]) {
  if(argc < 2) return -1;
  setbuf(stdout, NULL);
  int fd = open(argv[1], O_RDONLY);
  if(fd < 0) {
    perror("[kbreader] Couldn't open event device.");
    return -1;
  }
  while(1) {
    ssize_t n = read(fd, &ev, sizeof(ev));
    if (n != sizeof(ev)) {
      perror("[kbreader] Bad event read.");
      return -1;
    }
    if(!(ev.type == EV_KEY)) continue; 
    else if(ev.value == 1 || ev.value == 2) {
      kbreader_chseq kca = *kbreader_key_press((unsigned int) ev.code);
      char *ca = (char *) kca.ca;
      for(unsigned int i=0; i<kca.len; i++) {
	char c = *(ca++);
	if(c != putchar(c)) {
	  perror("[kbreader] Bad char print.");
	  return -1;
	}
      }
    }
    else if(ev.value == 0) kbreader_key_release((unsigned int) ev.code);
  }
  close(fd);
  return 0;
}
