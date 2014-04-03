classdef LaplaceKernel < Kernel
    properties
    end
    
    methods
        function obj = LaplaceKernel()
            obj@Kernel();
            obj.name = 'LaplaceKernel';
        end
            
        function ret = k(obj, x, y)
            T = size(x, 2);
            if T <= 200  
                width = 1.2; 
            elseif T < 1200
                 width = 0.7; 
            else
                width = 0.4;
            end            
            theta = 1/width;            
            n2 = dist1(x, y);            
%             if theta == 0
%                 theta = 2/median(n2(tril(n2)>0));
%             end                        
            wi2 = theta / 2;
            ret = exp(-n2*wi2);
        end
        
    end
end

