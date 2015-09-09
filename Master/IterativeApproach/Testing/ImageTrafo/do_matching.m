% MATLAB demo code for testing different matching algorithm on two images
% written by E.Tikhoncheva, 08.09.2015

% BASED ON: MATLAB demo code of Max-Pooling Matching CVPR 2014
% M. Cho, J. Sun, O. Duchenne, J. Ponce
% Finding Matches in a Haystack: A Max-Pooling Strategy for Graph Matching in the Presence of Outliers 
% Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition (2014) 
% http://www.di.ens.fr/willow/research/maxpoolingmatching/
%
% Please cite our work if you find this code useful in your research. 
%
% written by Minsu Cho, Inria - WILLOW / Ecole Normale Superieure 
% http://www.di.ens.fr/~mcho/

clear all; close all; clc;
disp('************************ Image Matching Test ************************');disp(' ');

%% Settings Evaluations
setPath;
setMethods;

%% 
plotSet.lineWidth = 3; % Line width
plotSet.markerSize = 10; % Marker Size
plotSet.fontSize = 15; % Font Size
plotSet.font = '\fontname{Arial}'; % Font default

%% Select images
iparam.bShow = false;  % show detected features and initial matches ( it can takes long... )  

filepath = '/export/home/etikhonc/Documents/UniGit/uni/Master/data/img_trafo/set1/';

fname1 = 'sun_aafpznbwiqbmolft_a3.png'; % reference image
fname2 = 'sun_aafpznbwiqbmolft_b.png'; % reference image

%% storage for matching results
accuracy = zeros(1, length(methods));
score = zeros(1, length(methods));
time = zeros(1, length(methods));
X = cell(1, length(methods));
% Xraw = cell(1, length(methods));
perform_data = cell(1, length(methods));
scoreGrowth = zeros(1, length(methods));
inlierGrowth = zeros(1, length(methods));

%% Preprocessing
iparam.view(1).fileName = fname1(1:end-4);
iparam.view(1).filePathName = [filepath, fname1];

iparam.view(2).fileName = fname2(1:end-4);
iparam.view(2).filePathName = [filepath, fname2];

iparam.nView = 2;   iparam.bPair = 1;
  
% file with the saved GT
resultTag = [ iparam.view(1).fileName '+' iparam.view(2).fileName ];
initPathnFile = [ filepath '/' 'fi_' resultTag '.mat' ];

problem = makeProblem(iparam, initPathnFile);
% pr2LevelGM = makeProblem_elevelGM();

%% Test Methods
for i = 1:length(methods)
    str = sprintf('run_algorithm(''%s'', problem);', func2str(methods(i).fhandle));
    [accuracy(i), score(i), time(i), X{i}, perform_data{i}] = eval(str);
  
    fprintf('Algorithm:%s   Accuracy: %.3f Score: %.3f Time: %.3f\n',...
            func2str(methods(i).fhandle), accuracy(i), score(i), time(i));
    plotMatches(func2str(methods(i).fhandle), problem, accuracy(i), score(i), X{i});
end

%% Plot changes in Precision, Recall
cImg = 1;
% visPerformPlot;

%%
handleCount = 0;
yData = accuracy; yLabelText = 'accuracy'; plotResults;
yData = score; yLabelText = 'objective score'; plotResults;
yData = time; yLabelText = 'running time'; plotResults;