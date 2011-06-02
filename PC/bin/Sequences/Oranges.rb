def sequence robot
	t = Time.now
	robot.goTo 46.5, 0, 0
	Thread.new { robot.prendreOranges }
	sleep 1.3
	Thread.new {
		sleep 0.4
		robot.viderOranges 
	}
	robot.goTo 22, -4.5, 0 
	robot.goTo 42, -8.5, 0
	robot.goTo 48.5, -8.5, 0
	Thread.new { robot.prendreOranges }
	sleep 1.5
	robot.goTo 43, -8.5, 0
	robot.goTo -15, 0, (Math::PI/3)
	robot.goTo 0, 30, (Math::PI/3)
	robot.goTo 150, 100, (Math::PI/2)
	puts (Time.now - t).to_s
	robot.viderOranges
	robot.viderOranges
end
