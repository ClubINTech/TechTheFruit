#!/usr/bin/ruby -I../lib

require "readline"

require "Robot"

#robot = Robot.new(:jaune, Position.new(300, 300, 0))
robot = Robot.new(:bleu, Position.new(300, -300, 0.0085))
robot.demarrer

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
        robot.arreter
	exit
end
