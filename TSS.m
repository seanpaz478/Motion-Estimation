%COMPE565 Homework 4
%Nov. 21, 2019
%Name: Seanmark Paz
%ID: 820246863
%Email: spaz@sdsu.edu

%Three Step Search Algorithm:
%Start with search location at center, (0,0)
%Set step size S = 4
%Search 8 locations +/- S pixels around location (0,0)
%Pick among 9 locations with minimum cost function
%Set new search origin to above picked location
%Set new step size to S = S/2
%Repeat search procedure until S = 1

function TSSReconstructedFrames = TSS(frames)

[vFrameRows, vFrameCols, vFrameColors, vFrameNum] = size(frames);
TSSReconstructedFrames = zeros(vFrameRows, vFrameCols, vFrameColors, vFrameNum);

for i = 1:1
    iFrame = frames(:, :, :, i);
    TSSReconstructedFrames(:, :, 1, i) = iFrame(:, :, 1);
    pFrame = frames(:, :, :, i + 1);
    r_block = cell((vFrameRows / 16), (vFrameCols / 16));
    %Counter variables for assembling reconstructed frame
    rx = 1;
    ry = 1;
    %Counter variable for coordinate arrays
    k = 1;
    %Arrays to hold coordinates of reference frame
    x1 = [];
    y1 = [];
    %Arrays to hold coordinates of pframe
    x2 = zeros(2, 1, 16);
    y2 = zeros(2, 1, 16);
    for frameCols = 1:16:vFrameCols
        for frameRows = 1:16:vFrameRows
            %use I block to process P block
            %search window: frames((rows - 8):(rows + 23), (cols - 8):(cols + 23))
            %Changing search window size based on where it is in the frame
            if(frameRows - 8 < 1)
                %do searching only below
                rowStart = frameRows;
            else
                rowStart = frameRows - 8;
            end
            
            if(frameCols - 8 < 1)
                %do searching only to the right
                colStart = frameCols;
            else
                colStart = frameCols - 8;
            end
            
            if(frameRows + 23 > vFrameRows)
                %do searching only above
                if(frameRows + 15 > vFrameRows)
                    rowEnd = frameRows + 8;
                else
                    rowEnd = frameRows + 15;
                end
            else
                rowEnd = frameRows + 23;
            end
            
            if(frameCols + 23 > vFrameCols)
                %do searching only to the left
                if(frameCols + 15 > vFrameCols)
                    colEnd = frameCols + 8;
                else
                    colEnd = frameCols + 15;
                end
            else
                colEnd = frameCols + 23;
            end
            
            %Searching search window using three step search with initial
            %step size of 4
            %variables to hold coordinates of best matched MB in ref frame
            refx = frameRows;
            refy = frameCols;
            currentMB = pFrame((frameRows:(frameRows + 15)), (frameCols:(frameCols + 15)), 1);
            refMB = iFrame((frameRows:(frameRows + 15)), (frameCols:(frameCols + 15)), 1);
            diffMat = zeros(16, 16);
            step = 4;
            
            %Current block in ref is assigned as best match initially
            diffMat = double(refMB) - double(currentMB);
            MAD = abs(sum(diffMat, 'all'));
            
            %Doing Three Step Search here
            
            %This while loop will continue searching and lowering the step
            %size to find the best match according to the TSS algorithm
            while(step >= 1)
                for j = 1:8
                    switch j
                        case 1
                            %(x-step, y) ref block to the left of pframe block
                            if(frameRows - step > rowStart)
                                refMB1 = iFrame((frameRows - step:(frameRows - step + 15)), (frameCols:(frameCols + 15)), 1);
                                diffMat = double(refMB1) - double(currentMB);
                                tempMAD = abs(sum(diffMat, 'all'));
                                if(tempMAD < MAD)
                                    MAD = tempMAD;
                                    refx = frameRows - step;
                                    refy = frameCols;
                                end
                            end
                            
                        case 2
                            %(x-step, y-step) ref block to the upper left of pframe block
                            if(frameRows - step > rowStart && frameCols - step > colStart)
                                refMB2 = iFrame((frameRows - step:(frameRows - step + 15)), (frameCols - step:(frameCols - step + 15)), 1);
                                diffMat = double(refMB2) - double(currentMB);
                                tempMAD = abs(sum(diffMat, 'all'));
                                if(tempMAD < MAD)
                                    MAD = tempMAD;
                                    refx = frameRows - step;
                                    refy = frameCols - step;
                                end
                            end
                        case 3
                            %(x, y-step) ref block to the top of pframe block
                            if(frameCols - step > colStart)
                                refMB3 = iFrame((frameRows:(frameRows + 15)), (frameCols - step:(frameCols - step + 15)), 1);
                                diffMat = double(refMB3) - double(currentMB);
                                tempMAD = abs(sum(diffMat, 'all'));
                                if(tempMAD < MAD)
                                    MAD = tempMAD;
                                    refx = frameRows;
                                    refy = frameCols - step;
                                end
                            end
                        case 4
                            %(x+step, y+step) ref block to the upper right of pframe block
                            if(frameRows - step > rowStart && frameCols + step + 15 < colEnd)
                                refMB4 = iFrame((frameRows - step:(frameRows - step + 15)), (frameCols + step:(frameCols + step + 15)), 1);
                                diffMat = double(refMB4) - double(currentMB);
                                tempMAD = abs(sum(diffMat, 'all'));
                                if(tempMAD < MAD)
                                    MAD = tempMAD;
                                    refx = frameRows - step;
                                    refy = frameCols + step;
                                end
                            end
                        case 5
                            %(x+step, y) ref block to the right of pframe block
                            if(frameCols + step + 15 < colEnd)
                                refMB5 = iFrame((frameRows:(frameRows + 15)), (frameCols + step:(frameCols + step + 15)), 1);
                                diffMat = double(refMB5) - double(currentMB);
                                tempMAD = abs(sum(diffMat, 'all'));
                                if(tempMAD < MAD)
                                    MAD = tempMAD;
                                    refx = frameRows;
                                    refy = frameCols + step - 1;
                                end
                            end
                        case 6
                            %(x+step, y - step) ref block to the lower right of pframe block
                            if(frameRows + step + 15 < rowEnd && frameCols + step + 15 < colEnd)
                                refMB6 = iFrame((frameRows + step:(frameRows + step  + 15)), (frameCols + step:(frameCols + step + 15)), 1);
                                diffMat = double(refMB6) - double(currentMB);
                                tempMAD = abs(sum(diffMat, 'all'));
                                if(tempMAD < MAD)
                                    MAD = tempMAD;
                                    refx = frameRows + step - 1;
                                    refy = frameCols + step - 1;
                                end
                            end
                        case 7
                            %(x, y-tep) ref block to the bottom of pframe block
                            if(frameRows + step + 15 < rowEnd)
                                refMB7 = iFrame((frameRows + step:(frameRows + step + 15)), (frameCols:(frameCols + 15)), 1);
                                diffMat = double(refMB7) - double(currentMB);
                                tempMAD = abs(sum(diffMat, 'all'));
                                if(tempMAD < MAD)
                                    MAD = tempMAD;
                                    refx = frameRows + step;
                                    refy = frameCols;
                                end
                            end
                        case 8
                            %(x+step, y-step) ref block to the bottom left of pframe block
                            if(frameRows + step + 15 < rowEnd && frameCols - step > colStart)
                                refMB8 = iFrame((frameRows + step:(frameRows + step  + 15)), (frameCols - step:(frameCols - step + 15)), 1);
                                diffMat = double(refMB8) - double(currentMB);
                                tempMAD = abs(sum(diffMat, 'all'));
                                if(tempMAD < MAD)
                                    MAD = tempMAD;
                                    refx = frameRows + step;
                                    refy = frameCols - step;
                                end
                            end
                    end
                end
                step = step / 2;
            end
            
            %After best matching MB is found, save the matching MB for
            %reconstruction later
            r_block(rx, ry) = {iFrame((refx:refx + 15), (refy:refy + 15), 1)};
            if(rx == (vFrameRows / 16))
                rx = 1;
                ry = ry + 1;
            else
                rx = rx + 1;
            end
        end
    end
    reconstructed_frame = cell2mat(r_block);
    reconstructed_frame = cat(3, reconstructed_frame, pFrame(:, :, 2:3));
    TSSReconstructedFrames(:, :, :, i + 1) = reconstructed_frame;
end
%Doing TSS to reconstruct the rest of the frames

for i = 2:4
    iFrame = reconstructed_frame;
    pFrame = frames(:, :, :, i + 1);
    r_block = cell((vFrameRows / 16), (vFrameCols / 16));
    %Counter variables for assembling reconstructed frame
    rx = 1;
    ry = 1;
    %Counter variable for coordinate arrays
    k = 1;
    %Arrays to hold coordinates of reference frame
    x1 = [];
    y1 = [];
    %Arrays to hold coordinates of pframe
    x2 = zeros(2, 1, 16);
    y2 = zeros(2, 1, 16);
    for frameCols = 1:16:vFrameCols
        for frameRows = 1:16:vFrameRows
            %use I block to process P block
            %search window: frames((rows - 8):(rows + 23), (cols - 8):(cols + 23))
            %Changing search window size based on where it is in the frame
            if(frameRows - 8 < 1)
                %do searching only below
                rowStart = frameRows;
            else
                rowStart = frameRows - 8;
            end
            
            if(frameCols - 8 < 1)
                %do searching only to the right
                colStart = frameCols;
            else
                colStart = frameCols - 8;
            end
            
            if(frameRows + 23 > vFrameRows)
                %do searching only above
                if(frameRows + 15 > vFrameRows)
                    rowEnd = frameRows + 8;
                else
                    rowEnd = frameRows + 15;
                end
            else
                rowEnd = frameRows + 23;
            end
            
            if(frameCols + 23 > vFrameCols)
                %do searching only to the left
                if(frameCols + 15 > vFrameCols)
                    colEnd = frameCols + 8;
                else
                    colEnd = frameCols + 15;
                end
            else
                colEnd = frameCols + 23;
            end
            
            %Searching search window using three step search with initial
            %step size of 4
            %variables to hold coordinates of best matched MB in ref frame
            refx = frameRows;
            refy = frameCols;
            currentMB = pFrame((frameRows:(frameRows + 15)), (frameCols:(frameCols + 15)), 1);
            refMB = iFrame((frameRows:(frameRows + 15)), (frameCols:(frameCols + 15)), 1);
            diffMat = zeros(16, 16);
            step = 4;
            
            %Current block in ref is assigned as best match initially
            diffMat = double(refMB) - double(currentMB);
            MAD = abs(sum(diffMat, 'all'));
            
            %Doing Three Step Search here
            
            %This while loop will continue searching and lowering the step
            %size to find the best match according to the TSS algorithm
            while(step >= 1)
                for j = 1:8
                    switch j
                        case 1
                            %(x-step, y) ref block to the left of pframe block
                            if(frameRows - step > rowStart)
                                refMB1 = iFrame((frameRows - step:(frameRows - step + 15)), (frameCols:(frameCols + 15)), 1);
                                diffMat = double(refMB1) - double(currentMB);
                                tempMAD = abs(sum(diffMat, 'all'));
                                if(tempMAD < MAD)
                                    MAD = tempMAD;
                                    refx = frameRows - step;
                                    refy = frameCols;
                                end
                            end
                            
                        case 2
                            %(x-step, y-step) ref block to the upper left of pframe block
                            if(frameRows - step > rowStart && frameCols - step > colStart)
                                refMB2 = iFrame((frameRows - step:(frameRows - step + 15)), (frameCols - step:(frameCols - step + 15)), 1);
                                diffMat = double(refMB2) - double(currentMB);
                                tempMAD = abs(sum(diffMat, 'all'));
                                if(tempMAD < MAD)
                                    MAD = tempMAD;
                                    refx = frameRows - step;
                                    refy = frameCols - step;
                                end
                            end
                        case 3
                            %(x, y-step) ref block to the top of pframe block
                            if(frameCols - step > colStart)
                                refMB3 = iFrame((frameRows:(frameRows + 15)), (frameCols - step:(frameCols - step + 15)), 1);
                                diffMat = double(refMB3) - double(currentMB);
                                tempMAD = abs(sum(diffMat, 'all'));
                                if(tempMAD < MAD)
                                    MAD = tempMAD;
                                    refx = frameRows;
                                    refy = frameCols - step;
                                end
                            end
                        case 4
                            %(x+step, y+step) ref block to the upper right of pframe block
                            if(frameRows - step > rowStart && frameCols + step + 15 < colEnd)
                                refMB4 = iFrame((frameRows - step:(frameRows - step + 15)), (frameCols + step:(frameCols + step + 15)), 1);
                                diffMat = double(refMB4) - double(currentMB);
                                tempMAD = abs(sum(diffMat, 'all'));
                                if(tempMAD < MAD)
                                    MAD = tempMAD;
                                    refx = frameRows - step;
                                    refy = frameCols + step;
                                end
                            end
                        case 5
                            %(x+step, y) ref block to the right of pframe block
                            if(frameCols + step + 15 < colEnd)
                                refMB5 = iFrame((frameRows:(frameRows + 15)), (frameCols + step:(frameCols + step + 15)), 1);
                                diffMat = double(refMB5) - double(currentMB);
                                tempMAD = abs(sum(diffMat, 'all'));
                                if(tempMAD < MAD)
                                    MAD = tempMAD;
                                    refx = frameRows;
                                    refy = frameCols + step - 1;
                                end
                            end
                        case 6
                            %(x+step, y - step) ref block to the lower right of pframe block
                            if(frameRows + step + 15 < rowEnd && frameCols + step + 15 < colEnd)
                                refMB6 = iFrame((frameRows + step:(frameRows + step  + 15)), (frameCols + step:(frameCols + step + 15)), 1);
                                diffMat = double(refMB6) - double(currentMB);
                                tempMAD = abs(sum(diffMat, 'all'));
                                if(tempMAD < MAD)
                                    MAD = tempMAD;
                                    refx = frameRows + step - 1;
                                    refy = frameCols + step - 1;
                                end
                            end
                        case 7
                            %(x, y-tep) ref block to the bottom of pframe block
                            if(frameRows + step + 15 < rowEnd)
                                refMB7 = iFrame((frameRows + step:(frameRows + step + 15)), (frameCols:(frameCols + 15)), 1);
                                diffMat = double(refMB7) - double(currentMB);
                                tempMAD = abs(sum(diffMat, 'all'));
                                if(tempMAD < MAD)
                                    MAD = tempMAD;
                                    refx = frameRows + step;
                                    refy = frameCols;
                                end
                            end
                        case 8
                            %(x+step, y-step) ref block to the bottom left of pframe block
                            if(frameRows + step + 15 < rowEnd && frameCols - step > colStart)
                                refMB8 = iFrame((frameRows + step:(frameRows + step  + 15)), (frameCols - step:(frameCols - step + 15)), 1);
                                diffMat = double(refMB8) - double(currentMB);
                                tempMAD = abs(sum(diffMat, 'all'));
                                if(tempMAD < MAD)
                                    MAD = tempMAD;
                                    refx = frameRows + step;
                                    refy = frameCols - step;
                                end
                            end
                    end
                end
                step = step / 2;
            end
            
            %After best matching MB is found, save the matching MB for
            %reconstruction later
            r_block(rx, ry) = {iFrame((refx:refx + 15), (refy:refy + 15), 1)};
            if(rx == (vFrameRows / 16))
                rx = 1;
                ry = ry + 1;
            else
                rx = rx + 1;
            end
        end
    end
    reconstructed_frame = cell2mat(r_block);
    reconstructed_frame = cat(3, reconstructed_frame, pFrame(:, :, 2:3));
    TSSReconstructedFrames(:, :, :, i + 1) = reconstructed_frame;
    
end
end