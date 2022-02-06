%function gatherDepthInfo(imgName1, imgName2)
imgName1 = 'PICT0003.TIF';
imgName2 = 'PICT0002.TIF';

% Piotr Latusek, #212613, latusekpiotr@gmail.com
% Maciej <redacted>, #212691, <redacted>@gmail.com

blockSize = 64;
K = 10800;
f = 4.912;
focalDistance = 48;

% Read images and gather their size
I1 = imread(imgName1);
I2 = imread(imgName2);
%h = size(I1, 1);
%w = size(I1, 2);

% Convert to grayscale and normalize images
I1 = double(rgb2gray(I1)) / 255;
I2 = double(rgb2gray(I2)) / 255;

% Create and apply gaussian mask
G = fspecial('gaussian', [3 3], 0.85);
G1 = imfilter(I1, G, 'replicate');
G2 = imfilter(I2, G, 'replicate');

% Create and apply laplacian mask
L = [ -2 -1 -2
      -1 12 -1
      -2 -1 -2 ];
L1 = imfilter(G1, L, 'replicate');
L2 = imfilter(G2, L, 'replicate');

% Create "dummy" blurred image "P1g"
G1g = imfilter(G1, G, 'replicate');
L1g = imfilter(G1g, L, 'replicate');

% Calculate energies
sumAll = @(x) sum(sum(x));
P1 = blkproc(L1 .^ 2, [blockSize blockSize], sumAll);
P2 = blkproc(L2 .^ 2, [blockSize blockSize], sumAll);
P1g = blkproc(L1g .^ 2, [blockSize blockSize], sumAll);

% Calculate relative power differences
% and the C matrix
PD1 = 2 * (P2 - P1) ./ (P1 + P2);
PD2 = 2 * (P1g - P1) ./ (P1 + P1g);
C = PD1 ./ PD2;

% Frame the result
C = C(1:24, 10:34);

% Calculating U matrix
s = 1 / (1 / f - 1 / focalDistance);
u = 1 ./ ((1 / f) - (K + (K^2 + 4 * K * C * s^2) .^ 0.5) / (2 * K * s));

% Smooth U matrix
smooth =  [ 2^0.5  1  2^0.5;
              1    0    1  ;
            2^0.5  1  2^0.5 ];
smooth = 2 - smooth;
smooth = smooth ./ sum(smooth(:));
u = imfilter(u, smooth, 'replicate');

% Display U matrix
[X, Y] = meshgrid(1:size(u, 2), 1:size(u, 1));
figure; surf(X, Y, u); colormap jet;
set(gca,'Zdir','reverse');





