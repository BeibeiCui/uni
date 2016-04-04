
clear all
close all


%% Set parameters


% VL_Library

VLFEAT_Toolbox = ['..' filesep '..' filesep '..' filesep 'vlfeat-0.9.19' filesep 'toolbox' ];
addpath(genpath(VLFEAT_Toolbox));

run vl_setup.m

clc;

SetParameters;

%%
%% read images

[image, imagefiles] = readImages();  % cell of the images

%% Reference image
% Select a reference image
img1 = 1;
%%

 N = 1;
 N = size(image, 2);

% cell of the keypoints-matrices
framesCell = cell(1,N); % Nx(4xK1) matrices

% cell of the descriptors-matrices
descrCell = cell(1,N); % Nx(128xK1) matrices

% number of interest points in each image
nV= zeros(N,1);

%%

for i = 1 : N
    
    img = image{i};      
   
    %% find point of interest (nodes of the graph)
    tic
    
    if i==1
        [ framesCell{i}, descrCell{i}, nV(i) ] = find_features_harlap_vl(img, true, 30);
    else
        [ framesCell{i}, descrCell{i}, nV(i) ] = find_features_harlap_vl(img, false);
    end
    
    fprintf(' %f secs elapsed for finding %d interest points on the image %d \n', ...
                        toc, nV(i) , i);
        
    f = figure;
        imagesc(img),colormap(gray);
        title(sprintf('Image %d', i));
        hold on;     
        h1 = vl_plotframe(framesCell{i});
        set(h1,'color','y','linewidth', 2) ;
        
        h3 = vl_plotsiftdescriptor(descrCell{i},framesCell{i}) ;
        set(h3,'color','g') ;
    hold off;

end


 %% try to match

v1 = framesCell{1}(1:2,:);

for i = 2 : N
    
    v2 = framesCell{i}(1:2,:);

    
    matchInfo = make_initialmatches2(descrCell{1},descrCell{i}, mparam); 
    
    corrMatrix = zeros(nV(1),nV(i));
    for ii = 1:size(matchInfo.match,2)
        corrMatrix(matchInfo.match(1,ii), matchInfo.match(2,ii) ) = 1;
    end

    plotMatches(double(image{1})/256,double(image{i})/256, v1', v2', corrMatrix, ...
                                                imagefiles(i).name,1);                                            
end  
