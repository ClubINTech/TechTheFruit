def sequence robot
	#robot.attendreJumper
	robot.goTo 20, 0, (Math::PI/2)
        robot.goTo 20, 20, (Math::PI)
        robot.goTo 0, 20, (3 * Math::PI/2)
        robot.goTo 0, 0, 0
end
