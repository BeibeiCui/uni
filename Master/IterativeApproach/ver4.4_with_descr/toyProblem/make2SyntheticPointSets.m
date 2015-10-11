% based on Minsu Cho, makePointMatchingProblem, MPM_release_v1

%% make 2 synthetic graphs for testing graph matching algorithm
% Output
%   G1 = (V,D,E) first graph;  NOTE: D = []
%   G2 = (V,D,E) second graph; NOTE: D = []
%   GT = (LLpairs) ground thruth for matching on each of two
%                           levels

function [img1, img2, G1, G2, GT] = make2SyntheticPointSets()

%     rng('default');
    setParameters_syntheticPointSets;
        
    % create two empty images
    img1 = repmat(ones(s,s),1,1,3);
    img2 = repmat(ones(s,s),1,1,3);
    
    
    if bOutBoth
      n1 = nIn + nOut;		% number of nodes in the first set
    else
      n1 = nIn;
    end       
    n2 = nIn + nOut;    % number of nodes in the second set
    
    %% Generate Nodes
    switch typeDistribution
	case 'normal', V1 = F*randn(n1, 2); Pout = F*randn(nOut, 2); 
	case 'uniform', V1 = F*rand(n1, 2); Pout = F*rand(nOut, 2); 
	otherwise, disp(''); error('Insert Point Distribution');
    end
    % rotation matrix
    rotMatrix = [cos(aff_transfo_angle) -sin(aff_transfo_angle); ... 
                 sin(aff_transfo_angle)  cos(aff_transfo_angle)];    

    V2 = aff_transfo_scale * V1 * rotMatrix + sig*F*randn(n1, 2); % apply transformation to the nodes of the first graph

    if bOutBoth
      V2((nIn+1):end, :) = Pout;
    else 
      V2 = [V2;Pout]; 
    end
    
    % permute graph sequence (prevent accidental good solution)
    if bPermute
      seq = randperm(n2);
      V2(seq,:) = V2;
      seq = seq(1:n1);
    else 
      seq = 1:n1;
    end
    
    %% 2nd Order Matrix
    E1 = ones(n1); E1(1:size(E1,1)+1:end) = 0;
    [L1(:,1), L1(:,2)] = find(E1);
    L1 = unique(sort(L1,2), 'rows');  % delete same edges
    
    % omit (1-edgeDen)% of edges
    nOmit1 = round(n1*(n1-1)*(1-edge_den)/2); 
    ind_omit1 = datasample(1:size(L1,1), nOmit1, 'Replace',false)';
    L1(ind_omit1,:) = [];

    
    E2 = ones(n2); E2(1:size(E2,1)+1:end) = 0;
    [L2(:,1), L2(:,2)] = find(E2);
    L2 = unique(sort(L2,2), 'rows');  % delete same edges
    
    % omit (1-edgeDen)% of edges
    nOmit2 = round( n2*(n2-1)*(1-edge_den)/2); 
    ind_omit2 = datasample(1:size(L2,1), nOmit2, 'Replace',false)';
    L2(ind_omit2,:) = [];
    
    
    % create first graphs
    G1.V = V1;
    G1.D = [];
    G1.E = L1;
    G1.W = Inf*ones(n1,1);

    % create first graphs
    G2.V = V2;
    G2.D = [];
    G2.E = L2;
    G2.W = Inf*ones(n2,1);
      
    % Ground Truth
    GT.LLpairs = [ [1:n1]'  , seq'];
    GT.HLpairs = [];
    
    % shift coordinates of the nodes to plot it nicer    
    min_x = min([ min(G1.V(:,1)), min(G2.V(:,1)) ]);
    max_x = max([ max(G1.V(:,1)), max(G2.V(:,1)) ]);
    
    min_y = min([ min(G1.V(:,2)), min(G2.V(:,2)) ]);
    max_y = min([ max(G1.V(:,2)), max(G2.V(:,2)) ]);
    
    G1.V(:,1) = b + (G1.V(:,1) - min_x) * (s-2*b) / (max_x-min_x);
    G1.V(:,2) = b +(G1.V(:,2) - min_y) * (s-2*b) / (max_y-min_y);
    
    G2.V(:,1) = b + (G2.V(:,1) - min_x) * (s-2*b) / (max_x-min_x);
    G2.V(:,2) = b + (G2.V(:,2) - min_y) * (s-2*b) / (max_y-min_y);
    
    
end