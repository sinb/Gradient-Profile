function  intercepColRow = findIntercept1(row, col, Gdir, Gmag)
%FINDINTERCEPT1 find interception points along line which's degree is
%between (0, 45], [135, 180]
%return col,row which can be decimal
    tanValue = tan(Gdir(row, col) *pi/180);
    lxmb = @(x,mb) mb(1).*x + mb(2);    % Line equation: y = m*x+b
    m = tanValue;
    b = row - col*tanValue;
    mb = [m;b];
    x = (0:size(Gmag, 2));
    y = (0:size(Gmag, 1));
    L1 = lxmb(x,mb);
    hix = @(y,mb) [(y-mb(2))./mb(1);  y];   % Calculate horizontal intercepts
    vix = @(x,mb) [x;  lxmb(x,mb)];     % Calculate vertical intercepts
    hrz = hix(y,mb)' ;              % [X Y] Matrix of horizontal intercepts
    vrt = vix(x,mb)'  ;             % [X Y] Matrix of vertical intercepts
    hvix = [hrz; vrt];                 % Concatanated ‘hrz’ and ‘vrt’ arrays
    intercepColRow = unique(round(hvix*10^4)/10^4,'rows');        % Remove repeats and sort ascending by ‘x’
end