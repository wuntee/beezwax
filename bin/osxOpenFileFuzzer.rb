base = __FILE__
while File.symlink?(base)
        base = File.expand_path(File.readlink(base), File.dirname(base))
end

$:.unshift(File.join(File.dirname(base), '../lib'))
  
require 'beezwax'
require 'optparse'

options = {:output => "."}
OptionParser.new do |opts|
  opts.banner = "Usage: osxOpenFileFuzzer.rb [options]"

  opts.on("-o", "--output-dir DIRECTORY", "Output directory for crash cases and crashlogs.") do |v|
    options[:output] = v
  end

  opts.on("-s", "--subject FILENAME", "The base subject to fuzz.") do |v|
    options[:subject] = v
  end

  opts.on("-a", "--application APPLICATION", "The Application binary you want to 'open' when fuzzing. If using crashwrangler option, this must be the full path to the binary, not just something like 'Microsoft Word'.") do |v|
    options[:application] = v
  end
  
  opts.on("-e", "--seed SEED", "The optional seed you want to initialize the random number generator with.") do |v|
    options[:seed] = v
  end  

  opts.on("-g", "--get-iteration ITERATION", "Get the specific iteration file of the specific SEED without actually running the fuzzer.") do |v|
    options[:iteration] = v.to_i
  end

  opts.on("-c", "--crash-wrangler DIR", "Base directory for the crashwrangler tool from Apple. This will post process the execution using 'exc_handler'.") do |v|
    options[:cw] = v
  end

end.parse!

application = options[:application]
sub = options[:subject]
seed = options[:seed].nil? ? Random.rand(9999999999) : options[:seed].to_i
crashdir = "/Users/#{ENV['USER']}/Library/Logs/DiagnosticReports"
!application.nil? and outputdir = "#{options[:output]}/#{application[application.rindex("/")+1..-1].gsub(' ','_')}/"

honeypot = Beezwax::Honeypot.new

subject = Beezwax::FileSubject.new
subject.readFile(sub)

honeypot.subject = subject
honeypot.manipulator = Beezwax::BitflipManipulator.new(seed)

$DEBUG = false

if(options[:iteration])
  subject = honeypot.manipulator.getArbitraryManipulation(subject, options[:iteration])
  extension = File.extname(sub)
  basename = File.basename(sub, extension)
  output_filename = "#{basename}-#{seed}-#{options[:iteration]}#{extension}"
  f = File.open(output_filename, "w")
  f.write(subject.contents)
  f.close
  puts("File written: #{output_filename}")
else
  honeypot.executor = Beezwax::OsxOpenProcessExecutor.new(application)
  honeypot.monitor = Beezwax::CrashlogDirectoryMonitor.new(crashdir)
  honeypot.processor.push(Beezwax::DirectoryCopierProcessor.new(crashdir, outputdir))
  honeypot.processor.push(Beezwax::ClearSystemEventsProcessor.new)

  if(options[:cw])
    honeypot.processor.push(Beezwax::Processor::CrashWranglerProcessor.new(options[:cw], outputdir))
  end

  honeypot.fuzz
end