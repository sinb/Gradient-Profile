function drawDirection4(row, col, range, Gdir)
%DRAWDIRECTION4 draw line which's degree (45, 90), (90, 135)
    tanValue = tan(Gdir(row, col) *pi/180);
    y_near = (row-range:1:row+range);
    y_near_dist = y_near - row;
    x_near = ones(size(y_near))*col;
    x_near_dist = y_near_dist / tanValue;
    x_near = x_near + x_near_dist;
    plot(x_near, y_near, 'b-');
    plot(col, row, 'ro');

end
