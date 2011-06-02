require 'sdl'
require "OptiquesEtUltrasons.rb"

#u = InterfaceUltrason.new "/dev/ttyUSB0"
#u.demarrer
v = Ultrasons.new "/dev/ttyUSB0"
w = Optiques.new "/dev/ttyUSB0"
sleep 1

rot=0
SDL.init( SDL::INIT_VIDEO )

screen = SDL::setVideoMode(900,675,16,SDL::SWSURFACE)

bleu = screen.mapRGB(0,0,255)
vert = screen.mapRGB(0,255,0)
rouge = screen.mapRGB(255,0,0)

#petite legende pour les curieux
#version 8 capteurs : 
print "Bas Avant Gauche\nBas Avant Droite\n\nBas Arriere Gauche\nBas Arriere Droite\n\nHaut Avant Gauche\nHaut Avant Droite\nHaut Arriere Gauche\nHaut Arriere Droite\n\nOptiques : \nAvant Gauche\tAvant droite\nArrière Gauche\tAvant Droite\n\n"


#boucle de raffraichissement de l'affichage
while true
	v.traitement
	sleep 0.05
	while event = SDL::Event2.poll#ecoute d'evenements d'entree
		case event
		when SDL::Event2::Quit#evenement=fermer fenetre
			exit
		end
	end
	SDL::Key.scan#regarde l'etat du clavier

	screen.fillRect(0, 0, 900, 675, 0)

	#puts "v.ultrason"
	#puts v.ultrason

	#on affiche les diagrammes
	#train bas avant
	for j in [0,1]
		if v.ultrason[j].to_i<=900
			screen.fillRect(0,50*(j+1),(v.ultrason[j]).to_i,50,bleu)
		else
			screen.fillRect(0,50*(j+1),900,50,bleu)
		end
	end
	#train bas arriere
	for j in [2,3]
		if v.ultrason[j].to_i<=900
			screen.fillRect(0,50*(j+2),(v.ultrason[j]).to_i,50,bleu)
		else
			screen.fillRect(0,50*(j+2),900,50,bleu)
		end
	end
	#train haut (AvG,AvD,ArG,ArD)
	for j in [4,5,6,7]
		if v.ultrason[j].to_i<=900
			screen.fillRect(0,50*(j+3),(v.ultrason[j]).to_i,50,bleu)
		else
			screen.fillRect(0,50*(j+3),900,50,bleu)
		end
	end
	rot+=1
	if rot==1
		screen.fillRect(850,625,50,50,rouge)
	elsif rot==2
		screen.fillRect(850,625,50,50,vert)
	else
		screen.fillRect(850,625,50,50,bleu)
		rot=0
	end

	#on passe aux optiques : 
	w.traitement
	sleep 0.05

	#puts "w.optiques"
	#puts w.optiques

	if w.optiques[0]==0
		#puts "OK"
		screen.drawFilledEllipse(25,600,25,25,rouge)
		#screen.fillRect(25,575,50,50,bleu)

	end
	if w.optiques[1]==0
		#puts "Ok"
		screen.drawFilledEllipse(75,600,25,25,rouge)
		#screen.fillRect(75,625,50,50,bleu)
	end
	if w.optiques[2]==0
		#puts "oK"
		screen.drawFilledEllipse(25,650,25,25,rouge)
		#screen.fillRect(25,575,50,50,bleu)
	end
	if w.optiques[3]==0
		#puts "ok"
		screen.drawFilledEllipse(75,650,25,25,rouge)
		#screen.fillRect(75,625,50,50,bleu)
	end

	screen.updateRect(0,0,0,0)#met à jour l'affichage
end

u.arreter
