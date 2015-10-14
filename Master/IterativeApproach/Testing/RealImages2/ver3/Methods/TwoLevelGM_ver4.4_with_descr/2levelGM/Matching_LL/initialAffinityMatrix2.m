%% Function to compute initial affinity matrix between two graphs
%
% v1 : 2 x nV1
% v2 : 2 x nV2

% d1: d x nV1
% d2: d x nV2
%
% d - size of vectorized HoG - descriptor around node
%
% AdjM1, AdjM2 adjancency matrices of two graphs
% 


function [D] = initialAffinityMatrix2(v1, v2, d1, d2, AdjM1, AdjM2, corrMatrix)

nV1 = size(v1,1);
nV2 = size(v2,1);

[I, J] = find(corrMatrix);
[ group1, group2 ] = make_group12([I, J]);
conflictMatrix = getConflictMatrix(group1, group2);

[corr(:,1), corr(:,2)] =  find(corrMatrix);

ind_corr_in_D = (corr(:,2)-1)*nV1 + corr(:,1);

% Affinity matrix (non-diagonal elements: edge similarity)

G1 = squareform(pdist(v1, 'euclidean')); if isempty(G1) G1=[0]; end;
G1(~AdjM1) = NaN;
% sigma1 = sum(G1(:))/nV1/nV1;
% G1 = G1./sigma1;

G2 = squareform(pdist(v2, 'euclidean')); if isempty(G2) G2=[0]; end;
G2(~AdjM2) = NaN;
% sigma2 = sum(G2(:))/nV2/nV2;
% G2 = G2./sigma2;

nV = nV1*nV2;
D1 = edgeSimilarity_exp(reshape(repmat(G1, nV2, nV2), nV*nV,1), ...
                    reshape(kron(G2,ones(nV1)), nV*nV,1) );
D1 = reshape(D1, nV, nV);

% Affinity matrix (diagonal elements: node similarity)
if (isempty(d1) || isempty(d2))
   D1(1:(length(D1)+1):end) = 0; 
else
%     D(1:(length(D)+1):end) = 0; 
%     node_eusimilarity = nodeSimilarity(d1, d2, 'euclidean');
    node_eusimilarity = nodeSimilarity(d1, d2, 'cosine');
    D1(1:(length(D1)+1):end) = node_eusimilarity;
end

D = D1(ind_corr_in_D, ind_corr_in_D);

end