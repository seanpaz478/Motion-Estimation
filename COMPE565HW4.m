%COMPE565 Homework 4
%Nov. 21, 2019
%Name: Seanmark Paz
%ID: 820246863
%Email: spaz@sdsu.edu

video = VideoReader('football_qcif.avi');
frames = read(video, [7, 11]);

[frameRows, frameCols, frameColors, frameNum] = size(frames);

sub420Frames = zeros(frameRows, frameCols, frameColors, frameNum);

%Doing 4:2:0 subsampling
for i = 1:5
    sub420Frames(:, :, :, i) = sampling420(frames(:, :, :, i));
end

reconstructed_frames = zeros(frameRows, frameCols, frameColors, frameNum, 'uint8');

QandDCTFrames = zeros(frameRows, frameCols, frameColors, frameNum, 'uint8');

%Performing DCT and Quantization on each frame and then indoing it for
%processing in the motion estimation
for i = 1:5
    QandDCTFrames(:, :, :, i) = QandDCT(sub420Frames(:, :, :, i));
end

for i = 1:5
    QandDCTFrames(:, :, :, i) = ycbcr2rgb(QandDCTFrames(:, :, :, i));
end

%Performing motion estimation on all the frames
%(TSS takes in all 5 frames as an input)
reconstructed_frames = TSS(QandDCTFrames);

for i = 1:5
    reconstructed_frames(:, :, :, i) = ycbcr2rgb(reconstructed_frames(:, :, :, i));
end


for i = 1:5
    figure()
    imshow(reconstructed_frames(:, :, :, i))
end