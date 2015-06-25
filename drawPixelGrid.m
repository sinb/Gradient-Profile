function main()
    bw = [...
    0 0 0 1 0 0 0
    0 0 1 0 1 0 0
    0 1 0 0 0 1 0
    1 1 1 1 1 1 1 ];

    drawPixelGrid(bw)
end
function drawPixelGrid(bw)
    [row_size, col_size] = size(bw);
    imshow(bw, 'InitialMagnification', 'fit'),hold on
%         plot(repmat(0:col_size, 2, 1), [0, row_size], 'r-')
%         plot([0, col_size], repmat(0:row_size, 2, 1), 'r-')
	h = findobj(gcf,'type','image');
    xdata = get(h, 'XData');
    ydata = get(h, 'YData');
    M = size(get(h,'CData'), 1);
    N = size(get(h,'CData'), 2);
end