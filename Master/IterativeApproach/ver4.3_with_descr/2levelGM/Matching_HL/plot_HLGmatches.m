%% plot results of matching
% img1, img2    two images to match
% G1, G2        corresponding graphs to match (nV1=|V1|,nV2=|V2|)
% pairs         pairs of points

function plot_HLGmatches(img1, G1, img2, G2, matches, matches_old, varargin )

% if (~isempty(img1) && ~isempty(img2))
%     n1 = size(img1,2);                      % width of the first image
%     img3 = combine2images(img1,img2);       % plot two concatenated images
%     imagesc(img3) ; hold on ; axis off;
% else
%     n1 = max(G1.V(:,1)) + abs(min(G1.V(:,1)));
% end
hold on; n1 = 500;
G2.V(:,1) = n1 + G2.V(:,1);	% shift x-coordinates of the second graph


%                      ------------------------------------
%                              plot first graph (G1)
% edges
edges = G1.E'; edges(end+1,:) = 1; edges = edges(:);
points = G1.V(edges,:); points(3:3:end,:) = NaN;
line(points(:,1), points(:,2), 'Color', 'y', 'LineWidth', 3);
% nodes
plot(G1.V(:,1), G1.V(:,2), 'bo','MarkerSize', 7, 'MarkerFaceColor','y');

%                      ------------------------------------
%                              plot second graph (G2)
% edges
edges = G2.E'; edges(end+1,:) = 1; edges = edges(:);
points = G2.V(edges,:); points(3:3:end,:) = NaN;
line(points(:,1), points(:,2), 'Color', 'y', 'LineWidth', 3);
% nodes
plot(G2.V(:,1), G2.V(:,2), 'bo','MarkerSize', 7, 'MarkerFaceColor','y');

%                      ------------------------------------
%                                  plot matches
if (~isempty(matches))
    nans = NaN * ones(size(matches,1),1) ;
    x = [ G1.V(matches(:,1),1) , G2.V(matches(:,2),1) , nans ] ;
    y = [ G1.V(matches(:,1),2) , G2.V(matches(:,2),2) , nans ] ; 
    line(x', y', 'Color','b',  'LineWidth', 2) ;
end

%                      ------------------------------------
%                     plot matches from previous iterations
if (~isempty(matches_old))
    nans = NaN * ones(size(matches_old,1),1) ;
    x = [ G1.V(matches_old (:,1),1) , G2.V(matches_old (:,2),1) , nans ] ;
    y = [ G1.V(matches_old (:,1),2) , G2.V(matches_old (:,2),2) , nans ] ; 
    line(x', y', 'Color','g','LineStyle', '--') ;
end


%                      ------------------------------------
%                        ADDITIONALLY:  highlight some matches

if (nargin == 7)
    matches_hl = varargin{1};

    if (~isempty(matches_hl) )
        nans = NaN * ones(size(matches_hl,1),1) ;
        x = [ G1.V(matches_hl(:,1),1) , G2.V(matches_hl(:,2),1) , nans ] ;
        y = [ G1.V(matches_hl(:,1),2) , G2.V(matches_hl(:,2),2) , nans ] ; 
        line(x', y', 'Color','b', 'LineWidth', 4) ;

        if (~isempty(matches_old))
            [~,right_matches] = ismember(matches_hl(:,1), matches_old(:,1));
            x = [ G1.V(matches_hl(:,1),1) , G2.V(matches_old(right_matches, 2),1) , nans ] ;
            y = [ G1.V(matches_hl(:,1),2) , G2.V(matches_old(right_matches, 2),2) , nans ] ; 
            line(x', y', 'Color','b', 'LineWidth', 4, 'LineStyle', '--');
        end
    end
    
end

hold off;
end