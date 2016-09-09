base = __FILE__
while File.symlink?(base)
        base = File.expand_path(File.readlink(base), File.dirname(base))
end

$:.unshift(File.join(File.dirname(base), '../lib'))
  
require 'beezwax'

honeypot = BeezwaxHoneypot.new

subject = Beezwax::FileSubject.new
subject.readFile("/Users/wuntee/Desktop/test.pdf")
honeypot.subject = subject

honeypot.manipulator = Beezwax::BitflipManipulator.new
honeypot.executor = Beezwax::ProcessExecutor.new('/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome')
honeypot.monitor = Beezwax::CrashlogDirectoryMonitor.new("/Users/#{ENV['USER']}/Library/Application Support/Google/Chrome/Crash Reports", "/Users/wuntee/workspace-ruby/beezwax/crashes/chrome")
honeypot.fuzz