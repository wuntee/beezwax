class AbstractBeezwaxSubject
  attr_accessor :identifyer, :contents
  
  def getNewSubjectForManipulator(updatedContents); raise "Abstract Exception: getNewSubjectForManipulator must be extended"; end

end