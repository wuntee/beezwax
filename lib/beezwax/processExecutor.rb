require 'sys/proctable'

class Beezwax
  class ProcessExecutor < AbstractBeezwaxExecutor
    attr_accessor :executable
    attr_reader :pid, :subject
    
    def initialize(executable)
      @executable = executable
    end
    
    def executeSubject(subject)
      @subject = subject
      exec = "#{@executable} #{@subject.identifyer}"

      @pid = spawn(exec, :err => "/dev/null", :out => "/dev/null")

      # sleep(@timeout)
      # Monitor CPU usage until at 0, then kill
      counter = 0
      while(counter < 100)
        p = Sys::ProcTable.ps(@pid)
        if(p.pctcpu == 0.0)
          counter = counter + 1
        end
        sleep(0.01)
      end
    end
    
    def doAfterMonitor
      Process.kill("KILL", @pid)
      Process.wait(@pid)
    end
  end
end