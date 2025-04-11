// kernel.c

void print(const char* str) {
  volatile char* video = (char*)0xB8000;
  while (*str) {
    *video++ = *str++;
    *video++ = 0x07;
  }
}

void kernel() {
  print("Hola desde C alfin");

  while (1) {
    __asm__("hlt");
  }
}
