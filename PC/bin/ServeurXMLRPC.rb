#!/usr/bin/ruby -I../lib

require "xmlrpc/server"
require "Robot"
require "Log"

log = Logger.instance
log.level = Logger::DEBUG

serveur = XMLRPC::Server.new(8080, "192.168.10.106")

robot = Robot.new(Position.new(0, 0, 0))
robot.demarrer

# La ressource distante doit être robot pour être utilisé par la classe
# RobotDistant (premier argument)
serveur.add_handler("robot", robot)
serveur.serve

robot.arreter
