class AbstractBeezwaxMonitor
  
  #boolean - returns ture if there was a crash
  def isCrash(executor); raise "Abstract Exception: isCrash must be extended"; end

  def reInitialize; '''Does not have to be implemented'''; end
  
end