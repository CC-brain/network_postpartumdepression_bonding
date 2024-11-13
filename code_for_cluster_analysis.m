% Clustering analysis and plot code for the following paper
% "A network analysis of postpartum depression and mother-to-infant bonding 
% shows common and unique symptom-level connections at three postpartum
% timepoints"

clear all

% Load data
load data.mat

% Specify the number of clusters (k)
k = 2; 

% Set the random seed
rng(0);

% Perform k-means clustering
[idx, ~] = kmeans(data, k);

% Calculate frequency and ratio of each cluster
freq = zeros(k, 1);
for i = 1:k
    freq(i) = sum(idx == i);
    ratio = freq(i) / length(data);
    fprintf('Cluster %d: Frequency = %d, Ratio = %.2f%%\n', i, freq(i), ratio * 100);
end

% Determine which cluster has more and fewer data points
[~, idx_major] = max(freq); 
idx_minor = setdiff(1:k, idx_major); 

% Create labels for data points
labels = [compose('epds%d', 1:10), compose('mibs%d', 1:10)];

% Ensure the labels match the data size
if length(labels) < length(data)
    labels = [labels, compose('x%d', 1:(length(data) - length(labels)))]; % Fill with extra labels if needed
elseif length(labels) > length(data)
    labels = labels(1:length(data)); % Trim if there are more labels than data points
end

% Define colors for clusters
color_major = [0.3010 0.7450 0.9330]; % Blue-ish for major cluster
color_minor = [1 0.5 0];              % Orange for minor cluster

colors = zeros(length(data), 3); % Initialize color array
colors(idx == idx_major, :) = repmat(color_major, sum(idx == idx_major), 1); % Major cluster
colors(idx == idx_minor, :) = repmat(color_minor, sum(idx == idx_minor), 1); % Minor cluster

% Sort data and corresponding attributes in descending order
[sorted_data, sorted_idx] = sort(data, 'descend');
sorted_labels = labels(sorted_idx);
sorted_colors = colors(sorted_idx, :);
sorted_idx_major = idx(sorted_idx) == idx_major;

% Adjusted vertical positions to have some space at the top
y_top = 1;  
y_bottom = 0; 
y_offset = 0.1; 

% Set the y-axis limits to include space above the top data point
ylim_values = [y_bottom, y_top + y_offset];

% Assign vertical positions based on ranking
vertical_positions = linspace(y_top, y_bottom, length(data));

% Create a new figure for the ranked plot
figure;
hold on;

% Scatter plot with ranked vertical positions
scatter(sorted_data(sorted_idx_major), vertical_positions(sorted_idx_major), 50, sorted_colors(sorted_idx_major, :), 'filled', 'MarkerFaceAlpha', 0.7); % Major cluster
scatter(sorted_data(~sorted_idx_major), vertical_positions(~sorted_idx_major), 70, sorted_colors(~sorted_idx_major, :), 'filled', 'MarkerFaceAlpha', 0.7); % Minor cluster

% Add labels with offset for better readability 
for i = 1:length(sorted_data)
    text(sorted_data(i), vertical_positions(i) + 0.005, sorted_labels{i}, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 9);
end

legend('Cluster 1', 'Cluster 2', 'Location', 'best');

title('All participants');
xlabel('Bridge Expected Influence', 'FontSize', 11); 
set(gca, 'YTick', [], 'YColor', 'none'); 
ylim(ylim_values);
xlim([-0.05, 0.425]);
xticks([0, 0.1, 0.2, 0.3, 0.4]);
ax = gca;
ax.XAxis.FontSize = 11;
axis square;

hold off;
