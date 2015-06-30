function drawDirection3(row, col, range, Gdir)
%DRAWDIRECTION3 draw line which's degree 90 (vertical line)

    y_near = (row-range:1:row+range);
    x_near = ones(size(y_near))*col;
    plot(x_near, y_near, 'b-');hold on
    plot(col, row, 'ro');
end