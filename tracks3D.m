clc; clear;

% Load the CSV data from the specified folder
file_path = 'C:\Users\ojd34\OneDrive - University of Cambridge\Desktop\Code\diffusion_3D_PSF_simulation\results\20000 signal photons, 10.00 bkgnd photons per 100-by-100 nm pixel, sCMOS_CAMRIG camera\repeat 1\lightfield\40nm\3D Fitting\locs3D.csv';  % Update with your file path
data = readtable(file_path);  % Read the CSV data

% Extract the directory from the file path to create a folder for the interpolated tracks
output_folder = fullfile(fileparts(file_path), 'interpolated_tracks');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Extract relevant columns
x = data{:, 1};  % Column 1 is X
y = data{:, 2};  % Column 2 is Y
z = data{:, 3};  % Column 3 is Z
frames = data{:, 8};  % The last column is frames

% Time step (30 ms per frame)
time_step = 30 / 1000;  % In seconds

% Initialize variables for storing tracks and their lengths
track_num = 1;
track_data = {};  % A cell array to store multiple tracks
track_lengths = [];  % Array to store track lengths
interpolated_flags = [];  % Array to flag whether interpolation was done

% Loop through the frames and split the data where frame difference > 3
start_idx = 1;  % Starting index of the first track
for i = 2:length(frames)
    if frames(i) - frames(i-1) > 3
        % Save the current track
        track_data{track_num} = data(start_idx:i-1, :);
        track_lengths(track_num) = length(track_data{track_num}{:, end});  % Store the length of the track (frame column)
        interpolated_flags(track_num) = 0;  % No interpolation
        track_num = track_num + 1;
        start_idx = i;
    end
end

% Save the last track and its length
track_data{track_num} = data(start_idx:end, :);
track_lengths(track_num) = length(track_data{track_num}{:, end});
interpolated_flags(track_num) = 0;  % No interpolation

% Initialize a figure for the 3D scatter plot of all tracks
figure;
hold on;

% Define a colormap for assigning different colors to each track
num_tracks = length(track_data);
colors = lines(num_tracks);  % 'lines' is a built-in colormap that returns distinguishable colors

% Loop through each track to interpolate missing frames and plot the 3D positions
for t = 1:num_tracks
    % Extract current track frames, x positions, y positions, and z positions
    track = track_data{t};
    track_frames = track{:, end};  % Last column is frame
    track_x = track{:, 1};         % X positions
    track_y = track{:, 2};         % Y positions
    track_z = track{:, 3};         % Z positions

    % Initialize arrays for missing frames and interpolated values
    new_frames = [];
    new_x = [];
    new_y = [];
    new_z = [];

    % Identify missing frames and interpolate
    for i = 2:length(track_frames)
        if track_frames(i) - track_frames(i-1) > 1
            % Find missing frames
            missing_frames = track_frames(i-1) + 1 : track_frames(i) - 1;
            % Interpolate x, y, and z positions
            x_interp = linspace(track_x(i-1), track_x(i), length(missing_frames)+2);
            y_interp = linspace(track_y(i-1), track_y(i), length(missing_frames)+2);
            z_interp = linspace(track_z(i-1), track_z(i), length(missing_frames)+2);
            % Exclude endpoints (only keep the interpolated points)
            new_frames = [new_frames; missing_frames'];
            new_x = [new_x; x_interp(2:end-1)'];
            new_y = [new_y; y_interp(2:end-1)'];
            new_z = [new_z; z_interp(2:end-1)'];
        end
    end

    % Insert interpolated points into the track
    if ~isempty(new_frames)
        % Create a table for interpolated points
        interpolated_data = array2table(NaN(length(new_frames), size(track, 2)), 'VariableNames', track.Properties.VariableNames);
        interpolated_data{:, 1} = new_x;
        interpolated_data{:, 2} = new_y;
        interpolated_data{:, 3} = new_z;
        interpolated_data{:, end} = new_frames;

        % Append interpolated points to original track
        track = [track; interpolated_data];
        track = sortrows(track, 8);  % Sort by frame column
        interpolated_flags(t) = 1;  % Mark as interpolated
    end

    % Plot the entire track with a line in 3D, assigning a unique color for each track
    pale_color = colors(t, :) + (1 - colors(t, :)) * 0.5;  % Make the line color lighter (blend with white)
    plot3(track{:, 1}, track{:, 2}, track{:, 3}, '-', 'Color', pale_color, 'LineWidth', 1.5);  % Plot pale connecting lines

    % Add markers to every data point with lighter fill
    lighter_color = colors(t, :) + (1 - colors(t, :)) * 0.3;  % Adjust lighter fill color
    plot3(track{:, 1}, track{:, 2}, track{:, 3}, 'o', 'MarkerEdgeColor', colors(t, :), 'MarkerFaceColor', lighter_color, ...
         'MarkerSize', 6, 'DisplayName', ['Track Markers ', num2str(t)]);  % Use plot3 for 3D markers

    % Plot the interpolated points as large black crosses in 3D
    if any(ismember(track{:, end}, new_frames))
        plot3(new_x, new_y, new_z, 'x', 'Color', 'black', ...
            'MarkerSize', 12, 'LineWidth', 2.5, 'DisplayName', ['Interpolated Track ', num2str(t)]);
    end

    % Highlight the start of each track with a marker
    plot3(track_x(1), track_y(1), track_z(1), 'o', 'MarkerSize', 8, 'MarkerEdgeColor', 'black', ...
          'MarkerFaceColor', colors(t, :));
end

% Set axis labels and title
xlabel('X Position (\mum)');
ylabel('Y Position (\mum)');
zlabel('Z Position (\mum)');
%title('3D Scatter Plot of All Tracks with Interpolated Points');

% Show grid and finish
grid on;
hold off;

% Output the number of tracks created and track lengths
fprintf('Number of tracks created: %d\n', track_num);
disp('Track lengths:');
disp(track_lengths);


% Filter out tracks that have fewer than 3 frames
valid_tracks = track_lengths >= 3;
filtered_track_lengths = track_lengths(valid_tracks);  % Only keep tracks with 3 or more frames

% Calculate the number of tracks created
num_tracks_created = length(filtered_track_lengths);

% Calculate the average track length
if num_tracks_created > 0
    average_track_length = mean(filtered_track_lengths);
else
    average_track_length = 0;
end

% Output the number of valid tracks created and the average length
fprintf('Number of valid tracks (>= 3 frames) created: %d\n', num_tracks_created);
fprintf('Average valid track length: %.2f frames\n', average_track_length);
