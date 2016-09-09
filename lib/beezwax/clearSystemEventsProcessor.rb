require 'applescript'

class Beezwax
    class ClearSystemEventsProcessor < AbstractBeezwaxProcessor
      def processCrash
        # This will use applescript to close the "Application quit unexpectedly." window
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