base = __FILE__
while File.symlink?(base)
        base = File.expand_path(File.readlink(base), File.dirname(base))
end

$:.unshift(File.join(File.dirname(base), '../lib'))

require 'applescript'
require 'beezwax'
require 'pp'

application = "/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player"

begin
    gdb = Beezwax::Gdb::Wrapper.new(application, "/usr/bin/gdb")
    broke = []
    puts("[info] Loading functions")
    functions = gdb.getFunctions
    puts("[info] Setting breakpoints")

    functions.values.uniq.each do |f|
        #puts("Adding breakpoint: #{f}")
        gdb.setTemporaryBreakpoint(f)
    end

    gdb.onBreak do |addr, function|
        #puts("Broke at: #{function}")

        broke.push(addr)
    end

    gdb.onSignal do |sig, desc|
        puts("#{broke.size}/#{functions.size}")
    end

    puts("[info] Running application")
    thread = gdb.runBackground
    puts("[info] After runBackground")

    puts("[info] Sleeping")
    sleep(5)
    #gdb.DEBUG = false

    puts("[info] Opening file")
    out = AppleScript.execute('
        tell application "System Events"
            tell application process "QuickTime Player"
                open "' << Dir.pwd << '/../subjects/qclp/qtaudio-qcelp-problem.3g2"
            end tell
        end tell')
    puts("[info] File open output: #{out}")
    puts(Time.now)
    puts("[info] before thread.join")
    thread.join(600)
    puts(Time.now)
    puts("[info] after thread.join")
    puts("\n\n#{broke.size}/#{functions.size}")
    gdb.DEBUG = true
    gdb.sendInt
    gdb.kill


rescue Interrupt
    puts("\n\n#{broke.size}/#{functions.size}")
end