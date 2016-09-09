base = __FILE__
while File.symlink?(base)
        base = File.expand_path(File.readlink(base), File.dirname(base))
end

$:.unshift(File.join(File.dirname(base), '../lib'))
  
require 'beezwax'

binary = ARGV[0]
sub = ARGV[1]

honeypot = Beezwax::Honeypot.new

subject = Beezwax::FileSubject.new
subject.readFile(sub)
honeypot.subject = subject

manipulator = Beezwax::PdfManipulator.new(1357959632)
manipulator.processSubject(subject)
honeypot.manipulator = manipulator

honeypot.executor = Beezwax::ProcessExecutor.new(binary)
honeypot.executor.timeout = 2
#honeypot.monitor = Beezwax::CrashlogDirectoryMonitor.new("/Users/#{ENV['USER']}/Library/Logs/CrashReporter", "../crashes/safari")
honeypot.monitor = Beezwax::CrashlogDirectoryMonitor.new("/Users/#{ENV['USER']}/Library/Logs/DiagnosticReports", "../crashes/safari")

#honeypot.monitor = Beezwax::ProcessMonitor.new
#honeypot.monitor = Beezwax::CrashlogDirectoryMonitor.new("/Users/#{ENV['USER']}/Library/Application Support/Google/Chrome/Crash Reports", "../crashes/chrome")

honeypot.fuzz
