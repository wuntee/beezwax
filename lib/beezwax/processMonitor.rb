require 'sys/proctable'
include Sys

class Beezwax
    class ProcessMonitor < AbstractBeezwaxMonitor
    	def isCrash(executor)
    		return(!isProcessAlive(executor.pid))
    	end


    	def isProcessAlive(pid)
            ProcTable.ps.each do |p|
            	'''
                    if(p.cmdline =~ /#{@process}/)
                            return(true)
                    end
                '''
                if(p.pid == pid)
                	return(true)
                end

            end
            return(false)
    	end

    end

end