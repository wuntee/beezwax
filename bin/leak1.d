#!/usr/sbin/dtrace -s

/* leak1.d */
#pragma D option quiet

pid$target:libc:malloc:entry
{
    self->nbytes = arg0;
}

pid$target:libc:malloc:return
/self->nbytes/
{
    printf("%s: allocated %d bytes at address %lx\n",
      probefunc, self->nbytes, arg1);
    self->nbytes = 0;
}

pid$target:libc:free:entry
{
    printf("%s: freeing space at address %lx\n", probefunc, arg0);
}