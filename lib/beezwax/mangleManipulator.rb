class Beezwax
    class MangleManipulator < AbstractBeezwaxManipulator
        attr_accessor :maxIterations, :filpsPerIteration
      
        ADD = ["\xff", "\xfe", "\xff\xff", "\xff\xfe", "\xff\xff", "\xff\xff\xff\xfe"]

        def initialize(seed = Time.now.to_i)
            super(seed)
            @maxIterations = 100
        end

        def filpRandomBit(contents)
            # flip the bits of a random char
            r = @rand.rand(contents.length())
            bin = contents[r].chr().unpack('C*')[0]
            flip = bin ^ 0xff 
            newChar = [flip].pack('C*')
            contents[r] = newChar
            return(contents)
        end

        def removeRandomBit(contents)
            r = @rand.rand(contents.length())
            contents.slice(r)
            return(contents)
        end

        def insertSpecail(contents)
            r = @rand.rand(contents.length())
            b = ADD[@rand.rand(ADD.length)]
            contents.insert(r, b)
            return(contents)
        end

        def insertRandom(contents)
            r = @rand.rand(contents.length())
            b = [@rand.rand(0xff)].pack("C")
            contents.insert(r, b)
            return(contents)
        end
      
        def doManipulation(contents)
            case @rand.rand(4)
            when 0
                return(filpRandomBit(contents))
            when 1
                return(removeRandomBit(contents))
            when 2
                return(insertSpecail(contents))
            when 3
                return(insertRandom(contents))
            end
        end
      
        def shouldReInitialize
            if(@iteration >= @maxIterations)
                return true
            end
            return false
        end
      

    end
end