#!/usr/bin/ruby -I../lib

require "readline"

require "Robot"


require 'joystick'

# make sure a device was specified on the command-line
unless ARGV.size > 0
  $stderr.puts 'Missing device name.'
  exit -1
end


#robot = Robot.new(:jaune, Position.new(300, 300, 0))
robot = Robot.new(:bleu, Position.new(300, -300, 0.0085))
robot.demarrer

class Con
  attr_accessor :type, :val, :num
  def initialize
    @type=1
    @val=0
    @num=0
  end

end
Joystick::Device.open(ARGV[0]) { |joy|
  evtemp=""
  begin
    evtemp=joy.ev
  end while(evtemp.type!=Joystick::Event::BUTTON)
  ev=Con.new
  ev.type=evtemp.type
  ev.val=evtemp.val
  ev.num=evtemp.num
  #ev=evtemp

  #robot.changerVitesse(250,50)

  temps=Time.now.to_f
  loop {
    #puts "-3-: " + ev.type.to_s
    if(joy.pending?)
      evtemp = joy.ev
      if(evtemp.type==Joystick::Event::BUTTON)
        #puts "-1-: " + ev.type.to_s
        ev.type=evtemp.type
        ev.val=evtemp.val
        ev.num=evtemp.num
        #ev=evtemp
        #puts ev.type
      end
      #puts ev.type
    else
      #puts ev.type
    end
    begin
      puts "bouton: #{ev.num}, #{ev.val}"
      diff=Time.now.to_f - temps.to_f
      #puts "-2-: " + ev.type.to_s
      ######tourner
      if ev.num == 1 && ev.val ==1		     		
        if(diff>0)
          temps=Time.now.to_f				
          #j.avance
          robot.tourneDe 0.05
        end
        #elsif ev.num == 1 && ev.val ==0
        #robot.tourneDe 0.0


      elsif ev.num == 2 && ev.val ==1
        if(diff>0)
          temps=Time.now.to_f
          #j.recule
          robot.tourneDe -0.05
        end
        #elsif ev.num == 2 && ev.val ==0
        #robot.tourneDe 0.0

        ###avancer
      elsif ev.num == 0 && ev.val ==1
        if(diff>0.1)	
          temps=Time.now.to_f	      		
          robot.avancer 50
        end
      elsif ev.num == 0 && ev.val ==0
        if(diff>0.1)	
          temps=Time.now.to_f	      		
          robot.avancer 0
        end

      elsif ev.num == 3 && ev.val ==1
        if(diff>0.1)
          temps=Time.now.to_f	
          robot.avancer -50
        end
      elsif ev.num == 3 && ev.val ==0
        if(diff>0.1)	
          temps=Time.now.to_f	      		
          robot.avancer 0
        end

        ##
      elsif ev.num == 5 && ev.val ==1
        if(diff>0.1)
          temps=Time.now.to_f	
          robot.baisseFourche
        end
      elsif ev.num == 4 && ev.val ==1
        if(diff>0.1)
          temps=Time.now.to_f	
          robot.leveFourche
        end

      elsif ev.val==0
        puts "on arrete"
      end
    end
  }
}

robot.arreter

