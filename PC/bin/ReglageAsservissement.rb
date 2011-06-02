#!/usr/bin/ruby -I../lib

require "readline"

require "SerieSimple"

puts "Réglage de l'arduino d'asservissement"
puts "Premier caractère, type d'asservissement t ou r"
puts "Deuxième caractère, type de constante, Acc (a), Kp (k), Vmax (v), PWM (p)"
puts "Valeur"

peripherique = `ls -1 /dev/ttyUSB* 2> /dev/null`
liaison = Serie.new("/dev/ttyUSB0", 57600)

while line = Readline.readline("> ", true)
        type = line[0].chr
        typeC = line[1].chr
        valeur = line[2..line.size - 1].to_i
        if type == "a"
        	liaison.ecrire "b" + valeur.to_s.rjust(8, "0")
        end
        if type == "?"
		liaison.ecrire "?"

	end
	if type == "b"
        	liaison.ecrire "g" + valeur.to_s.rjust(8, "0")
        end
        if type == "c"
        	liaison.ecrire "a" + valeur.to_s.rjust(8, "0")
        end
        if type == "d"
        	liaison.ecrire "f" + valeur.to_s.rjust(8, "0")
        end
        if type == "r"
                if typeC == "a"
                        liaison.ecrire "k" + valeur.to_s.rjust(8, "0")
                end
                if typeC == "k"
                        liaison.ecrire "m" + valeur.to_s.rjust(8, "0")
                end
                if typeC == "v"
                        liaison.ecrire "l" + valeur.to_s.rjust(8, "0")
                end
                if typeC == "p"
                        liaison.ecrire "p" + valeur.to_s.rjust(8, "0")
                end    
		if typeC == "i"
                        liaison.ecrire "v" + valeur.to_s.rjust(8, "0")
                end
        end
        if type == "t"
                if typeC == "a"
                        liaison.ecrire "q" + valeur.to_s.rjust(8, "0")
                end
                if typeC == "k"
                        liaison.ecrire "s" + valeur.to_s.rjust(8, "0")
                end
                if typeC == "v"
                        liaison.ecrire "r" + valeur.to_s.rjust(8, "0")
                end
                if typeC == "p"
                        liaison.ecrire "t" + valeur.to_s.rjust(8, "0")
                end    
		if typeC == "i"
			liaison.ecrire "u" + valeur.to_s.rjust(8, "0")
		end
        end
	retour = ""
	begin
		if ((caractere = liaison.getc) != nil) 
			retour << caractere.chr
		end
	end while caractere != 10
	retour.split("\r\n").first
end
