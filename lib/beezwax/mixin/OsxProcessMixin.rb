require 'applescript'

class Beezwax
    class Mixin
        module OsxProcessMixin
            def open_file(application, file)
                begin
                    as = 'tell application "' + application + '" to open "' + file + '"'
                    $DEBUG and puts("Executing applescript: #{as}")
                    AppleScript.execute(as)
                rescue Exception => e
                    puts("Could not open file: #{e}")
                end
            end

            def clear_system_event
                begin
                    AppleScript.execute('tell application "System Events"
                tell application process "UserNotificationCenter"
                    click button "Ignore" of window 1
                end tell
            end tell')
                rescue Exception => e
                    puts("Could not clear crash dialog: #{e}")
                end
            end
        end
    end
end