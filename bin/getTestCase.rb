base = __FILE__
while File.symlink?(base)
        base = File.expand_path(File.readlink(base), File.dirname(base))
end

$:.unshift(File.join(File.dirname(base), '../lib'))
  
require 'beezwax'

sub = ARGV[0]
seed = ARGV[1].to_i
iteration = ARGV[2].to_i

honeypot = Beezwax::Honeypot.new

subject = Beezwax::FileSubject.new
subject.readFile(sub)
honeypot.subject = subject

manipulator = Beezwax::PdfManipulator.new(seed.to_i)
manipulator.processSubject(subject)
honeypot.manipulator = manipulator

testCase = honeypot.getSubjectForTestCase(iteration)
`cp #{testCase.identifyer} .`
