require 'applescript'
require 'timeout'
require_relative '../mixin/ProcessMixin'
require_relative '../mixin/OsxProcessMixin'

class Beezwax
    class Processor
        class CrashWranglerProcessor < AbstractBeezwaxProcessor
            include Beezwax::Mixin::ProcessMixin
            include Beezwax::Mixin::OsxProcessMixin

            attr_accessor :crashwrangler, :crashlog_dir

            EXEC_HANDLER = "exc_handler"

            def initialize(crashwrangler_dir, crashlog_dir)
                @crashwrangler = crashwrangler_dir
                @crashlog_dir = crashlog_dir
                !File.exists?("#{crashwrangler_dir}/#{EXEC_HANDLER}") and throw "CrashWrangler directory is incorrect, it does not contain 'exc_handler'."
            end

            def processCrash
                subject = @executor.subject.identifyer

                cw_binary = "#{@crashwrangler}/#{EXEC_HANDLER}"
                application_name = @executor.application.rindex("/") ? @executor.application[@executor.application.rindex("/")+1..-1] : @executor.application
                Dir.mktmpdir { |dir|
                    env_vars = {"CW_LOG_DIR" => dir,
                                "CW_CURRENT_CASE" => "crashwrangler-seed-#{@manipulator.seed}.iteration-#{@manipulator.iteration}", 
                                "CW_USE_GMAL" => "0"
                            }
                    spawn(env_vars, "#{cw_binary} '#{@executor.application}'")
                    
                    # Wait for the app to launch
                    sleep(0.5)

                    pid = wait_for_pid(application_name)
                    wait_for_stable_cpu(pid)

                    begin
                        Timeout::timeout(5) {
                            # This should cause the application to crash - if not, wait for a specific tiemout
                            open_file(application_name, subject)
                        }
                    rescue Timeout::Error
                        puts("[i] The test case did not cause a crash when attempting with crashwrangler (Timedout waiting).")
                        return
                    end

                    destination = @crashlog_dir + "/seed-#{@manipulator.seed}.iteration-#{@manipulator.iteration}"
                    FileUtils.mkdir_p(destination)
                    FileUtils.cp_r(Dir["#{dir}/*"], destination)

                    sleep(0.1)
                    clear_system_event
                    sleep(0.5)
                }
            end
        end
    end
end