# Ce fichier contient la classe de log.
# Author::    Guillaume Rose  (mailto:guillaume.rose@gmail.com)
# Copyright:: Copyright (c) 2010 INTech - TechTheFruit
# License::   GPL

require 'logger'
require 'singleton'

# Cette classe permet d'afficher les logs soit sur la sortie des erreurs,
# soit dans un fichier avec un certain niveau de log.

class Logger
    include Singleton
    @@old_initialize = Logger.instance_method :initialize

    def initialize
        # @@old_initialize.bind(self).call("log/" + Time.now.strftime("%m.%d.%Y-%Hh%M"))
        @@old_initialize.bind(self).call(STDERR)
    end  
end

# log = Logger.instance
# log.level = Logger::WARN
# 
# log.debug("Created logger")
# log.info("Program started")
# log.warn("Nothing to do!")
