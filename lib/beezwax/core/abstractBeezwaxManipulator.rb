require 'colorize'

class AbstractBeezwaxManipulator
  attr_reader :rand, :seed, :iteration
  
  # returns a new AbstractBeezwaxSubject 
  # passes the current subject
  def doManipulation(contents); raise "Abstract Exception: doManipulation must be extended"; end
  
  # can optionally be used to reinitialize the manipulator
  def shouldReInitialize
    return(false)
  end
  
  def initialize(seed = Time.now.to_i)
    @seed = seed
    @iteration = 0
    @rand = Random.new(@seed)
    puts("Initializing manipulator. (Seed: #{@seed})".blue)
  end
  
  def reInitialize
    @seed = Time.now.to_i
    @iteration = 0    
    @rand = Random.new(@seed)
    puts("Reinitializing manipulator. (Seed: #{@seed})".blue)
  end
 
  # returns next manipulation subject
  def getNextManipulation(subject)
    print("Iteration: #{@iteration}\r".blue)
    newContents = doManipulation(subject.contents.clone)
    @iteration += 1
    return(subject.getNewSubjectForManipulator(newContents))
  end
    
  def getArbitraryManipulation(base_subject, iteration)
    # perform manipulation unitl we have reached one under iteration
    while(@iteration < iteration)
      base_subject = getNextManipulation(base_subject)
    end
    # return the next manipulation, which should be index iteration
    return(base_subject)
  end
    
end