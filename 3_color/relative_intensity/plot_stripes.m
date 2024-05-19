% Plot state assignment of traces in a single figure
% Feb 3, 2023
% By X. Feng
close all

files = dir(fullfile(pwd, '*.csv'));

n_files = length(files);

max_len = 0;

len_list = zeros(1, n_files);

time_unit = 0.05; % unit is seconds
x_axis = 0:2:6;

for i = 1 : n_files
    state_list = readmatrix(files(i).name);
    curr_len = length(state_list);
    len_list(i) = curr_len;
    if curr_len > max_len
        max_len = curr_len;
    end
end

% allocate a matrix of 3's to store all data
data_matrix = ones(n_files, max_len) * 3;

% fill in matrix
for j = 1 : n_files
    state_list = readmatrix(files(j).name);
    curr_len = length(state_list);
    data_matrix(j, 1 : curr_len) = state_list;
end

%cm = [0 1 0; 1 0 0; 0 0 1; 1 1 1];
cm = [0 1 0; 1 0 0; 0 0 1; 0 0 0];

figure
colormap(cm);
imagesc(data_matrix);
set(gcf, 'Position', [500 450 800 500]);

[sorted,idx] = sort(len_list);

sorted_data_matrix = ones(n_files, max_len) * 3;

for k = 1 : n_files
    sorted_data_matrix(k, :) = data_matrix(idx(k), :);
end

figure
colormap(cm);
imagesc(sorted_data_matrix);
set(gcf, 'Position', [500 450 800 500]);
xticks(x_axis/time_unit);
xticklabels(x_axis);
xlabel('Time (s)');
xlim([0 6/time_unit]);

sorted_data_matrix2 = ones(n_files * 3, max_len) * 3;

for k = 1 : n_files
    sorted_data_matrix2(k * 3 - 2, :) = sorted_data_matrix(k, :);
    sorted_data_matrix2(k * 3 - 1, :) = sorted_data_matrix(k, :);
end

figure
colormap(cm);
imagesc(sorted_data_matrix2);
set(gcf, 'Position', [500 450 400 300]);
set(gca, 'FontSize', 15);
set(gca, 'Color', 'k');
xticks(x_axis/time_unit);
xticklabels(x_axis);
set(gca, 'ytick', []);
xlabel('Time (s)');
xlim([0 6/time_unit]);


