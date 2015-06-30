close all;
%% kernel parameters
w1 = 9;
[X1 Y1] = meshgrid([-w1:w1]);
kernel_sz = size([-w1:w1], 2);
%%
eth=0.1; % thershold for canny edge detector
%% two sigma array
sig_a = [0.1:0.1:3];
sig_b = [0.1:0.1:3];
sig_len = length(sig_a);
idx_a = randperm(sig_len);
idx_b = randperm(sig_len);
%%
for i = 1:1:30 % 30 images
    [v1, v2] = getTwoGrayValue();
    I = generateImage(102, 102, v1, v2, 3);
    gI = rgb2gray(I);
    
    gauss_a = fspecial('gaussian', [kernel_sz kernel_sz], sig_a(idx_a(i)));
    gauss_b = fspecial('gaussian', [kernel_sz kernel_sz], sig_b(idx_b(i)));
    
    img_blurred  = ...
        convolutionTwoKernel(gI, gauss_a, gauss_b, floor(size(I,1)/2));
    subplot(3,1,1)
    plot(45:58, img_blurred(51, 45:58), 'ro-')
    img_blurred = img_blurred(10:end-10, 10:end-10);
    %% draw profile
    
    gI = img_blurred;
    edgeMap=edge(gI,'canny',eth,1);
    [Gmag,Gdir] = imgradient(gI); 
    [GX, GY] = imgradientxy(gI);
    Gdir = atan2(GY,GX);
    Gdir = Gdir * 180/pi;
    Gdir(find(Gdir < 0)) = Gdir(find(Gdir < 0)) + 180;
    idx=find(edgeMap~=0);
    [rows, cols] = find(edgeMap > 0);
    %only to draw one profile in the middle of the image
    range = 8;
    idx = round(length(rows)/2);
    Gdir(rows(idx), cols(idx))
    [GradProfile, GradProfileX, GradProfileCenterLoc] = nearstLinearInterp(rows(idx), cols(idx), Gmag, Gdir, range);
    subplot(3,1,3)
    plot(GradProfileX,GradProfile, 'r-o'),hold on
    plot(GradProfileX(GradProfileCenterLoc), GradProfile(GradProfileCenterLoc), 'b*')
    close all
end
