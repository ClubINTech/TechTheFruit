#!/usr/bin/ruby -I../lib

require "readline"

require "RobotDistant"

robot = RobotDistant.new("192.168.10.106", "8080")

begin
        while line = Readline.readline("> ", true)
	        if line != ""
	                if line == "exit"
	                        break
	                else
	                        cmd = line.split(" ") 
	                        fonction = cmd.first
	                        cmd.reverse!.pop
	                        args = cmd.reverse!.collect! {|x| x.to_f}
	                        puts robot.send(fonction, *args)
	                end    
	        end
	end
rescue Interrupt => e
	exit        
end
