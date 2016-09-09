#!/usr/bin/env ruby

require 'rubygems'
require 'ragweed'
require 'pp'
require 'sys/proctable'

class Test < Ragweed::Debuggerosx
  def on_signal(sig)
  	super(sig)
    puts("SIGNAL: #{sig}")
  end

  def on_exit(code)
  	super(code)
  	puts("EXIT: #{code}")
  end

  # override to use rip instead of eip
  def wait(opts = 0)
    r = Ragweed::Wraposx::waitpid(@pid,opts)
    status = r[1]
    wstatus = status & 0x7f
    signal = status >> 8
    found = false
    if r[0] != 0 #r[0] == 0 iff wait had nothing to report and NOHANG option was passed
      case
      when wstatus == 0 #WIFEXITED
        @exited = true
        try(:on_exit, signal)
      when wstatus != 0x7f #WIFSIGNALED
        @exited = false
        try(:on_signaled, wstatus)
      when signal != 0x13 #WIFSTOPPED
        self.threads.each do |t|
          if @breakpoints.has_key?(self.get_registers(t).rip-1)
            found = true
            try(:on_breakpoint, t)
          end
        end
        if not found # no breakpoint so iterate through Signal constants to find the current SIG
          Signal.list.each do |sig, val|
            try("on_sig#{ sig.downcase }".intern) if signal == val
          end
        end
        try(:on_stop, signal)
        begin
          self.continue
        rescue Errno::EBUSY
          # Yes this happens and it's wierd
          # Not sure it should happen
          if $DEBUG
            puts 'unable to self.continue'
            puts self.get_registers
          end
        retry
        end
      when signal == 0x13 #WIFCONTINUED
        try(:on_continue)
      else
        raise "Unknown signal '#{signal}' recieved: This should not happen - ever."
      end
    end
    return r
  end

  # override to use rip instead of eip
  def on_breakpoint(thread)
    r = self.get_registers(thread)
    # rewind rip to correct position
    r.rip -= 1
    # don't use r.rip since it may be changed by breakpoint callback
    rip = r.rip
    # clear stuff set by INT3
    # r.esp -=4
    # r.ebp = r.esp
    # fire callback
    puts("BREAKPOINT!")
    @breakpoints[rip].call(thread, r, self)
    if @breakpoints[rip].first.installed?
      # uninstall breakpoint to continue past it
      @breakpoints[rip].first.uninstall
      # set trap flag so we don't go too far before reinserting breakpoint
      r.eflags |= (Ragweed::Wraposx::EFlags::TRAP << 32)
      # set registers to commit rip and eflags changes
      self.set_registers(thread, r)

      # step once
      self.stepp

      # now we wait() to prevent a race condition that'll SIGBUS us
      # Yup, a race condition where the child may not complete a single 
      # instruction before the parent completes many
      Ragweed::Wraposx::waitpid(@pid,0)

      # reset the breakpoint
      @breakpoints[rip].first.install
    end
  end

  def base_address
    return(self.region_info(0).base_address)
  end

  def breakpoint_set_relative(addr, name="", callable=nil, &block)
    self.breakpoint_set(self.base_address + addr, name, callable, block)
  end
end


def pidFromProcess(process)
  Sys::ProcTable.ps.each do |p|
    #if(p.cmdline =~ /\/#{process}$/ or p.cmdline =~ /\/#{process} /)
    if(p.comm =~ /^#{process}/)
      puts(p.cmdline)
      return(p.pid)
    end
  end
  return(nil)
end

pid = pidFromProcess(ARGV[0])
#pid =  spawn(ARGV[0], :err => "/dev/null", :out => "/dev/null")
puts("PID: #{pid}")
x = Test.new(pid)
x.attach
base = x.base_address
puts("Base addr: 0x#{x.base_address.to_s(16)}")

bp_file = File.open(ARGV[1])
bp_file.each_line do |l|
  addr, function, zero = l.split(",").map{|m| m.strip}
  addr = (addr.to_i & 0x0FFFFFFFF) + base                 # IDA seems to give ADDR withought ASLR
  puts("Adding bp[0x#{addr.to_s(16)} : #{addr}, #{function}]")
  x.breakpoint_set(addr, function, (bpl = lambda do | thread, regs, slf |
    puts "#{slf.breakpoints[regs.rip].first.function} hit in thread #{thread}\n"
  end))
end
puts("installing")
x.install_bps
puts("installed")
x.continue
puts("loop")
x.loop
puts("Killing")
Process.kill("HUP", pid)
