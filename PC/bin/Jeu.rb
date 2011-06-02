#!/usr/bin/ruby -I../lib

require "readline"

require "ListeEvenements"
require "RobotMagique"

begin
        ligne = Readline.readline("Coté de jeu : (j : jaune, b : bleue)\n", true)
end while (ligne != "j" and ligne != "b")

if ligne == "j"
        positionInitiale = Position.new(300, 300, 0)
        magicien = RobotMagique.new(positionInitiale, ListeEvenements, "Strategies/", :jaune)  
else
        positionInitiale = Position.new(300, -300, 0)
        magicien = RobotMagique.new(positionInitiale, ListeEvenements, "Strategies/", :bleu)        
end

Readline.readline("Presser une touche pour lancer le robot", true)

magicien.demarrer
