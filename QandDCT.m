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

end
