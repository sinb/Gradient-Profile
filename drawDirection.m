function drawDirection(rows, cols, range, Gmag, Gdir)
    imshow(Gmag),hold on;
    Gdir(find(Gdir < 0)) = Gdir(find(Gdir < 0)) + 180;

    for idx=1:1:length(rows) % for every edge point
%         x_near = (cols(idx)-range:1:cols(idx)+range);
%         y_near = ones(size(x_near))*rows(idx);
%         tanValue = tan(Gdir(rows(idx), cols(idx)) *pi/180);
%         if tanValue < 10^5 && tanValue > -10^5
%             x_near_dist = x_near - cols(idx);
%             y_near_dist = x_near_dist * tanValue;
%             y_near = y_near + y_near_dist;
%         end
%         plot(x_near, y_near, 'b-');
%         plot(cols(idx), rows(idx), 'ro');
%         fprintf('rows:%d, cols:%d, direction: %.3f\n', rows(idx), cols(idx), Gdir(rows(idx), cols(idx)));
    
        if Gdir(rows(idx), cols(idx)) >= 0 && Gdir(rows(idx), cols(idx)) <= 45 ...
        || Gdir(rows(idx), cols(idx)) >=135 && Gdir(rows(idx), cols(idx)) <= 180
            x_near = (cols(idx)-range:1:cols(idx)+range);
            y_near = ones(size(x_near))*rows(idx);
            tanValue = tan(Gdir(rows(idx), cols(idx)) *pi/180);
            x_near_dist = x_near - cols(idx);
            y_near_dist = x_near_dist * tanValue;
            y_near = y_near + y_near_dist;  
            plot(x_near, y_near, 'b-');
            plot(cols(idx), rows(idx), 'ro');
        elseif Gdir(rows(idx), cols(idx)) == 90
               y_near = (rows(idx)-range:1:rows(idx)+range);
               x_near = ones(size(y_near))*cols(idx);
               plot(x_near, y_near, 'b-');
               plot(cols(idx), rows(idx), 'ro');           
        else
            tanValue = tan(Gdir(rows(idx), cols(idx)) *pi/180);
            y_near = (rows(idx)-range:1:rows(idx)+range);
            y_near_dist = y_near - rows(idx);
            x_near = ones(size(y_near))*cols(idx);
            x_near_dist = y_near_dist / tanValue;
            x_near = x_near + x_near_dist;
            plot(x_near, y_near, 'b-');
            plot(cols(idx), rows(idx), 'ro');            
        end
    end
    hold off;
end