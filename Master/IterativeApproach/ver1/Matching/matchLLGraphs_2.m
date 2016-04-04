 
%% Matching of dependency graphs
%
% Input
% DG1, DG2      two graphs with nV1 and nV2 nodes respectively
% AG1, AG2      corresponding anchor graphs
%
% Output
%   objval      riched match score
%  matches      boolean matrix of matches if the size (nV1 x nV2)


function [objval, matches] = matchLLGraphs(indOfSubgraphsNodes, corrmatrices, affmatrices)

display(sprintf('\n================================================'));
display(sprintf('Match initial graphs'));
display(sprintf('=================================================='));

    nV1 = size(LLG1.V,1);
    nV2 = size(LLG2.V,1);

    % adjacency matrix of the first dependency graph
    adjM1 = zeros(nV1, nV1);
    E1 = LLG1.E;
    E1 = [E1; [E1(:,2) E1(:,1)]];
    ind = sub2ind(size(adjM1), E1(:,1), E1(:,2));
    adjM1(ind) = 1;

    % adjacency matrix of the second dependency graph
    adjM2 = zeros(nV2, nV2);
    E2 = LLG2.E;
    E2 = [E2; [E2(:,2) E2(:,1)]];
    ind = sub2ind(size(adjM2), E2(:,1), E2(:,2));
    adjM2(ind) = 1;






    tic 
    % global variables
    nIterations = size(LLG1.U, 2);      % number of iterations is equal to number of nodes in the first HLGraph 

    objective = zeros(nIterations, 1);

    nV = nV1 * nV2;
    localMatches = zeros(nIterations, nV);
            
    try
        poolobj = parpool(3);                           

        if isempty(poolobj)
            poolsize = 0;
        else
            poolsize = poolobj.NumWorkers;
        end
        display(sprintf('Number of workers: %d', poolsize));
        
        % ----------------------------------------------------------------
        % Run parallel
        % ----------------------------------------------------------------
        % in each step we match points corresponding to the anchor match ai<->aj
        parfor it = 1:1%nIterations
            node_ind = indOfSubgraphsNodes(it,:);
            
            % nodes, that belong to the anchor ai
            ai_x = logical(node_ind(1:nV1));
            nVi = size(corrmatrices{it},1);
            display(sprintf('nVi = %d', nVi));
           

            % nodes, that belong to the anchor aj
            aj_x = logical(node_ind(nV1+1:end));        
            nVj = size(corrmatrices{it},2);
            display(sprintf('nVj = %d', nVj));
            
            corrMatrix = corrmatrices{it};
            affmatrix = affmatrices{it};
            
            % conflict groups
            [I, J] = find(corrMatrix);
            [ group1, group2 ] = make_group12([I, J]);

            % run RRW Algorithm 
            tic
            x = RRWM(affmatrix, group1, group2);
            fprintf('    RRWM: %f sec\n', toc);

            X = greedyMapping(x, group1, group2);

            objective(it) = x'*affmatrix * x;

            matchesL = zeros(nVi, nVj);
            for k=1:numel(I)
                matchesL(I(k), J(k)) = X(k);
            end  

            matches = zeros(nV1, nV2);
            matches(ai_x, aj_x') = matchesL;
            localMatches(it, :) = reshape(matches, [1 nV]);
            
        end
        
        delete(poolobj); 
        display(sprintf('Delete parallel pool %d', poolsize));
        display(sprintf(' -------------------------------------------------- '));

    catch ME
        msg = 'Error occurred in Lower Level Graph Matching in parallel pool';
        causeException = MException(ME.identifier, msg);
        ME = addCause(ME, causeException);

        % close parallel pool
        delete(gcp('nocreate'));

        rethrow(ME);
    end


    matches = max(localMatches,[], 1);
    matches = reshape(matches, nV1,nV2);

    % for i=1:nV1
    %    [val, ind] = max(matchesW(i,:));
    %    if val>0
    %        matches(i,ind) = 1;
    %    end
    % end

    matches = logical(matches);
    
    objval = sum(objective);

    display(sprintf('=================================================='));

end