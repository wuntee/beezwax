class Beezwax
    class Mixin
        module ProcessMixin
            def wait_for_pid(process, sleep=0.1)
                pid = nil
                while(pid.nil?)
                    pid = pid_from_process(process)
                    sleep(sleep)
                end
                return(pid)
            end

            def pid_from_process(process)
                proc_name = process.rindex("/") ? process[process.rindex("/")+1..-1] : process
                
                Sys::ProcTable.ps.each do |p|
                    #if(p.cmdline =~ /\/#{process}$/ or p.cmdline =~ /\/#{process} /)
                    if (p.comm =~ /^#{proc_name}/)
                        return p.pid
                    end
                end
                return(nil)
            end

            def wait_for_stable_cpu(pid, count=30)
                $DEBUG and puts("wait_for_stable_cpu. pid: #{pid}")
                $DEBUG and puts(`ps -ef | grep #{pid}`)

                counter = 0
                previous_p = 0
                while(counter < count)
                    #p = Sys::ProcTable.ps(pid)
                    p = `ps -o rss= -p #{pid}`.to_i
                    $DEBUG and puts "#{p} = #{previous_p}"
                    if(p == previous_p)
                        counter = counter + 1
                    else
                        couter = 0
                    end
                    sleep(0.1)
                    previous_p = p
                end
                $DEBUG and puts("Pid was stable, count: #{counter}")
            end            

            def wait_for_pid_to_crash(pid, sleep=0.1)
                while(Sys::ProcTable.ps(pid))
                    sleep(sleep)
                end
            end
        end

    end
end