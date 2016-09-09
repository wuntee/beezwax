class Beezwax
  class ProcessKillProcessor < AbstractBeezwaxProcessor
    def processCrash
      begin
        Process.kill("TERM", @executor.pid) if !@executor.pid.nil?
      rescue
      end
      begin
        Process.kill("TERM", @executor.openPid) if !@executor.openPid.nil?
      rescue
      end
      begin
        Process.wait(@executor.pid)
      rescue Exception => e
      end
      begin
        Process.wait(@executor.openPid)
      rescue Exception => e
      end
    end
  end
end