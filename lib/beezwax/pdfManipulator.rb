class Beezwax
  class PdfManipulator < AbstractBeezwaxManipulator
    attr_accessor :maxIterations, :flipsPerIteration, :grammer, :debug, :iteration
    INTERESTING_NUMBER = [
      "",
      "\0",
      "0",
      "1",
      "-0",
      "00",
      "-1",
      "-0.1",
      "0.1",
      "0.999",
      "0.001",
      "0.0000000000000000000001",
      ">>",
      "<<",
      "wuntee",
      "32766",
      "32767",
      "-32766",
      "-32767",
      "65535",
      "-65535",
      "65536",
      "-65536",
      "2147483646",
      "2147483647",
      "-2147483647", 
      "-2147483648", 
      "4294967295",
      "-4294967295",
      "4294967296",
      "-4294967296"
      ]

    def initialize(seed = Time.now.to_i)
      super(seed)
      @maxIterations = 100
      @flipsPerIteration = 10
      @grammer = Array.new
      @debug = false
    end
    
    def processSubject(subject)
      subject.contents.split(/\n/).each do |line|
        line.split(/ /).each do |word|
          if(word.match(/^\//) and @grammer.index(word) == nil)
            @grammer.push(word)
            @debug and puts("Adding word: #{word}")
          end
        end
      end
    end

    def shouldReInitialize
      if(@iteration >= @maxIterations)
        return true
      end
      return false
    end


    def flipRandomBit(contents)
      (1..@rand.rand(@flipsPerIteration)).each do |x|
        # flip the bits of a random char
        r = @rand.rand(contents.length())  
        bin = contents[r].chr().unpack('C*')[0]
        flip = bin ^ 0xff 
        newChar = [flip].pack('C*')
        contents[r] = newChar
      end
      return(contents)
    end

    def doManipulation(contents)
      # Find random ojbect in the contents
      splitContents = contents.split(/ /, -1)
      randIndex = @rand.rand(splitContents.length)
      obj = splitContents[randIndex]
      while(obj.match(/^[a-zA-Z]$/) or obj.length == 0)
        randIndex = @rand.rand(splitContents.length)
        obj = splitContents[randIndex]
      end

      @debug and puts("object: #{obj}")
      # It is a grammer object, replace with a random grammer object
      if(obj.match(/^\//))
        splitContents[randIndex] = @grammer[@rand.rand(@grammer.length)]
      # If its a number
      elsif(obj.match(/^\d+$/))
        if(@rand.rand(2) == 1)
          newContents = INTERESTING_NUMBER[@rand.rand(INTERESTING_NUMBER.length)]
          splitContents[randIndex] = newContents
          @debug and puts("Changing number (#{obj} -> #{newContents})")
        else
          newContents = @rand.rand(100)
          splitContents[randIndex] = 
          @debug and puts("Changing number (#{obj} -> #{newContents})")
        end
      elsif(obj == ">>")
        if(@rand.rand(2) == 1)
          splitContents[randIndex] = "<<"
          @debug and puts("Flipping '>>' to '<<'")
        end
      elsif(obj == "<<")
        if(@rand.rand(2) == 1)
          splitContents[randIndex] = ">>"
          @debug and puts("Flipping '<<' to '>>'")
        end
      else
        splitContents[randIndex] = flipRandomBit(obj)
        @debug and puts("Flipping random bit")
      end
      return(splitContents.join(" "))
    end
    
  end
end