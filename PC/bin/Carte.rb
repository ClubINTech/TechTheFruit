#!/usr/bin/ruby -I../lib

require "CarteTechTheFruit"

require "Position"
require "Log"

class Robot
        def initialize p = Position.new
                @position = p
        end

        def position
                @position
        end
        def goTo x, y, angle
                @position = Position.new x, y, angle
                @position.prettyprint
                true
        end
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


destination = Position.new(2700, 1887, 0)
carte = CarteTechTheFruit.new
robot = Robot.new Position.new(300, 300, 0)

log = Logger.instance

# carte.goTo(Position.new(0, 0, 0), Position.new(2625, 1886, 0))

carte.bloquerZone(Position.new(600, 722, 0), 10)

        c = calculAngle([robot.position] + carte.goTo(robot.position, destination)) - [robot.position] + [destination]
	puts c.inspect
	c.each { |point|  point.prettyprint }


robot.goTo 400, 400, 0


c = calculAngle([robot.position] + carte.goTo(robot.position, destination)) - [robot.position] + [destination]
puts (c - [c.first]).inspect
(c - [c.first]).each { |point|  point.prettyprint }

exit
while !points.empty?
        prochainPoint = points.first
        retour = robot.goTo prochainPoint.x, prochainPoint.y, 0
        if !retour
                log.debug "Obstacle détecté"
                nouvelleListe = carte.goTo(robot.position, destination)
                if nouvelleListe.first == prochainPoint
                        # Aller retour
                        log.debug "Aucune issue"
                        sleep(1)
                else
                        # Nouveau chemin
                        log.debug "Issue trouvée"
                        points = nouvelleListe
                end
        else
                points -= [prochainPoint] 
        end
end

points.each { |point|  point.prettyprint }
