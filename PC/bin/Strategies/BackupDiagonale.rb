# -*- coding: utf-8 -*-
require "Strategie"
require "Vecteur"

require "Log"

class Diagonale < Strategie

        def initialize
                # temps requis, points gagnés, position de départ
                super(25, 1200, Position.new(300, 300, 0))

                @log = Logger.instance

                @executee = false
        end

        def condition
                @executee != true
        end

        def sequence
                begin
                        @executee = true
                        @robot.changerVitesse(1000, 1000)	
                        sleep 1
                        @robot.baisseFourche
                        @robot.selecteurMilieu
                        @robot.goTo 1150, 304, 3.14, :blocageTranslation
                        @robot.leveFourche
                        sleep 1
                        @robot.goTo 300, 310
                        @robot.tourneDe(Math::PI)
                        @robot.rouleauDirect


                        @robot.changerVitesse(2000, 2000)
                        Thread.new { sleep 1.5
                                @robot.activeEvitement
                        }
                        deplacement(2690, 1889, (Math::PI/2))
                        # vidage	
                        puts "ici"
                        @robot.rouleauIndirect
                        sleep 2
                        @robot.tourner(-Math::PI)
                        sleep 1
                        @robot.baisseFourche
                        sleep 2
                        @robot.avancer -10
                        @robot.avancer 10
                        sleep 2
                        puts "la"
                        @robot.leveFourche
			
			@robot.alignement(-Math::PI/4)
			deplacement 1500, 1222, -3*(Math::PI/4)
			@robot.goTo 600,1722
			@robot.tourneDe (Math::PI)
			deplacement 1500, 1722, (Math::PI/4)
			#deplacement 2400, 1222, (-Math::PI/4)

			deplacement(2690, 1889, (Math::PI/2))
			# vidage	
                        puts "deuxième vidage"
                        @robot.rouleauIndirect
                        sleep 2
                        @robot.tourner(-Math::PI)
                        sleep 1
                        @robot.baisseFourche
                        sleep 2
                        @robot.avancer -10
                        @robot.avancer 10
                        sleep 2
                        puts "la"
                                    
			return true                        
			@robot.alignement(-Math::PI/4)
                        deplacement 300, 300, 3.14
                        @robot.goTo 200, 300
                        @robot.goTo 600, 193
                        @robot.alignement 3.14                         
                        @robot.baisseFourche
                        @robot.selecteurMilieu
                        @robot.changerVitesse(1000, 1000)                
                        @robot.goTo 1190, 193, :bypass
                        @robot.leveFourche
                        sleep 1
                        @robot.goTo 300, 300, :bypass
                        #@robot.tourneDe(Math::PI)
                        #@robot.recalageJauneEnCours
                        @robot.changerVitesse(2500,2500)
                        @robot.rouleauDirect
                        deplacement 375, 1097, (Math::PI/4)
                        deplacement 1500, 1722, (Math::PI/4)
                        deplacement(2690, 1889, (Math::PI/2))
                        # vidage	
                        puts "ici"
                        @robot.rouleauIndirect
                        sleep 2
                        @robot.stopRouleau

                        @robot.tourneDe(-Math::PI/2)
                        @robot.tourneDe(-Math::PI/2)
                        sleep 1
                        @robot.baisseFourche
                        sleep 2
                        @robot.goTo 2690, 1869
                        @robot.goTo 2690, 1889
                        sleep 2
                        puts "la"
                        @robot.leveFourche  
                        deplacement 2625, 375, 0
                        @robot.desactiveEvitement
                        @robot.goTo 2700, 310
                        @robot.alignement 0
                        @robot.baisseFourche
                        @robot.goTo 1860, 310, :bypass
                        @robot.leveFourche
                        sleep 1
                        @robot.goTo 2700, 310
                        @robot.alignement 0
                        @robot.rouleauDirect


                        @robot.changerVitesse(2500, 2500)
                        Thread.new { sleep 1.5
                                @robot.activeEvitement
                        }
                        deplacement(2690, 1889, (Math::PI/2))
                        # vidage	
                        puts "ici"
                        @robot.rouleauIndirect
                        sleep 2
                        @robot.tourneDe(-Math::PI/2)
                        @robot.tourneDe(-Math::PI/2)
                        sleep 1
                        @robot.baisseFourche
                        sleep 2
                        @robot.goTo 2690, 1869
                        @robot.goTo 2690, 1889
                        sleep 2
                        return true
                        # vidage	
                        @robot.alignement(Math::PI/5)
                        @robot.rouleauIndirect
                        sleep 2
                        @robot.stopRouleau
                        @robot.alignement(-(Math::PI/2))
                        @robot.baisseFourche
                        sleep 1
                        @robot.goTo 2690, 1895

                        return true

                        #         @robot.goTo 2350, 1807, -(Math::PI/4)
                        #         @robot.goTo 2400, 1847, -(Math::PI/4)
                        #         @robot.goTo 2350, 1807, -(Math::PI/4)
                        #         @robot.goTo 2400, 1847, -(Math::PI/4)
                        #         sleep 2
                        @robot.rouleauIndirect		
                        @robot.goTo 295, 193
                        @robot.alignement 3.14 	
                        sleep 2
                        @robot.baisseFourche
                        @robot.selecteurMilieu
                        @robot.goTo 1170, 193, 3.14, :bypass
                        @robot.leveFourche
                        @robot.changerVitesse(2000, 2000)              
                        sleep 0.5
                        @robot.goTo 300, 193           
                        @robot.alignement 0
                        @robot.rouleauDirect
                        @robot.changerVitesse(1500, 1500)
                        deplacement 2700, 1889, -(Math::PI/5)*4
                        @robot.alignement(Math::PI/5)
                        @robot.rouleauIndirect
                        sleep 2
                        @robot.stopRouleau

                        #   @robot.goTo 2657, 1868
                        @robot.alignement(-(Math::PI/2))

                        @robot.baisseFourche
                        sleep 1
                        @robot.goTo 2700, 1895
                end
        end
        def deplacement(x, y, angle)
                destination = Position.new(x, y, angle)
                points = chemin(destination)
                precedent = [@robot.position.clone]

                while !points.empty?
                        prochainPoint = points.first
                        retour = @robot.goToDep(prochainPoint.x, prochainPoint.y)


                        if (!retour || @carte.estBloque?(@robot.position))
                                @log.debug "Obstacle détecté"

                                # @carte.bloquerZone(position, 10)
                                while precedent != [] && @carte.estBloque?(@robot.position)
                                        precedent2 = precedent.last
                                        retour = @robot.goToDep precedent2.x, precedent2.y
                                        precedent -= [precedent.last]
                                end

                                nouvelleListe = chemin(destination)

                                if (nouvelleListe.first.y == prochainPoint.y) && (nouvelleListe.first.x == prochainPoint.x)
                                        # Aller retour
                                        @log.debug "Aucune issue"
                                        # sleep(10)
                                        while precedent != [] && @carte.estBloque?(@robot.position)
                                                precedent2 = precedent.last
                                                retour = @robot.goToDep precedent2.x, precedent2.y
                                                precedent2 -= [precedent.last]
                                        end
                                        # sleep 5
                                        points = chemin(destination)
                                else
                                        # Nouveau chemin
                                        @log.debug "Issue trouvée"
                                        points = nouvelleListe
                                end
                                # points = chemin(destination)
                        end
                        while retour != true     
                                puts "retdeplacementgoToDep",retour
                                retour = @robot.goToDep(prochainPoint.x, prochainPoint.y)
                        end
                        precedent += [prochainPoint]
                        points -= [prochainPoint]

                        @robot.tourneDe((prochainPoint.angle - @robot.position.angle).modulo2)
                end
        end

        # def deplacement(x, y, angle)
        #         position = @robot.position
        #         destination = Position.new(x, y, angle)
        #         points = chemin(destination)
        #         listePrecedent = [position.clone]
        # 
        #         echec = 0
        # 
        #         while !points.empty?
        #                 prochainPoint = points.first
        #                 retour = @robot.goTo prochainPoint.x, prochainPoint.y, prochainPoint.angle 
        # 
        #                 if (!retour || @carte.estBloque?(position))
        #                         echec += 1
        #                         if echec > 3
        #                                 @log.debug "3 échecs"
        #                                 return false
        #                         end
        #                         
        #                         @log.debug "Obstacle détecté"
        #                         
        #                         puts listePrecedent.inspect
        #                         
        #                         while listePrecedent != [] && @carte.estBloque?(position)
        #                                 precedent = listePrecedent.last
        #                                 deplacement = Vecteur.new(position, destination)
        #                                 # if deplacement.norme >= 700
        #                                 #         k = 700 / deplacement.norme.to_f
        #                                 #         nouvelleDestination = Position.new
        #                                 #         nouvelleDestination.x = (destination.x - position.x) * k + position.x
        #                                 #         nouvelleDestination.y = (destination.y - position.y) * k + position.y
        #                                 #         nouvelleDestination.angle = deplacement.angle
        #                                 #         @robot.goTo nouvelleDestination.x, nouvelleDestination.y, nouvelleDestination.angle
        #                                 # else
        #                                         @robot.goTo precedent.x, precedent.y, precedent.angle
        #                                 # end
        #                                 listePrecedent -= [listePrecedent.last]
        #                         end
        # 
        #                         nouvelleListe = chemin(destination)
        # 
        #                         if (nouvelleListe.first.y == prochainPoint.y) && (nouvelleListe.first.x == prochainPoint.x)
        #                                 # Aller retour
        #                                 @log.debug "Aucune issue"
        #                                 sleep 5
        #                                 points = chemin(destination)
        #                         else
        #                                 # Nouveau chemin
        #                                 @log.debug "Issue trouvée"
        #                                 points = nouvelleListe
        #                         end
        #                 else
        #                         listePrecedent += [prochainPoint]
        #                         points -= [prochainPoint]
        #                 end
        #         end
        #         return true
        # end

        def chemin(destination, position = Position.new)
                if position == Position.new
                        position = @robot.position
                end
                c = calculAngle([position] + @carte.goTo(position, destination)) - [position] + [destination]
                c -= [c.first]
                c.each { |point|  point.prettyprint }
                c
        end


        def calculAngle(liste)
                n = []
                n.push liste.first
                angleP = liste.first.angle
                for i in (1..liste.size - 2)
                        angle = Vecteur.new(liste[i-1], liste[i+1]).angle
                        if angle == angleP
                                n.pop
                        end
                        n.push Position.new(liste[i].x, liste[i].y, angle)
                        angleP = angle
                end
                n
        end

end
