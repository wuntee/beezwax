class AbstractBeezwaxProcessor
    attr_accessor :executor, :manipulator, :monitor, :subject
    
    #void - if there was a crash, this will process it. ex: copy crash logs
    def processCrash; raise "Abstract Exception: AbstractBeezwaxCrashProcessor.processCrash must be extended"; end

end