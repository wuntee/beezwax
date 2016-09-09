base = __FILE__
while File.symlink?(base)
        base = File.expand_path(File.readlink(base), File.dirname(base))
end

$:.unshift(File.join(File.dirname(base), '../lib'))
  
require 'beezwax'

application = "QuickTime Player"
sub = ARGV[0]
seed = ARGV[1].nil? ? Time.now().to_i : ARGV[1].to_i

honeypot = Beezwax::Honeypot.new

subject = Beezwax::FileSubject.new
subject.readFile(sub)
honeypot.subject = subject

#honeypot.manipulator = Beezwax::MangleManipulator.new(seed)
honeypot.manipulator = Beezwax::BitflipManipulator.new(seed)

honeypot.executor = Beezwax::OsxOpenProcessExecutor.new(application)

crashdir = "/Users/#{ENV['USER']}/Library/Logs/DiagnosticReports"
outputdir = "../../crashes/#{application}/"
honeypot.monitor = Beezwax::CrashlogDirectoryMonitor.new(crashdir)
honeypot.processor.push(Beezwax::ProcessKillProcessor.new)
honeypot.processor.push(Beezwax::DirectoryCopierProcessor.new(crashdir, outputdir))
honeypot.processor.push(Beezwax::ClearSystemEventsProcessor.new)
honeypot.processor.push(Beezwax::QuicktimeCrashProcessor.new(subject))
honeypot.processor.push(Beezwax::QuicktimeCrashProcessor.new(subject))

honeypot.fuzz
