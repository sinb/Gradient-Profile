function [v1, v2] = getTwoGrayValue()
    v1 = rand(1);
    v2 = rand(1);
    while abs(v1 - v2) < 0.1
        v1 = rand(1);
        v2 = rand(1);    
    end
end