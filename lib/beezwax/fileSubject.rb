require 'tempfile'

class Beezwax
  class FileSubject < AbstractBeezwaxSubject
    attr_accessor :extension, :identifyer, :base, :file
   
    def readFile(filename)
      @extension = filename[filename.rindex('.')..-1]
      @identifyer = filename
      @base = File.basename(filename)
      f = File.new(filename, "rb")
      @contents = f.read;
      f.close
    end
      
    def getNewSubjectForManipulator(updatedContents)
      f = Tempfile.new([@base, @extension])
      tempfilename = f.path
      f.write(updatedContents)
      f.close

      ret = Beezwax::FileSubject.new
      ret.file = f
      ret.identifyer = tempfilename
      ret.contents = updatedContents
      ret.extension = @extension
      ret.base = File.basename(@base)
      
      return(ret)
    end

  end
end