#pragma D option quiet
profile:::profile-1001hz
/pid == $pid/ 
{
    @pc[arg1] = count();
}
dtrace:::END
{
   printa("OUT: %A %@d\n", @pc);
}