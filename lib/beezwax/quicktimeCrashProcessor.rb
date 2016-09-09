require 'applescript'

class Beezwax
    class QuicktimeCrashProcessor < AbstractBeezwaxProcessor
        attr_accessor :subject
        def initialize(subject)
            @subject = subject
        end

        def processCrash
        # This will use applescript to close the 
        # "The last time you opened QuickTime Player, it unexpectedly quit while reopening windows. Do you want to try to reopen its windows again?" 
        # window
        @openPid = spawn("open -a 'QuickTime Player' '#{@subject}'", :err => "/dev/null", :out => "/dev/null")
        sleep 1
        
        begin
            AppleScript.execute('tell application "System Events"
        tell application process "QuickTime Player"
            click button "Don' << "\u2019" << 't Reopen" of window 1
        end tell
    end tell')
        rescue
        end

        Process.kill("TERM", @openPid) if !@openPid.nil?
        begin
          Process.wait(@openPid)
        rescue Exception => e
        end


      end
    end
end