%% One iteration of the two-level Graph Matching Algorithm

function [HLG1, HLG2, LLGmatches, HLGmatches, affTrafo, time, it] = ...
                   twoLevelGM(L, LLG1, LLG2, HLG1, HLG2, LLGmatches, HLGmatches, InitialMatches, affTrafo)
    
    setParameters_2levelGM;
    
    nMaxIt = algparam_2lGM.nMaxIt;       % maximal number of iteration for each level of the image pyramid
    nConst = algparam_2lGM.nConst;       % stop, if the matching score didn't change in last C iterations    
    
    time = 0;
    it = 0; 
    count = 0;
  
    [LLG1, LLG2] = preprocessing(LLG1, LLG2, agparam_2lGM);
%     [HLG1, HLG2] = buildHLGraphs_use_InitMatches(LLG1, LLG2, InitialMatches, agparam_2lGM);
  
    if isempty(HLG1)
%         HLG1 = buildHLGraph(L, LLG1, agparam_2lGM);
        HLG1 = buildHLGraph_grid(L, LLG1, agparam_2lGM);
%           HLG1 = buildHLGraph_aggClustering(L, LLG1, agparam_2lGM);
    end
    if isempty(HLG2)
%         HLG2 = buildHLGraph(L, LLG2, agparam_2lGM);
        HLG2 = buildHLGraph_grid(L, LLG2, agparam_2lGM);
%           HLG2 = buildHLGraph_aggClustering(L, LLG2, agparam_2lGM);
    end
    
%     poolobj = parpool(2);   
    while count<nConst && it<nMaxIt
        it = it + 1;
        start = tic;
        [HLG1, HLG2, LLGmatches, HLGmatches, affTrafo] = ...
                twoLevelGM_oneIteration(it, LLG1, LLG2, HLG1, HLG2, LLGmatches, HLGmatches, affTrafo);
        time = time + toc(start);   
            
        if it>=2 && abs(LLGmatches(it).objval-LLGmatches(it-1).objval)<10^(-5)
            count = count + 1;
        else
            count = 0;
        end
        
    end
    
    % close parallel pool
%     delete(poolobj); 
       
end