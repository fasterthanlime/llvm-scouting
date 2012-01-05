#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
   char *s1 = "hello ";
   int l1 = 7;
   char *s2 = "world";
   int l2 = 6;

   int l3 = l1 + l2 + 1;
   char *s3 = malloc(l3);
   strncpy(s3, s1, l1);
   strncat(s3, s2, l3);
   puts(s3);
}

