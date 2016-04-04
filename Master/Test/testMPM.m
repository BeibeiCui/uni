
clear all
close all


%% Set parameters

% MPM code
addpath(genpath(['..' filesep 'MPM_release_v1']));

% VL_Library

VLFEAT_Toolbox = ['..' filesep '..' filesep 'vlfeat-0.9.19' filesep 'toolbox' ];
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

% select rectangle region on the reference image

f = figure;
    imagesc(image{img1}),colormap(gray);
    title('Reference Image');
    hold on;     
    rect = getrect;    
hold off;

img1cut = imcrop(image{img1},rect);

xmin = rect(1,1);
ymin = rect(1,2);
%%

N = 5;

% cell of the keypoints-matrices
framesCell = cell(1,N); % Nx(4xK1) matrices

% cell of the descriptors-matrices
descrCell = cell(1,N); % Nx(128xK1) matrices

% number of interest points in each image
nV= zeros(N,1);

% Cell of the adjazent matrices on each image
adjCell = cell(1,N); % nV_i x nV_i

%%


minDeg = 2;

for i = 1 : N
    
    img = image{i};     

    %% find point of interest (nodes of the graph)
    tic
    
    if (i==1)
        [ framesCell{i}, descrCell{i}, nV(i) ] = find_features(img1cut, xmin, ymin);
    else
        [ framesCell{i}, descrCell{i}, nV(i) ] = find_features(img);
    end
    
     fprintf(' %f secs elapsed for finding %d interest points on the image %d \n', ...
                        toc, nV(i) , i);
    
    %% build a dependency graph on each image
    
    tic
    
    [adjMatrixInd, ~] = knnsearch(framesCell{i}(1:2,:)', ....
                                  framesCell{i}(1:2,:)', 'k', minDeg + 1);                       
    adjMatrixInd = adjMatrixInd(:,2:end); % delete loops in each vertex (first column of the matrix)
    
    adjMatrix = zeros(nV(i),nV(i));
    for v= 1 : nV(i)
        adjMatrix(v, adjMatrixInd(v,:)) =  1;
    end
    adjCell{i} = adjMatrix;
    
    fprintf(' %f secs elapsed for building an image graph with %d nodes and minDeg = %d\n', ...
                        toc, nV(i), minDeg);
                    
                    
    %%  draw graph
    if i==1
        draw_graph(img, imagefiles(i).name, framesCell{i}, adjMatrix, [1:nV(i)],...
                                                    'saveImage', 'false');
    end

end

% close all;


%%  MPM

% first image is a reference image
% second image is a target image  

img1 = 1;

v1 = framesCell{img1}(1:2,:);
v1=v1';
nV1 = nV(img1,1);
 
Objective = zeros(1, N);

for img2 = 2:N
    
    v2 = framesCell{img2}(1:2,:);
    v2=v2';
    nV2 = nV(img2,1);

    %% initial correspondence Matrix nV1 x nV2
%     nCorr = nV2;
%     [corrMatrixInd, ~ ] = knnsearch(descrCell{img2}', descrCell{img1}','k', nCorr);

%     corrMatrix = ones(nV1,nV2);
%     for v= 1 : nV1
%         corrMatrix(v, corrMatrixInd(v,:)) =  1;
%     end

%     plotMatches(double(image{img1})/256,double(image{img2})/256, v1, v2, corrMatrix, ...
%                                                 imagefiles(img2).name,1);

    matchInfo =  make_initialmatches(descrCell{img1}, descrCell{img2}, mparam);
    
    corrMatrix = zeros(nV1,nV2);
    for ii = 1:size(matchInfo.match,2)
        corrMatrix(matchInfo.match(1,ii), matchInfo.match(2,ii) ) = 1;
    end
    
    [ uniq_feat2, tmp, new_feat2 ] = unique(matchInfo.match(2,:));
    % uniq_feat2 = matchInfo.match(2,tmp)
    %  matchInfo.match(2,:) = uniq_feat2(new_feat2);
    
    cand_matchlist_uniq = [ matchInfo.match(1,:); new_feat2' ]; % pairs (feat1, feat2) for each match 
    
    
    plotMatches(double(image{img1})/256,double(image{img2})/256, v1, v2, corrMatrix, ...
                                                imagefiles(img2).name,1);    
                                            
    draw_graph(image{img2}, imagefiles(img2).name, framesCell{img2}(1:2,:), adjCell{img2}, uniq_feat2,...
                                                    'saveImage', 'true');
                                                

    
    %% conflict groups
    [ group1, group2 ] = make_group12(matchInfo.match(1:2,:));
    conflictMatrix = getConflictMatrix(group1, group2);

    %% affinity matrix

    nAffMatrix = size(matchInfo.match, 2);
    AffMatrix = zeros(nAffMatrix);

    % node similarity (diagonal elements of the affinity matrix)
    AffMatrix(1:nAffMatrix+1:end) = matchInfo.sim(:);

    % edge similarity (non-diagonal elements of the affinity matrix)

    Adj1 = adjCell{img1};
    Adj2 = adjCell{img2};

    [IJ(:,1), IJ(:,2)] = find(Adj1);
    [AB(:,1), AB(:,2)] = find(Adj2);

    for ia = 1:nAffMatrix
        i = cand_matchlist_uniq(1, ia);
        a = cand_matchlist_uniq(2, ia);
        
        for jb = 1:nAffMatrix
            j = cand_matchlist_uniq(1, jb);
            b = cand_matchlist_uniq(2, jb);
            
            if (ismember([i, j], IJ, 'rows') && ismember([a, b], AB, 'rows'))
                
                var1 = sum( (framesCell{img1}(1:2, i) - framesCell{img1}(1:2, j)).^2,1);
                e_ij = sqrt(var1);

                var2 = sum( (framesCell{img2}(1:2, a) - framesCell{img2}(1:2, b)).^2,1);
                e_ab = sqrt(var2);

                AffMatrix(ia, jb) =  exp(-(e_ij-e_ab)^2/0.5); 
                
            end
            
        end
    end

    clear('AB'); 
    
    %% run MPM 
    
    x = MPM(AffMatrix, group1, group2);
    
    
    Objective(img2) = x'*AffMatrix * x;
    
    x = reshape(x, [nV1, nAffMatrix/nV1]);

    [XmaxRow, Ind]= max(x,[],2);
    newCorrMatrix = zeros(nV1, nV2);
    
    for i=1:nV1
        newCorrMatrix(i,cand_matchlist_uniq(2,Ind(i))) = XmaxRow(i);
    end;

    %% visialize results of matching
    plotMatches(image{img1},image{img2}, v1, v2, newCorrMatrix,...
                                            imagefiles(img2).name,2);
    

end

%%
% 
% %% save 5 best Matches
% 
% sourcePath = ['.' filesep 'results'];
% bestMatchesPath = ['.' filesep 'results' filesep 'bestMatches'];
% 
% imwrite(image{img1}, fullfile(bestMatchesPath,...
%             'ReferenceImage.jpg'));
% 
% [~, bestMatchesInd ] = sort(Objective,'descend');
%     
% for i=1:5
%     copyfile ( ...
%         fullfile(sourcePath, sprintf('result_%s-2.jpg',imagefiles(bestMatchesInd(i)).name)),...
%         fullfile(bestMatchesPath, sprintf('%s.jpg',imagefiles(bestMatchesInd(i)).name)));
% end

%%

pause

%%
close all
