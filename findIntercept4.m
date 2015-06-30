function  intercepColRow = findIntercept4(row, col, Gdir, Gmag)
%FINDINTERCEPT1 find interception points along line which's degree is
%between (45, 90), (90, 135)
%return col,row which can be decimal

    tanValue = tan(Gdir(row, col) *pi/180);
    lxmb = @(x,mb) mb(1).*x + mb(2);    % Line equation: y = m*x+b
    m = tanValue;
    b = row - col*tanValue;
    mb = [m;b];
    %             x = x_near;
    %             y = (row-range:1:row+range);
    x = (0:length(Gmag));
    y = x;
    L1 = lxmb(x,mb);
    hix = @(y,mb) [(y-mb(2))./mb(1);  y];   % Calculate horizontal intercepts
    vix = @(x,mb) [x;  lxmb(x,mb)];     % Calculate vertical intercepts
    hrz = hix(y,mb)' ;            % [X Y] Matrix of horizontal intercepts
    vrt = vix(x,mb)'  ;             % [X Y] Matrix of vertical intercepts
    hvix = [hrz; vrt];                 % Concatanated ‘hrz’ and ‘vrt’ arrays
    intercepColRow = unique(round(hvix*10^4)/10^4,'rows');        % Remove repeats and sort ascending by ‘x’


end