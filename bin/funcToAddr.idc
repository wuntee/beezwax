// Run this IDC script within IDA
// Written by Eric Monti

#include <idc.idc>

static main()
{
  auto entry, fname, outf, fd;
  outf = AskFile(1, "*.txt", "Please select an output file");
  fd = fopen(outf,"w");

  for(entry=NextFunction(0); entry  != BADADDR; entry=NextFunction(entry) )
  {
    fname = GetFunctionName(entry);
    fprintf(fd, "%d,%s,0\n", entry, fname);
  }

  fclose(fd);
}
