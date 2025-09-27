%% DFS, Graph, Trees

% Voronoi Graph
centroids = [328,497,1;
146,154,1;
435,126,1;
630,275,1;
848,161,1;
49,521,1;
239,696,1;
676,643,1;
688,509,1;
882,503,1];

labelImage = createVoronoi(centroids,'Different-amoebas-on-abstract-background-gray.tiff');

Ivor = labeloverlay(I,labelImage);
figure; imshow(Ivor)

% Quadtree
[rows, columns] = size(I_gray);
m = 1024;
n = 1024;
rowsPre = floor((m - rows)/2);
collsPre = floor((n - columns)/2);
I_grayp = padarray(I_gray, [rowsPre, collsPre], 0, 'both');

S = qtdecomp(I_grayp,.27);
blocks = repmat(uint8(0),size(S));

for dim = [1024 512 256 128 64 32 16 8 4 2 1]    
  numblocks = length(find(S==dim));    
  if (numblocks > 0)        
    values = repmat(uint8(1),[dim dim numblocks]);
    values(2:dim,2:dim,:) = 0;
    blocks = qtsetblk(blocks,S,dim,values);
  end
end

blocks(end,1:end) = 1;
blocks(1:end,end) = 1;

blocks(1:rowsPre,:) = [];
blocks(end-rowsPre+1:end,:) = [];

figure
imshow(blocks,[])

[rows, cols] = size(I_BW);
label_matrix_dfs = zeros(rows, cols);
component_id = 0;

% Scan every pixel
for r = 1:rows
    for c = 1:cols
        % If a foreground pixel is found and is unlabeled
        if I_BW(r, c) == 1 && label_matrix_dfs(r, c) == 0
            component_id = component_id + 1;
            stack = [r, c]; % Push starting pixel onto stack
            % Start DFS
            while ~isempty(stack)
                % Pop a pixel from the stack
                current_pixel = stack(end, :);
                stack(end, :) = [];
                curr_r = current_pixel(1);
                curr_c = current_pixel(2);
                % Skip if already labeled
                if label_matrix_dfs(curr_r, curr_c) ~= 0
                    continue;
                end
                % Label the current pixel
                label_matrix_dfs(curr_r, curr_c) = component_id;
                % Explore neighbors (8-connectivity)
                for dr = -1:1
                    for dc = -1:1
                        % Skip the current pixel itself
                        if dr == 0 && dc == 0
                            continue;
                        end
                        neighbor_r = curr_r + dr;
                        neighbor_c = curr_c + dc;
                        % Check boundaries
                        if neighbor_r > 0 && neighbor_r <= rows && neighbor_c > 0 && neighbor_c <= cols

                            % If neighbor is a foreground pixel and is unlabeled
                            if I_BW(neighbor_r, neighbor_c) == 1 && label_matrix_dfs(neighbor_r, neighbor_c) == 0
                                stack = [stack; neighbor_r, neighbor_c]; % Push neighbor to stack
                            end
                        end
                    end
                end
            end
        end
    end
end
% --- Part 2: Connected components using the built-in function ---
% Note: bwlabel also uses an algorithm that is conceptually similar to a graph search
[label_matrix_builtin, num_components] = bwlabel(I_BW, 8); % Using 8-connectivity
% --- Visualization ---
subplot(1, 3, 1);
imshow(I_BW);
title('Original Binary Image');
subplot(1, 3, 2);
imshow(label2rgb(label_matrix_dfs, 'jet', 'w', 'shuffle'));
title('Labeled by Manual DFS');
subplot(1, 3, 3);
imshow(label2rgb(label_matrix_builtin, 'jet', 'w', 'shuffle'));
title('Labeled by bwlabel');
% Display the number of components found
fprintf('Manual DFS found %d components.\n', component_id);
fprintf('bwlabel found %d components.\n', num_components);