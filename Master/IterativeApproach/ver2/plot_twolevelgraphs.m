% function for plotting of the anchor graph 
% Input:
% img       given imHLGe
%
% HLGraph =      higher level graph
%  {     V,    coordinates of the anchors (m x 2)
%        U,    matrix of the nearest anchors for each point v_i \in V
%  }
%
% LLGraph =      lower level graph
%  {    V,  coordinates of the vertices (n x 2)
%       E,  eLLGes
%       D  descriptors of the vertices
%       U, matrix of dependences between nodes of HLGraph and those of LLGraph
%  }
%
%
% show_HLGraphs   show eLLGes of the HLG
% show_LLGraphs   show eLLGes of the LLG

function plot_twolevelgraphs(img, LLG, HLG, show_LLG, show_HLG)

    if (ndims(img)>1)
        imagesc(img) ;
    end
    
    hold on ;
    axis off;
    
    n = size(LLG.V, 1);
    m = size(HLG.V, 1);
    
    % edges between vertives on two levels
    [i, j] = find(LLG.U);
    matchesInd = [i,j]';

    nans = NaN * ones(size(matchesInd,2),1) ;
    xInit = [ LLG.V(matchesInd(1,:),1) , HLG.V(matchesInd(2,:),1) , nans ] ;
    yInit = [ LLG.V(matchesInd(1,:),2) , HLG.V(matchesInd(2,:),2) , nans ] ;
    line(xInit', yInit', 'Color','m', 'LineStyle', '--', 'LineWidth', 0.5) ;
      
    % vertices
    plot(LLG.V(:,1), LLG.V(:,2), 'b*');
    
    % edges between vertices
    if show_LLG
        edges = LLG.E';
        edges(end+1,:) = 1;
        edges = edges(:);

        points = LLG.V(edges,:);
        points(3:3:end,:) = NaN;

        line(points(:,1), points(:,2), 'Color', 'g');
% %         for i=1:size(LLG.E, 1)
% %             line([LLG.V(LLG.E(i,1),1) LLG.V(LLG.E(i,2),1) ],...
% %                  [LLG.V(LLG.E(i,1),2) LLG.V(LLG.E(i,2),2) ], 'Color', 'g');  
% %         end
    end
    
    % anchors
    plot(HLG.V(:,1), HLG.V(:,2), 'yo','MarkerSize', 9, 'MarkerFaceColor','y');
    
    % edges between anchors
    if show_HLG
        matchesInd = HLG.E';

        nans = NaN * ones(size(matchesInd,2),1) ;
        xInit = [ HLG.V(matchesInd(1,:),1) , HLG.V(matchesInd(2,:),1) , nans ] ;
        yInit = [ HLG.V(matchesInd(1,:),2) , HLG.V(matchesInd(2,:),2) , nans ] ;

        line(xInit', yInit', 'Color','y', 'LineStyle', '-', 'LineWidth', 3) ;
    end
    
    
    hold off; 

 
 
end