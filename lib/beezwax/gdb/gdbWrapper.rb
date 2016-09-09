class Beezwax
    class Gdb
        class Frame
            attr_accessor :address, :function
        end

        class Wrapper
            attr_accessor :DEBUG, :onSignal, :onBreak

            PROMPT = "(gdb) "

            def initialize(process, gdb="gdb")
                @gdb = IO.popen("#{gdb} -n -q '#{process}' 2>&1", "r+")
                readToPrompt
            end

            def readToPrompt
                ret = ""
                @DEBUG and puts("[GDB output start]")
                while(reader = IO.select([@gdb]))
                    c = @gdb.read(1)
                    ret << c
                    @DEBUG and print(c)
                    if(ret.end_with?(PROMPT))
                        ret = ret.slice(0, ret.size-PROMPT.size)
                        processDebuggerOutput(ret)
                        @DEBUG and puts("[GDB output end]")
                        return(ret)
                    end
                end
            end

            def sendCommand(command)
                @DEBUG and puts "(gdb) #{command}"
                @gdb.write("#{command}\n")
                return(readToPrompt)
            end

            def getFunctions(filter = nil)
                output = sendCommand("info functions #{filter}")
                ret = {}
                output = output.slice(output.index("0x"), output.length)
                output.split("\n").each do |line|
                    func, addr = line.split(" ", 2)
                    ret[func] = addr
                end

                return(ret)
            end

            def setBreakpoint(addrOrFunction)
                return(sendCommand("break *#{addrOrFunction}"))
            end

            def setTemporaryBreakpoint(addrOrFunction)
                return(sendCommand("tbreak *#{addrOrFunction}"))
            end

            def sendInt
                Process.kill("INT", @gdb.pid)
            end

            def onBreak(*args, &block)
                if block_given?
                    @onBreak = block
                else
                    @onBreak.call(*args) if @onBreak
                end
            end

            def onSignal(*args, &block)
                if block_given?
                    @onSignal = block
                else
                    @onSignal.call(*args) if @onSignal
                end
            end

            def runBackground
                t = Thread.new {
                    runForeground
                }
                return(t)
            end

            def runForeground
                sendCommand("run")
                while(true)
                    continue()
                end
            end

            def processDebuggerOutput(output)
                signalRegex = /Program received signal (\S+),(.*)\n/
                breakpointRegex = /Breakpoint.*, (.*) in (.*) \(/
                if(output.match(signalRegex))
                    @DEBUG and puts("GDB output matches signal regex")
                    signal, description = output.match(signalRegex).captures
                    onSignal(signal, description)
                elsif(output.match(breakpointRegex))
                    @DEBUG and puts("GDB output matches breakpoint regex")
                    addr, funct = output.match(breakpointRegex).captures
                    onBreak(addr, funct)
                else
                    @DEBUG and puts("Debugger stoped and I dont know why: #{output}")
                end
            end

            def getRegisters
                output = sendCommand("info registers")
                ret = {}
                output.split(/[\s\n]+/).each_slice(3) do |reg, hex, dec|
                    ret[reg] = hex
                end
                return(ret)
            end

            def getRegister(reg)
                return(getRegisters[reg])
            end

            def getCodeAtPc(size = 10)
                ret = ""
                (0..size).each do |i|
                    ret << sendCommand("x /i $pc+#{i}") 
                end
                return(ret)
            end

            def backtrace
                btRegex = /#\d+\s+(0x\d+) in (.*)$/
                ret = []
                out = sendCommand("bt full")
                out.split("\n").each do |l|
                    if(l.starts_with?("#"))
                        '''
                        #1  0x0000000100112923 in _mh_execute_header ()
                        No symbol table info available.
                        '''
                        frameArray = btRegex.match(btRegex).captures
                        frame = Beezwax::Gdb::Frame.new
                        frame.address = frameArray[0]
                        frame.function = frameArray[1]
                    end
                end
            end

            def continue
                return(sendCommand("continue"))
            end

            def kill
                return(sendCommand("kill"))
            end

        end
    end
end
'''

x = BeezwaxGdbWrapper.new("/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player")
x.DEBUG = false
x.setBreakpoint("0x00007fff951bd686")

#func = x.getFunctions("OpenFrom")
#func.keys.each do |addr|
#    x.setTemporaryBreakpoint(addr)
#end

x.onSignal do |signal, description|
    puts("GOT SIIIIIIGNAL: #{signal} : #{description}")
    if(signal == "SIGTRAP")
        #x.continue
    else
        puts(x.getRegisters)
        puts(x.getCodeAtPc)
        x.kill
        exit
    end
end

x.onBreak do |addr|
    puts("BROKE AT #{addr}")
end

x.runForeground
    
'''