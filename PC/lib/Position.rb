# Ce fichier contient la classe Position.
# Author::    Guillaume Rose  (mailto:guillaume.rose@gmail.com)
# Copyright:: Copyright (c) 2010 INTech - TechTheFruit
# License::   GPL

require "Point"

# Cette classe étend la classe Point pour lui ajouter une composante angulaire.

class Position < Point

        # Nouvel attribut à une position, l'orientation du robot
        attr_accessor :angle

        # Initialisation à partir de x, y et de l'angle par rapport à (Ox).
        # Par défaut, la position est l'origine.
        def initialize x = 0, y = 0, a = 0
                super(x, y)
                @angle = a
        end

        # Affiche les attributs d'une position
        def prettyprint
                puts "x = " + @x.to_s + ", y = " + @y.to_s + ", angle = " + @angle.to_s
        end

        def == p
                (x == p.x) && (y == p.y) && ((angle - p.angle) % (2 * Math::PI) == 0)
        end

        def existe?
                (x >= 0) && (x <= 3000) && (y >= 0) && (y <= 2100)
        end
        
        def assezLoinDuBord?
                (x >= 250) && (x <= 2750) && (y >= 250) && (y <= 1850)
        end
        
        def symetrie
                Position.new(@x, -@y, -@angle)
        end

end
