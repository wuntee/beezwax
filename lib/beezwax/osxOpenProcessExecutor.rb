require 'sys/proctable'
require 'pp'
require 'timeout'
require_relative 'mixin/ProcessMixin'

class Beezwax
  class OsxOpenProcessExecutor < AbstractBeezwaxExecutor
    include Beezwax::Mixin::ProcessMixin

    attr_accessor :application, :timeout
    attr_reader :pid, :openPid, :subject
    
    def initialize(application)
      @application = application
      @timeout = 30
    end
    
    def executeSubject(subject)
      @subject = subject
      exec = "open -a '#{@application}' '#{@subject.identifyer}'"

      begin
        # for some reason, this sometimes hangs
        Timeout::timeout(@timeout) {
          @openPid = spawn(exec, :err => "/dev/null", :out => "/dev/null")
        }
      rescue Timeout::Error
        puts "[e] OsxOpenProcessExecutor: Could not spawn process (Timeout occured)"
      end
      
      # Let the process spawn
      sleep(0.1)
      
      begin
        Timeout::timeout(@timeout) {
          @pid = wait_for_pid(@application)
        }
      rescue Timeout::Error
        puts("[e] Could not find pid from process: #{@application} (Timeout occured)")
        return
      end

      if(!@pid.nil?)
        wait_for_stable_cpu(@pid)
        sleep(0.05)
      else
        puts("[e] Could not get pid from process: #{@application}")
      end

    end
    
    def doAfterMonitor
      begin
        Process.kill("TERM", @pid) if !@pid.nil?
      rescue
      end
      begin
        Process.kill("TERM", @openPid) if !@openPid.nil?
      rescue
      end
      begin
        Process.wait(@pid)
      rescue Exception => e
      end
      begin
        Process.wait(@openPid)
      rescue Exception => e
      end
    end

  end
end