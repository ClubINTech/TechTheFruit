#!/usr/bin/ruby -I../lib

require "readline"

strategies = []

puts "Choississez la stratégie à adopter : "
Dir.entries("Sequences").each { |f|
	if f.include? ".rb"
		strategies.push f
		puts strategies.size.to_s + " - " + f
	end
}
begin
	while line = Readline.readline('> ', true)
		if line.to_i > 0 && line.to_i < strategies.size + 1
			puts "Choix n°" + line + ", " + strategies[line.to_i - 1]
			break
		end
	end
	rescue Interrupt => e
		puts "Arrêt.."
		exit
end

require "Sequences/" + strategies[line.to_i - 1]

require "RobotDistant"

robot = RobotDistant.new("192.168.10.106", "8080")

while line = Readline.readline("Presser une touche pour lancer le robot", true)
	break
end

sequence robot
