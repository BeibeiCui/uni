% LLG1, LLG2    two Lower Level Graphs, that should be matched
% LLGmatches    result of lower level graph matching (pairs of correspondence nodes)
% HLGmatches    result of higher level graph matching (pairs of correspondence nodes)
%

% Rule 1:
% if the aff.transformation between graphs is reliable, for all nodes in
% both subgraphs add their nearest neighbors (according to the transformattion)
% in the opposite subgraph

% Rule 2:
% If some subgraph consists of less than 3 nodes, assign the nodes of
% the subgraph to the anchor, to which the nearest neighbors of this nodes
% belong to

function [LLG1, LLG2, HLG1, HLG2] = rearrange_subgraphs10(LLG1, LLG2, HLG1, HLG2, ...
                                              LLGmatches, HLGmatches, affTrafo)
   fprintf('\n------ Rearrange subgraphs');
   error_eps = 1.0;
   
   
   nV1 = size(LLG1.V, 1);  nV2 = size(LLG2.V, 1);
   
   old_U1 = HLG1.U;
   old_U2 = HLG2.U;
   
   old_W1 = LLG1.W(:,end);
   old_W2 = LLG2.W(:,end);
   
   % nodes that weren't matched create zero lines in new_U1, new_U2
   new_U1 = old_U1.* repmat(exp(-old_W1), 1, size(HLG1.V, 1)); 
   new_U2 = old_U2.* repmat(exp(-old_W2), 1, size(HLG2.V, 1)); 
%    new_U1 = 0.5*double(old_U1); 
%    new_U2 = 0.5*double(old_U2); 
   
   % for each pairs of anchor matches ai<->aj estimate the best local
   % affine transformation
   nPairs = size(HLGmatches.matched_pairs,1); 
   for k=1:nPairs
       
        ai = HLGmatches.matched_pairs(k,1); % \in HLG1.V
        aj = HLGmatches.matched_pairs(k,2); % \in HLG2.V
       
        
        ind_Vai = find(HLG1.U(:,ai));
        ind_Vaj = find(HLG2.U(:,aj));
        
        [~, ind_matched_pairs] = ismember(ind_Vai, LLGmatches.matched_pairs(:,1));
        ind_matched_pairs = ind_matched_pairs(ind_matched_pairs>0);
        pairs = LLGmatches.matched_pairs(ind_matched_pairs,1:2);

        Vai = LLG1.V(ind_Vai,:);      % coordinates of the nodes in the subgraph G_ai
        Vaj = LLG2.V(ind_Vaj,:);      % coordinates of the nodes in the subgraph G_aj
        
        
        if (size(pairs, 1)>=3)
                          
            Ti = affTrafo.T(k, :);             % transformation from G_ai into G_aj
            Tj = affTrafo.Tinverse(k,:);       % transformation from G_aj into G_ai (inverse Ti)
            
            Ai = [[Ti(1) Ti(2)]; [Ti(3) Ti(4)]]; % transformation Tx = Ax+b
            bi = [ Ti(5); Ti(6)];
            
            Aj = [[Tj(1) Tj(2)]; [Tj(3) Tj(4)]];
            bj = [ Tj(5); Tj(6)];
            
            err = min(old_W1(ind_Vai));
%             err = sum(old_W1(ind_Vai))/numel(ind_Vai);
%             assert(err == old_W1(ind_Vai(1)), 'all nodes in the same subgraph should have the same weight');
            assert(err == min(old_W2(ind_Vaj)), 'nodes of matched subgraphs should have the same weight');
                        
            if (err<error_eps)  % Rule 1

                PVai = Ai * Vai' + repmat(bi,1,size(Vai,1)); % proejction of Vai_nm nodes
                PVai = PVai';
                PVaj = Aj * Vaj' + repmat(bj,1,size(Vaj,1)); % projection of Vaj_nm nodes
                PVaj = PVaj';

                % calculate the nearest neighbours of the projections and
                % include them into corresponding graphs
                [nn_PVai, ~] = knnsearch(LLG2.V, PVai);   %indices of nodes in LLG2.V
                [nn_PVaj, ~] = knnsearch(LLG1.V, PVaj);   %indices of nodes in LLG1.V

%                 new_U1(nn_PVaj, ai) = err; % exp(-err); %1;
%                 new_U2(nn_PVai, aj) = err; % exp(-err); %1;                                 
                new_U1(nn_PVaj, ai) = exp(-err); %1;
                new_U2(nn_PVai, aj) = exp(-err); %1;   
            end % err<err_eps
            
        else % Rule 2
            if size(Vai,1)<3
                nn_Vai = knnsearch(LLG1.V, Vai, 'K', 2);   %indices of nodes in LLG2.V
                nn_Vai(:,1) = [];                
                new_U1(ind_Vai, :) = new_U1(nn_Vai, :);
 
            end
            if size(Vaj,1)<3
                nn_Vaj = knnsearch(LLG2.V, Vaj, 'K', 2);   %indices of nodes in LLG2.V
                nn_Vaj(:,1) = [];             
                new_U2(ind_Vaj, :) = new_U2(nn_Vaj, :);
          
            end
        end
       
        clear pairs;
        clear ind_V1;
        clear ind_matched_pairs;
   end
   

% new correspondence matrix between nodes and anchors

%    ind_zero = (new_U1==0); new_U1(ind_zero) = NaN;
%    [W1, min_pos] = min(new_U1, [], 2);
%    new_U1(ind_zero) = 0;
%    
%    ind = sub2ind(size(new_U1), [1:nV1]', min_pos);
%    new_U1(:) = 0;
%    new_U1(ind) = 1;
% 
%    ind_zero = (new_U2==0); new_U2(ind_zero) = NaN;
%    [W2, min_pos] = min(new_U2, [], 2);
%    new_U2(ind_zero) = 0;
%    
%    ind = sub2ind(size(new_U2), [1:nV2]', min_pos);
%    new_U2(:) = 0;
%    new_U2(ind) = 1;


   [W1, max_pos] = max(new_U1, [], 2);
   ind_W_NaN = isnan(W1);
   
   i = [1:nV1]'; i(ind_W_NaN) = [];  max_pos(ind_W_NaN) = [];
   
   ind = sub2ind(size(HLG1.U), i, max_pos);
   new_U1(:) = 0;
   new_U1(ind_W_NaN,:) = HLG1.U(ind_W_NaN,:);
   new_U1(ind) = 1;

   [W2, max_pos] = max(new_U2, [], 2);
   ind_W_NaN = isnan(W2);
   
   i = [1:nV2]'; i(ind_W_NaN) = [];  max_pos(ind_W_NaN) = [];
   ind = sub2ind(size(HLG2.U), i, max_pos);
   new_U2(:) = 0;
   new_U2(ind_W_NaN,:) = HLG2.U(ind_W_NaN,:);
   new_U2(ind) = 1;
   
   HLG1.U = logical(new_U1);
   HLG2.U = logical(new_U2);
   
   LLG1.W(:, end) = -log(W1);
   LLG2.W(:, end) = -log(W2);
   
% mark anchors if corresponding subgraphs didn't changed
   F1 = HLG1.F;
   diff_U1 = abs(new_U1 - old_U1);
   F1(logical(sum(diff_U1))) = 0;

   F2 = HLG2.F;
   diff_U2 = abs(new_U2 - old_U2);
   F2(logical(sum(diff_U2))) = 0;   
   
   HLG1.F = F1;
   HLG2.F = F2;

end