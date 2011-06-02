require "xmlrpc/client"

require "Position"

class RobotDistant

        def initialize ip = "localhost", port = 8080
                # On peut sans doute remplacer cette technologie par SOAP
                @serveur = XMLRPC::Client.new(ip, "/", port)
                @serveur.timeout = 120
        end

        def position
                Position.new(x, y, angle).inspect
        end

        # Le nom de la ressource distante doit être robot
        def method_missing(method, *arg)
                begin
                        @serveur.call("robot." + method.to_s, *arg)
                rescue
                        puts "Erreur : fonction inexistante ou argument manquant pour " + method.to_s + "(" + arg.join(", ") + ")" 
                end
        end

end