
% Read *.dat and *_background.dat of a selected trace and convert it into a color-coded 
%   line representating state transitions over time.
% Requires utility functions: which_state, bd_filter2, and getDT.
% Feb 1, 2023 X. Feng
% Last updated May 19, 2024

close all
clearvars

% ---------------------------- USER INPUT ----------------------------

trace_prefix = 'your_trace_name'; % for example 'hel1_trace_1'; this 
                                  % should be a subtrace containing the
                                  % binding event of interest; if the trace
                                  % contains multiple binding events, the
                                  % longest event will be selected
num_std = 3; % a parameter that might need manual tuning for every
             % trace to achieve the best state assignment; it sets how many
             % standard deviations the fluorescence intensity needs to be
             % above background to be regarded as signal (and not
             % background)
save_states = 1; % 1 if saving output state sequence; 0 if not saving
save_dt = 1; % 1 if saving dwell times of each state; 0 if not saving
time_unit = 0.05; % unit: seconds

% -------------------------- USER INPUT ENDS --------------------------

% Read input trace data

trace_fname = [trace_prefix '.dat'];
data = readmatrix(trace_fname);

background_fname = [trace_prefix '_background.dat'];
opts = detectImportOptions(background_fname, 'LeadingDelimitersRule', 'ignore');
background = readmatrix(background_fname, opts);

x = data(:, 1) ;
y0 = data(:, 2);
y1 = data(:, 3);
y2 = data(:, 4);
u0 = background(4);
u1 = background(5);
u2 = background(6);

% Plot trace

figure
plot(x, y0, 'g');
hold on
plot(x, y1, 'r');
plot(x, y2, 'b');
%plot(x, y0 + y1 + y2, 'k');
hold off
xlabel("Time (s)");
ylabel("Fluor. Intensity");
set(gcf, 'Position', [100 600 1100 100]);
xlim([min(x) max(x)]);

if save_states
    saveas(gcf, trace_prefix, 'epsc');
end

% Assign a state - 0, 1, 2, or 3 - to each data point

y_state = zeros(1, length(x));
    
ptr = 0;
for t = x'
    ptr = ptr + 1; 
    state = which_state(y0(ptr), y1(ptr), y2(ptr), u0, u1, u2, num_std);
    y_state(ptr) = state;        
end

% Create a matlab colormap with 3 or 4 colors, depending on # states in a trace

if ismember(0, y_state)
    cm = [0 1 0; 1 0 0; 0 0 1; 1 1 1];
else
    cm = [1 0 0; 0 0 1; 1 1 1];
end

% Make a heatmap trace of assigned states

figure
colormap(cm);
imagesc(y_state);
set(gcf, 'Position', [100 450 1100 50]);

if save_states
    heatmap_fname = [trace_prefix '_states'];
    saveas(gcf, heatmap_fname, 'epsc');
end

% Filter out false positive states outside of binding event

filtered_state_list = bd_filter2(y_state);

if ismember(0, filtered_state_list) && ismember(1, filtered_state_list) && ismember(2, filtered_state_list)
    cm = [0 1 0; 1 0 0; 0 0 1];
elseif ismember(0, filtered_state_list) && ismember(1, filtered_state_list)
    cm = [0 1 0; 1 0 0];
elseif ismember(1, filtered_state_list) && ismember(2, filtered_state_list)
    cm = [1 0 0; 0 0 1];
elseif ismember(0, filtered_state_list) && ismember(2, filtered_state_list)
    cm = [0 1 0; 0 0 1];
elseif ismember(0, filtered_state_list)
    cm = [0 1 0];
elseif ismember(1, filtered_state_list)
    cm = [1 0 0];
elseif ismember(2, filtered_state_list)
    cm = [0 0 1];
end

figure
colormap(cm);
imagesc(filtered_state_list);
set(gcf, 'Position', [100 300 1100 50]);

if save_states
    heatmap_fname = [trace_prefix '_states_filtered'];
    saveas(gcf, heatmap_fname, 'epsc');
    
    % remove previous state_list data
    old_state_list = dir([trace_prefix '_state_list_std_*.csv']);
    if ~isempty(old_state_list)
        delete(old_state_list(1).name);
    end
    
    % save filtered_state_list
    state_list_fname = [trace_prefix '_state_list_std_' int2str(num_std) '.csv'];
    writematrix(filtered_state_list, state_list_fname, 'Delimiter', ',');
    
end


% Extract dwell times from state list

dt0_list = getDT(filtered_state_list, 0, time_unit);
dt1_list = getDT(filtered_state_list, 1, time_unit);
dt2_list = getDT(filtered_state_list, 2, time_unit);

% Save dwell time data

if save_dt
    dt0_fname = [trace_prefix '_cy3onlyDT.dat'];
    dt1_fname = [trace_prefix '_cy5fretDT.dat'];
    dt2_fname = [trace_prefix '_cy7fretDT.dat'];

    csvwrite(dt0_fname, dt0_list);
    csvwrite(dt1_fname, dt1_list);
    csvwrite(dt2_fname, dt2_list);
end
