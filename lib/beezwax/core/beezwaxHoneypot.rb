class Beezwax
    class Honeypot
    attr_accessor :executor, :manipulator, :monitor, :subject, :processor, :restIteration
    attr_reader :originalSubject

    def initialize
      @processor = []
    end
    
    #make sure everything has been initialized
    def sanityCheck
      @executor.nil? and raise "Executor has not been initialized."
      @manipulator.nil? and raise "Manipulator has not been initialized."
      @monitor.nil? and raise "Monitor has not been initialized."
      @subject.nil? and raise "Subject has not been initialized."
    end
    
    #must set all accessors first 
    def fuzz
      sanityCheck

      @originalSubject = @subject.clone

      @currentSubject = @subject.clone
      
      while(1 == 1) do
        @currentSubject = @manipulator.getNextManipulation(@currentSubject)      
        @executor.executeSubject(@currentSubject)

        if(@monitor.isCrash(@executor))
          puts("Processing crash\n".red +
                "\tsubject: #{@subject.identifyer}\n" +
                "\tseed: #{@manipulator.seed}\n" +
                "\titeration:#{@manipulator.iteration}\n")
          
          @processor.each do |p|
            p.executor = @executor
            p.manipulator = @manipulator
            p.monitor = @monitor
            p.subject = @subject
            p.processCrash
          end
          
          @currentSubject = @originalSubject.clone
          @manipulator.reInitialize
          @monitor.reInitialize
        end

        @executor.doAfterMonitor
        
        if(@manipulator.shouldReInitialize)
          puts("Reinitialization threshold reached".blue)
          @currentSubject = @originalSubject.clone
          @manipulator.reInitialize
          
        end      
      end
    end

    def getSubjectForTestCase(iteration)
      @originalSubject = @subject.clone
      @currentSubject = @subject.clone
      while(@manipulator.iteration < iteration) do
        @currentSubject = @manipulator.getNextManipulation(@currentSubject)      
      end
      return(@currentSubject)
    end
    
  end
end