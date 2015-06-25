close all;clear
% load('circle.mat')
I = imread('input.png');
I = im2double(I);
gI = rgb2gray(I);
% gI = I;

% [v1, v2] = getTwoGrayValue();
% gI = generateImage(102, 102, v1, v2, 1);
[Gmag,Gdir] = imgradient(gI); 
[GX, GY] = imgradientxy(gI);
Gdir = atan2(GY,GX);
Gdir = Gdir * 180/pi;
Gdir(find(Gdir < 0)) = Gdir(find(Gdir < 0)) + 180;
% imshow(Gmag),hold on
%%
eth=0.1; % thershold for canny edge detector
edgeMap=edge(gI,'canny',eth,1);
% figure,imshow(edgeMap)
%%
idx=find(edgeMap~=0);
[rows, cols] = find(edgeMap > 0);
%% plot edge point upon Gmag
% figure, imshow(Gmag), hold on;
% for x=1:size(Gmag, 2)
%     for y=1:size(Gmag,1)
%         if edgeMap(y, x)
%             plot(x, y, 'ro')
%         end
%     end
% end
% hold off
%%
% plot(rows, cols, 'ro')
range = 5;
%drawDirection(rows, cols, range, Gmag, Gdir)
out = randseed(1);
randIndex = randperm(length(rows));
for index=1:1:length(rows)
% for idx=5000:1:6000
    idx = randIndex(index)
    [GradProfile, GradProfileX, GradProfileCenterLoc] = nearstLinearInterp(rows(idx), cols(idx), Gmag, Gdir);
    Gdir(rows(idx), cols(idx))
    figure, plot(GradProfileX,GradProfile, 'r-o'),hold on
    plot(GradProfileX(GradProfileCenterLoc), GradProfile(GradProfileCenterLoc), 'b*')
    close all
end
