function visited = dfs_iterative_image(image, start_row, start_col, target_value)
    [rows, cols] = size(image);
    visited = false(rows, cols);
    stack = [start_row, start_col]; % Stack stores [row, col] pairs

    while ~isempty(stack)
        current_pixel = stack(end, :); % Get top of stack
        stack(end, :) = []; % Pop from stack
        r = current_pixel(1);
        c = current_pixel(2);

        if r < 1 || r > rows || c < 1 || c > cols || visited(r, c) || image(r, c) ~= target_value
            continue; % Skip if out of bounds, visited, or not target value
        end

        visited(r, c) = true; % Mark as visited

        % Push unvisited neighbors onto the stack (e.g., 4-connectivity)
        if r + 1 <= rows && ~visited(r + 1, c) && image(r + 1, c) == target_value
            stack = [stack; r + 1, c];
        end
        if r - 1 >= 1 && ~visited(r - 1, c) && image(r - 1, c) == target_value
            stack = [stack; r - 1, c];
        end
        if c + 1 <= cols && ~visited(r, c + 1) && image(r, c + 1) == target_value
            stack = [stack; r, c + 1];
        end
        if c - 1 >= 1 && ~visited(r, c - 1) && image(r, c - 1) == target_value
            stack = [stack; r, c - 1];
        end
    end
end