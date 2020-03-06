%COMPE565 Homework 4
%Nov. 21, 2019
%Name: Seanmark Paz
%ID: 820246863
%Email: spaz@sdsu.edu

function sample420 = sampling420(image)

frameYcbcr = rgb2ycbcr(image);

%4:2:0 Subsampling
cbComponent = imresize(frameYcbcr(:, :, 2), 0.5, 'bilinear');
crComponent = imresize(frameYcbcr(:, :, 3), 0.5, 'bilinear');

%Upsampling back to image size
cbComponent = imresize(cbComponent, 2);
crComponent = imresize(crComponent, 2);

sample420 = frameYcbcr;
sample420(:, :, 2) = cbComponent;
sample420(:, :, 3) = crComponent;

sample420 = ycbcr2rgb(sample420);
end
