require "GestionEvenements"
require "Log"
require "Position"

# Utiliser @log, @robot, et @carte
class ListeEvenements < GestionEvenements

        def setup
        end

        def evArretUrgence
                # return
                capteurs = @robot.ultrasons
                # @log.debug capteurs.inspect

                positionBloquee = @robot.position.clone

                if @robot.sens == 1 && capteurs[1] > 10 && capteurs[1] <= 400 && @robot.evitement?


                        positionBloquee.x += capteurs[1] * Math.cos(@robot.position.angle)
                        positionBloquee.y += capteurs[1] * Math.sin(@robot.position.angle)

                        if positionBloquee.assezLoinDuBord? && !@carte.estBloque?(positionBloquee)
                                @carte.bloquerZone(positionBloquee, 10)
                                @robot.stop
                                @log.debug "Obstacle AvM"                        
                        end
                end

                return true

                if @robot.sens == 1 && capteurs[0] > 10 && capteurs[0] <= 500 && @robot.tempsRestant > 5
                        @log.debug "Obstacle AvG"

                        positionBloquee.x += capteurs[0] * Math.cos(Math::PI/4 + @robot.position.angle)
                        positionBloquee.y += capteurs[0] * Math.sin(Math::PI/4 + @robot.position.angle)

                        if positionBloquee.assezLoinDuBord? && !@carte.estBloque?(positionBloquee)
                                @carte.bloquerZone(positionBloquee, 10)
                                # @robot.stop
                        end
                end

                if @robot.sens == 1 && capteurs[2] > 10 && capteurs[2] <= 400 && @robot.tempsRestant > 5
                        @log.debug "Obstacle AvD"

                        positionBloquee.x += capteurs[2] * Math.cos(-Math::PI/4 + @robot.position.angle)
                        positionBloquee.y += capteurs[2] * Math.sin(-Math::PI/4 + @robot.position.angle)

                        if positionBloquee.assezLoinDuBord? && !@carte.estBloque?(positionBloquee)
                                @carte.bloquerZone(positionBloquee, 10)
                                # @robot.stop
                        end
                end

                if @robot.sens == -1
                        @log.debug "Obstacle ArM"

                        positionBloquee.x += capteurs[3] * Math.cos(@robot.position.angle)
                        positionBloquee.y += capteurs[3] * Math.sin(@robot.position.angle)

                        if positionBloquee.assezLoinDuBord? && !@carte.estBloque?(positionBloquee)
                                @carte.bloquerZone(positionBloquee, 10)
                                @robot.stop
                        end
                end

        end

        def evStockageTomates
                if (@robot.placeSurRailGauche > @robot.placeSurRailDroit)
                        @robot.selecteurDroite
                else
                        @robot.selecteurGauche
                end
        end

        # def evBlocage
        #         if @compteur > 0
        #                 return true
        #         end
        #         
        #         # @log.debug "Blocage ? -> " + @robot.blocage?.to_s
        #         if @robot.blocage?
        #                 sens = @robot.sens
        #                 zoneBloquee = @robot.position.clone
        #                 # @carte.bloquerZone(zoneBloquee, 10)
        #                 
        #                 @compteur = 50    
        #         end
        # end

end
