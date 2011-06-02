require "Position"

class Strategie
        
        attr_reader :temps, :points, :depart
        
        def initialize(temps, points, depart)
                @temps = temps
                @points = points
                @depart = depart
        end
        
        def donnerRessources robot, carte
                @robot = robot
                @carte = carte
        end
        
        def sequence
                1
        end
        
        def condition
                false
        end


        def deplacement(x, y, angle)
                position = @robot.position
                destination = Position.new(x, y, angle)
                points = chemin(destination)
                listePrecedent = [position.clone]

                while !points.empty?
                        prochainPoint = points.first
                        retour = @robot.goTo prochainPoint.x, prochainPoint.y, prochainPoint.angle 

                        if (!retour || @carte.estBloque?(position))
                                @log.debug "Obstacle détecté"

                                while listePrecedent != [] && @carte.estBloque?(position)
                                        precedent = listePrecedent.last
                                        deplacement = Vecteur.new(position, destination)
                                        if deplacement.norme >= 700
                                                k = 700 / deplacement.norme.to_f
                                                nouvelleDestination = Position.new
                                                nouvelleDestination.x = (destination.x - position.x) * k + position.x
                                                nouvelleDestination.y = (destination.y - position.y) * k + position.y
                                                nouvelleDestination.angle = deplacement.angle
                                                @robot.goTo nouvelleDestination.x, nouvelleDestination.y, nouvelleDestination.angle
                                        else
                                                @robot.goTo precedent.x, precedent.y, precedent.angle
                                        end
                                        listePrecedent -= [listePrecedent.last]
                                end

                                nouvelleListe = chemin(destination)

                                if (nouvelleListe.first.y == prochainPoint.y) && (nouvelleListe.first.x == prochainPoint.x)
                                        # Aller retour
                                        @log.debug "Aucune issue"
                                        sleep 5
                                        points = chemin(destination)
                                else
                                        # Nouveau chemin
                                        @log.debug "Issue trouvée"
                                        points = nouvelleListe
                                end
                        else
                                listePrecedent += [prochainPoint]
                                points -= [prochainPoint]
                        end
                end
        end

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
