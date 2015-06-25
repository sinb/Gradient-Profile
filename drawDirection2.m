function drawDirection2(gI, edgeMap)
    [GX, GY] = imgradientxy(gI);
    [GradMag, Gdir] = imgradient(gI);
     AngImg = atan2(GX, GY);
     % obtain the coordinates along the gradient direction centerted on the edge points
    AngImg(AngImg < 0) = AngImg(AngImg < 0) + pi;   % range from 0 to pi
    [rows, cols] = find(edgeMap > 0);
    AngVecEdge = AngImg(edgeMap > 0);
    angidxset1 = find(AngVecEdge < 45/180*pi | AngVecEdge >= 135/180*pi);
    angidxset2 = find(AngVecEdge >= 45/180*pi & AngVecEdge < 135/180*pi);
    % for angles in "angidxset1"
    u = -10:10;
    U = ones(length(angidxset1),1) * u;
    V = round(tan(AngVecEdge(angidxset1))*ones(1,length(u)) .* U);
    X1 = U + cols(angidxset1)*ones(1,length(u));
    Y1 = V + rows(angidxset1)*ones(1,length(u));
    % for angles in "angidxset2"
    v = -10:10;
    V = ones(length(angidxset2),1) * v;
    U = round(tan(pi/2 - AngVecEdge(angidxset2))*ones(1,length(v)) .* V);
    X2 = U + cols(angidxset2)*ones(1,length(v));
    Y2 = V + rows(angidxset2)*ones(1,length(v));
    % combine the above results
    X = zeros(length(AngVecEdge), length(v));
    X(angidxset1, :) = X1;
    X(angidxset2, :) = X2;
    Y = zeros(length(AngVecEdge), length(v));
    Y(angidxset1, :) = Y1;
    Y(angidxset2, :) = Y2;
    %%
    figure (100), imshow(gI, []), hold on
    %nvec = randsample(57385, 10000);
    nvec = randsample(51356, 10000);
    for n = 1:length(rows)

        r = rows(n);
        c = cols(n);
    %     if r <= 10 || r > w-10 || c <= 10 || c > h-10
    %         continue
    %     end
    
%         if r <= 10 || r > h-10 || c <= 10 || c > w-10
%             continue
%         end


        figure (100), plot(X(n,:), Y(n,:), 'r-'), plot(c, r, 'ro')
        % intensity values
    % % % %     n
    % % % %     r
    % % % %     c
    % % % %     max(X(n,:))
    % % % %     max(Y(n,:))
        IntenVal = [X(n,:); Y(n,:); diag(gI(Y(n,:), X(n,:)))'];

        figure (1000), plot(IntenVal(3,:), 'r-o'), hold on, plot(11, IntenVal(3,11), 'r*'), hold off, grid on
        % gradient magnitudes
        GradMagVal = [X(n,:); Y(n,:); diag(GradMag(Y(n,:), X(n,:)))'];
        figure (2000), plot(GradMagVal(3,:), 'r-o'), hold on, plot(11, GradMagVal(3,11), 'r*'), hold off, grid on
    end
end