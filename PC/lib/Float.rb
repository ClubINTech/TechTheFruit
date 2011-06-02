class Float
        def modulo2 arg = (2 * Math::PI)
                angle = self % arg
                
                if 2 * angle > arg 
                        angle -= arg
                end
                
                angle
        end
end