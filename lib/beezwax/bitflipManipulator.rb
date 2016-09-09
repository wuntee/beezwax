class Beezwax
  class BitflipManipulator < AbstractBeezwaxManipulator
    attr_accessor :maxIterations, :filpsPerIteration
    
    def initialize(seed = Random.rand(9999999999))
      super(seed)
      @maxIterations = 100
      @filpsPerIteration = 10
    end
      
    def filpRandomBit(contents)
      (1..@rand.rand(@filpsPerIteration)).each do |x|
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
      return(filpRandomBit(contents))
    end
    
    def shouldReInitialize
      if(@iteration >= @maxIterations)
        return true
      end
      return false
    end
    

  end
end