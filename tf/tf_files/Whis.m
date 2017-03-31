%% Start Python Script and TCP Socket
%py.scratch.get_targets(strcat(pwd, '/testImages/'))

t = tcpip('localhost', 9999);
fopen(t);
serverdata = strcat("dir ", pwd, '/testImages/');
fwrite(t, serverdata);
%fscanf(t)
%fclose(t);

% udp1 = udp('localhost', 9995);
% fopen(udp1);
% fprintf(udp1, 'Sending from Matlab');
% 
% udp2 = udp('localhost', 10005);
% fopen(udp2);
% 
% while(true)
%     fscanf(udp2)
% end


%% IMAGE SELECTION

imagename = 'test17.jpg';
imagedir = strcat('testImages/', imagename);

img = imread(imagedir);

% Use mode 0 and writeEnable 1 for competition =)

%% PRE-IMAGE PROCESSING
% Standard for all images(no initial crop)

% Best/Optimal Pre-Processing
filter = .18;
interEdges = coloredges(img);
interEdges = interEdges / max(interEdges(:));
                                                                                                                                                                                                                                                                                                                    
% Special Crop to fix ffmpeg capture
topCut = 10;
bottomCut = 12;
leftCut = 10;
rightCut = 10;
[height, width] = size(interEdges);

 interEdges = imcrop(interEdges,[leftCut topCut width-leftCut-rightCut height-bottomCut-topCut] );
 img = imcrop(img,[leftCut topCut width-leftCut-rightCut height-bottomCut-topCut] );
imgGray = rgb2gray(img);

BWimgMask = edge(interEdges,'canny', .3);
%BWimg = edge(imgGray,'canny', .4);

% Used to fill small holes/discontinuities
se10 = strel('square', 10);
se5 = strel('square', 5);

% thisImageThick is used to determine the boundary of a blob after dilating to fill holes (not displayed though)
thisImageThick = imdilate(BWimgMask,se5);


blobs = regionprops(thisImageThick, 'BoundingBox');

z = 1;

%% LOOPING THROUGH BLOBS
while z <= length(blobs)
    boundary = blobs(z).BoundingBox;
    
    % Crop it out of the original gray scale image.
    % thisBlob = imcrop(BWimg, boundary + [-3 -3 6 6]);
    thisBlob = imcrop(img, boundary + [-3 -3 6 6]);
    
    
%     if numberOfWhite < 80
%         z = z + 1;
%         continue;
%     end
    
%    [height, width] = size(thisBlob);
    %imshow(thisBlob);
%     thisBlob = bwareaopen(thisBlob, 50);
    %thisBlob = imdilate(thisBlob,se2);
        
    z = z + 1;
    
    strBoundary = string(boundary);
    serverdata = strcat("blob ", imagename, " ", strBoundary(1), " ", strBoundary(2), " ", strBoundary(3), " ", strBoundary(4));
    fwrite(t, serverdata);
    
    fprintf('Processed a blob\n')
%     shape = py.pyZeno.get_targets(imagedir, boundary);
%     
%     
%     shape = char(shape);
%     figure
%     imshow(thisBlob)
%     if(strcmp(shape, 'Unknown'))
%         close;
%     else
%         title(shape);
%     end
    
end

fprintf('Done!')