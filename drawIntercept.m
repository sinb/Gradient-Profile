clc;clear all;close all;
x = 0:5;                            % X-range
y = 0:25;                           % Y-range
lxmb = @(x,mb) mb(1).*x + mb(2);    % Line equation: y = m*x+b
m = 2.7;                              % Slope (or slope array)
b = 1;                              % Intercept (or intercept array)
mb = [m b];                         % Matrix of [slope intercept] values
L1 = lxmb(x,mb);                    % Calculate Line #1 = y(x,m,b)
hix = @(y,mb) [(y-mb(2))./mb(1);  y];   % Calculate horizontal intercepts
vix = @(x,mb) [x;  lxmb(x,mb)];     % Calculate vertical intercepts
hrz = hix(x(2:end),mb)'             % [X Y] Matrix of horizontal intercepts
vrt = vix(y(1:6),mb)'               % [X Y] Matrix of vertical intercepts
figure(1)                           % Draw grids & plot lines
plot(repmat(x,2,length(x)), [0 length(y)-1])    % Vertical gridlines
hold on
plot([0 length(x)-1], repmat(y,2,length(y)))    % Horizontal gridlines
plot(x, L1)                         % Plot more lines here (additional ‘plot’ statements)
hold on
axis equal
hvix = [hrz; vrt];                 % Concatanated ‘hrz’ and ‘vrt’ arrays
srtd = unique(hvix,'rows');        % Remove repeats and sort ascending by ‘x’
plot(srtd(:,1),srtd(:,2),'o');