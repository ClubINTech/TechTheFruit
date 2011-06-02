class Fixnum
        def modulo2 arg = (2 * Math::PI)
                angle = self.to_f % arg
                
                if 2 * angle > arg 
                        angle -= arg
                end
                
                angle
        end
end