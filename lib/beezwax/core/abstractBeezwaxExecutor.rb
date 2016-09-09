class AbstractBeezwaxExecutor
  
    def executeSubject(subject); raise "Abstract Exception: executeSubject must be extended"; end
    
    def doAfterMonitor; raise "Abstract Exception: doAfterMonitor must be extended"; end

end