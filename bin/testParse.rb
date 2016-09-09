require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: osxOpenFileFuzzer.rb [options]"

  opts.on("-o", "--output-dir DIRECTORY", "Output directory for crash cases and crashlogs.") do |v|
    options[:output] = v
  end

  opts.on("-s", "--subject FILENAME", "The base subject to fuzz.") do |v|
    options[:subject] = v
  end

  opts.on("-a", "--application APPLICATION", "The Application you want to 'open' when fuzzing.") do |v|
    options[:application] = v
  end
end.parse!

p options
p ARGV