%COMPE565 Homework 2
%Oct. 3, 2019
%Name: Seanmark Paz
%ID: 820246863
%Email: spaz@sdsu.edu

function reconstructedRGB = QandDCT(image)
%Storing rgb components of image in rgbImage
rgbImage = image;

%Finding dimensions of image
[rows, cols, colorBands] = size(rgbImage);

%Dividing up the image into 8x8 blocks for processing
blockSizeR = 8;
blockSizeC = 8;

%Using mat2cell in order to divide image into blocks
%Finding size of each block in rows
wholeBlockRows = floor(rows / blockSizeR);
blockVectorR = (blockSizeR * ones(1, wholeBlockRows));

%Finding size of each block in columns
wholeBlockCols = floor(cols / blockSizeC);
blockVectorC = (blockSizeC * ones(1, wholeBlockCols));

%Creating array of blocks
blockArray = mat2cell(rgbImage, blockVectorR, blockVectorC, colorBands);
[blockRows, blockCols, blockColors] = size(blockArray);

%Using dct2 to create array of DCT blocks
dctBlockArray = cell(blockRows, blockCols, blockColors);
for rows = 1:blockRows
    for cols = 1:blockCols
        temp1 = cell2mat(blockArray(rows, cols));
        temp1 = double(temp1(:, :, 1));
        temp1 = temp1 - 128;
        temp1 = dct2(temp1);
        
        temp2 = cell2mat(blockArray(rows, cols));
        temp2 = double(temp2(:, :, 2));
        temp2 = temp2 - 128;
        temp2 = dct2(temp2);
        
        temp3 = cell2mat(blockArray(rows, cols));
        temp3 = double(temp3(:, :, 3));
        temp3 = temp3 - 128;
        temp3 = dct2(temp3);
        
        dctBlockArray(rows, cols) = {cat(3, temp1, temp2, temp3)};
    end
end

%displaying dct blocks 22 and 23 in row 30 to command window
% disp('Block 22 DCT Coefficients:')
% celldisp(dctBlockArray(30,22))
% disp('Block 23 DCT Coefficients:')
% celldisp(dctBlockArray(30,23))

%displaying luminance component of dct blocks 22 and 23 in row 30
% dct3022 = cell2mat(dctBlockArray(30,22));
% dct3023 = cell2mat(dctBlockArray(30,23));
% figure('Name', 'Image 30,22'), imshow(dct3022(:, :, 1))
% figure('Name', 'Image 30,23'), imshow(dct3023(:, :, 1))

%Creating quantization matrices from lecture notes
Q = 28;

%Quantizing DCT coefficients
quantizedArray = cell(blockRows, blockCols);
for rows = 1:blockRows
    for cols = 1:blockCols
        temp = cell2mat(dctBlockArray(rows, cols));
        
        %Separating each component to quantize
        D1 = temp(:, :, 1);
        D2 = temp(:, :, 2);
        D3 = temp(:, :, 3);
        
        %Quantizing each component
        C1 = round(D1 / Q);
        C2 = round(D2 / Q);
        C3 = round(D3 / Q);
        
        %Combining all components back into one block
        C = cat(3, C1, C2, C3);
        
        %Creating new matrix of quantized blocks
        quantizedArray(rows, cols) = {C};
    end
end

%Displaying blocks 22 and 23 DC luminance component
% temp22 = cell2mat(quantizedArray(30,22));
% disp('Block 22 DC Luminance Component:')
% disp(temp22(1, 1, 1));
% temp23 = cell2mat(quantizedArray(30,23));
% disp('Block 23 DC Luminance Component:')
% disp(temp23(1, 1, 1));

%Creating vector of zig zag scanned coefficients
%Referenced code from this link:
%https://www.mathworks.com/matlabcentral/fileexchange/56332-zigzag-scan-any-n-n-matrix-bloc-of-image

%Block 22
% [~, N] = size(temp22(:, :, 1));
% vect = zeros(1, N*N);
% vect(1) = temp22(1, 1);
% v = 1;
% for k = 1:2*N-1
%     if k <= N
%         if mod(k,2) == 0
%         j = k;
%         for i = 1:k
%             vect(v) = temp22(i, j, 1);
%             v = v + 1; j = j - 1;
%         end
%         else
%             i = k;
%             for j = 1:k
%                 vect(v) = temp22(i, j, 1);
%                 v = v + 1; i = i - 1;
%             end
%         end
%     else
%         if mod(k, 2) == 0
%             p = mod(k, N); j = N;
%         for i = p + 1:N
%             vect(v) = temp22(i, j, 1);
%             v = v + 1; j = j - 1;
%         end
%         else
%             p = mod(k, N); i = N;
%             for j = p + 1:N
%                 vect(v) = temp22(i, j, 1);
%                 v = v + 1;i = i - 1;
%             end
%         end
%     end
% end

% disp('Block 22 Zig Zag Scanned Coefficients:')
% disp(vect)

%Block 23
% [~, N] = size(temp23(:, :, 1));
% vect = zeros(1, N*N);
% vect(1) = temp23(1, 1);
% v = 1;
% for k = 1:2*N-1
%     if k <= N
%         if mod(k,2) == 0
%         j = k;
%         for i = 1:k
%             vect(v) = temp23(i, j, 1);
%             v = v + 1; j = j - 1;
%         end
%         else
%             i = k;
%             for j = 1:k
%                 vect(v) = temp23(i, j, 1);
%                 v = v + 1; i = i - 1;
%             end
%         end
%     else
%         if mod(k, 2) == 0
%             p = mod(k, N); j = N;
%         for i = p + 1:N
%             vect(v) = temp23(i, j, 1);
%             v = v + 1; j = j - 1;
%         end
%         else
%             p = mod(k, N); i = N;
%             for j = p + 1:N
%                 vect(v) = temp23(i, j, 1);
%                 v = v + 1;i = i - 1;
%             end
%         end
%     end
% end

% disp('Block 23 Zig Zag Scanned Coefficients:')
% disp(vect)

%Inverse Quantization
dequantizedArray = cell(blockRows, blockCols);
for rows = 1:blockRows
    for cols = 1:blockCols
        temp = cell2mat(quantizedArray(rows, cols));
        C1 = temp(:, :, 1);
        C2 = temp(:, :, 2);
        C3 = temp(:, :, 3);
        
        D1 = round(C1 * Q);
        D2 = round(C2 * Q);
        D3 = round(C3 * Q);
        
        D = cat(3, D1, D2, D3);
        
        dequantizedArray(rows, cols) = {D};
    end
end

%Inverse DCT
invDctBlockArray = cell(blockRows, blockCols);
for rows = 1:blockRows
    for cols = 1:blockCols
        temp = cell2mat(dequantizedArray(rows, cols));
        temp1 = idct2(temp(:, :, 1)) + 128;
        
        temp2 = idct2(temp(:, :, 2)) + 128;
        
        temp3 = idct2(temp(:, :, 3)) + 128;
        
        
        invDctBlockArray(rows, cols) = {cat(3, temp1, temp2, temp3)};
    end
end

%Displaying final reconstructed RGB image
reconstructedRGB = uint8(cell2mat(invDctBlockArray));

% figure('Name', 'Final Image Comparison');
% subplot(1, 2, 1), imshow(rgbImage)
% title('RGB Image')
% subplot(1, 2, 2), imshow(reconstructedRGB)
% title('Reconstructed RGB Image')
%
% %Displaying error image
% error = double(rgbImage) - double(reconstructedRGB);
% figure('Name', 'Error Image'), imshow(error)
% title('Error Image')

%Computing PSNR of image
% MSEarray = rgbImage - reconstructedRGB;
% MSEvar = sum(sum(sum(MSEarray.^2)));
% MSE = (1/(640*480))*MSEvar;
% PSNR = 10*log(((255)^2)/MSE)
end
