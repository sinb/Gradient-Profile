function drawDirection2(row, col, range, Gdir)
%DRAWDIRECTION2 draw line which's degree is 0 or 180 (horizontal line)
 
    x_near = (col-range:1:col+range);
    y_near = ones(size(x_near))*row;
    tanValue = tan(Gdir(row, col) *pi/180);
    x_near_dist = x_near - col;
    y_near_dist = x_near_dist * tanValue;
    y_near = y_near + y_near_dist;
    plot(x_near, y_near, 'r-');
    plot(col, row, 'yo');
end