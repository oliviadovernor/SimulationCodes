% Load the CSV data from the specified folder, skipping the header row
file_path = 'C:\Users\ojd34\OneDrive - University of Cambridge\Desktop\Code\diffusion_3D_PSF_simulation\results\20000 signal photons, 10.00 bkgnd photons per 100-by-100 nm pixel, sCMOS_CAMRIG camera\repeat 1\standard\40nm\2Dlocs.csv';  % Update with your file path
data = readtable(file_path, 'HeaderLines', 1); % Skip the header row

% Extract the directory from the file path to create a folder for the interpolated tracks
output_folder = fullfile(fileparts(file_path), 'interpolated tracks');

% Create the output folder if it doesn't exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Extract the frames and other relevant columns
frames = data{:, 1};  % Column 1 is frame
x = data{:, 10};      % Column 10 is x
y = data{:, 11};      % Column 11 is y

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
        % If the frame difference exceeds 3, save the current track
        track_data{track_num} = data(start_idx:i-1, :);

        % Store the length of the track (based on column 1, which is the frame column)
        track_lengths(track_num) = length(track_data{track_num}{:, 1});

        % Initialize interpolation flag (0 means no interpolation yet)
        interpolated_flags(track_num) = 0;  % No interpolation

        % Increment track number and update the starting index
        track_num = track_num + 1;
        start_idx = i;
    end
end

% Save the last track and its length
track_data{track_num} = data(start_idx:end, :);
track_lengths(track_num) = length(track_data{track_num}{:, 1});
interpolated_flags(track_num) = 0;  % No interpolation

% Identify missing frames and perform interpolation
for t = 1:length(track_data)
    % Extract current track frames, x positions, and y positions
    track = track_data{t};
    track_frames = track{:, 1};  % Frame column (column 1)
    track_x = track{:, 10};      % X position column (column 10)
    track_y = track{:, 11};      % Y position column (column 11)

    % Initialize arrays for missing frames and interpolated values
    new_frames = [];
    new_x = [];
    new_y = [];

    % Identify missing frames and interpolate
    for i = 2:length(track_frames)
        if track_frames(i) - track_frames(i-1) > 1
            % Find missing frames
            missing_frames = track_frames(i-1) + 1 : track_frames(i) - 1;
            % Interpolate x and y positions
            x_interp = linspace(track_x(i-1), track_x(i), length(missing_frames)+2);
            y_interp = linspace(track_y(i-1), track_y(i), length(missing_frames)+2);
            % Exclude endpoints (only keep the interpolated points)
            new_frames = [new_frames; missing_frames'];
            new_x = [new_x; x_interp(2:end-1)'];
            new_y = [new_y; y_interp(2:end-1)'];
        end
    end

    % If we found missing frames, insert them into the original track
    if ~isempty(new_frames)
        % Create a table for the interpolated data with NaN for other columns
        num_vars = size(track, 2);  % Get the number of columns in the original track
        interpolated_data = array2table(NaN(length(new_frames), num_vars), 'VariableNames', track.Properties.VariableNames);

        % Fill the appropriate columns (Frame, X, Y) with interpolated values
        interpolated_data{:, 1} = new_frames;  % Column 1: Frames
        interpolated_data{:, 10} = new_x;      % Column 10: X positions
        interpolated_data{:, 11} = new_y;      % Column 11: Y positions

        % Append interpolated data to original track
        track = [track; interpolated_data];
        track = sortrows(track, 1);  % Sort by frame to maintain order (use column 1)

        % Set flag indicating that this track has been interpolated
        interpolated_flags(t) = 1;  % Mark as interpolated
    end

    % Save each track to the 'interpolated tracks' folder
    track_filename = fullfile(output_folder, sprintf('interpolated_track%d.csv', t));
    writetable(track, track_filename);

    % Update track length after interpolation (total number of frames in track)
    track_lengths(t) = length(track{:, 1});

    % Create corresponding time points (in seconds) using column 1 for frame numbers
    time_points = (track{:, 1} - min(track{:, 1})) * time_step;

    % Plot the data for each track
    figure;
    hold on;

    % Separate original and interpolated points
    is_interpolated = isnan(track{:, 2});  % Identifies interpolated rows (NaN in other columns)

    % Loop through each pair of consecutive points and draw lines
    for i = 2:length(track{:, 1})
        if is_interpolated(i-1) || is_interpolated(i)
            % If either the previous or current point is interpolated, draw a dashed orange line
            plot(time_points(i-1:i), track{(i-1:i), 10}, '--', 'Color', [1, 0.5, 0], 'LineWidth', 1.5);
        else
            % Otherwise, draw a solid blue line between original points
            plot(time_points(i-1:i), track{(i-1:i), 10}, '-', 'Color', 'blue', 'LineWidth', 1.5);
        end
    end

    % Plot interpolated frames as orange X markers
    plot(time_points(is_interpolated), track{is_interpolated, 10}, 'x', 'Color', [1, 0.5, 0], 'MarkerSize', 8);

    % Plot the original data points as blue circles
    plot(time_points(~is_interpolated), track{~is_interpolated, 10}, 'o', 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue', 'MarkerSize', 6);

    % Labels and title
    xlabel('Time (s)');
    ylabel('X Position (\mum)');
    title(['Track ', num2str(t)]);

    % Show grid and set axis tight
    grid on;
    axis tight;
    hold off;   
end

% Separate the lengths of interpolated and non-interpolated tracks
interpolated_lengths = track_lengths(interpolated_flags == 1);
non_interpolated_lengths = track_lengths(interpolated_flags == 0);

% Plot histogram of track lengths
figure;
hold on;

% Histogram for non-interpolated tracks (solid bars)
histogram(non_interpolated_lengths, 'FaceColor', [0.2 0.6 1], 'DisplayName', 'Non-interpolated');

% Histogram for interpolated tracks (dashed bars, outlined in red)
histogram(interpolated_lengths, 'FaceColor', [0.2 0.6 1], 'EdgeColor', [1, 0.5, 0], 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'Interpolated');

% Calculate mean track length for all tracks (combined)
mean_all_tracks = mean(track_lengths);

% Add text for the mean track lengths
text(0.95, 0.9, sprintf('Mean All Tracks: %.2f frames', mean_all_tracks), ...
    'Units', 'normalized', 'HorizontalAlignment', 'right', 'FontSize', 10, 'Color', 'black');

% Set labels and title
xlabel('Track Length (number of frames)');
ylabel('Frequency');
title('Histogram of Track Lengths (including interpolated tracks)');
legend;

% Display grid and finish
grid on;
hold off;

% Output the number of tracks created and track lengths
fprintf('Number of tracks created: %d\n', track_num);
disp('Track lengths:');
disp(track_lengths);

% clc; clear;
% % Load the CSV data from the specified folder, skipping the header row
% file_path = 'C:\Users\ojd34\OneDrive - University of Cambridge\Desktop\Code\diffusion_3D_PSF_simulation\results\20000 signal photons, 10.00 bkgnd photons per 100-by-100 nm pixel, sCMOS_CAMRIG camera\repeat 1\standard\200nm\2Dlocs.csv';  % Update with your file path
% data = readtable(file_path, 'HeaderLines', 1); % Skip the header row
% 
% % Extract the directory from the file path to create a folder for the interpolated tracks
% output_folder = fullfile(fileparts(file_path), 'interpolated tracks');
% 
% % Create the output folder if it doesn't exist
% if ~exist(output_folder, 'dir')
%     mkdir(output_folder);
% end
% 
% % Extract the frames and other relevant columns
% frames = data{:, 1};  % Column 1 is frame
% x = data{:, 10};      % Column 10 is x
% y = data{:, 11};      % Column 11 is y
% 
% % Time step (30 ms per frame)
% time_step = 30 / 1000;  % In seconds
% 
% % Initialize variables for storing tracks and their lengths
% track_num = 1;
% track_data = {};  % A cell array to store multiple tracks
% track_lengths = [];  % Array to store track lengths
% interpolated_flags = [];  % Array to flag whether interpolation was done
% 
% % Loop through the frames and split the data where frame difference > 3
% start_idx = 1;  % Starting index of the first track
% for i = 2:length(frames)
%     if frames(i) - frames(i-1) > 3
%         % If the frame difference exceeds 3, save the current track
%         track_data{track_num} = data(start_idx:i-1, :);
% 
%         % Store the length of the track (based on column 1, which is the frame column)
%         track_lengths(track_num) = length(track_data{track_num}{:, 1});
% 
%         % Initialize interpolation flag (0 means no interpolation yet)
%         interpolated_flags(track_num) = 0;  % No interpolation
% 
%         % Increment track number and update the starting index
%         track_num = track_num + 1;
%         start_idx = i;
%     end
% end
% 
% % Save the last track and its length
% track_data{track_num} = data(start_idx:end, :);
% track_lengths(track_num) = length(track_data{track_num}{:, 1});
% interpolated_flags(track_num) = 0;  % No interpolation
% 
% % Initialize a figure for the XY scatter plot of all tracks
% figure;
% hold on;
% 
% % Define a colormap for assigning different colors to each track
% num_tracks = length(track_data);
% colors = lines(num_tracks);  % 'lines' is a built-in colormap that returns distinguishable colors
% 
% % Loop through each track to interpolate missing frames and plot the XY positions
% for t = 1:num_tracks
%     % Extract current track frames, x positions, and y positions
%     track = track_data{t};
%     track_frames = track{:, 1};  % Frame column (column 1)
%     track_x = track{:, 10};      % X position column (column 10)
%     track_y = track{:, 11};      % Y position column (column 11)
% 
%     % Initialize arrays for missing frames and interpolated values
%     new_frames = [];
%     new_x = [];
%     new_y = [];
% 
%     % Identify missing frames and interpolate
%     for i = 2:length(track_frames)
%         if track_frames(i) - track_frames(i-1) > 1
%             % Find missing frames
%             missing_frames = track_frames(i-1) + 1 : track_frames(i) - 1;
%             % Interpolate x and y positions
%             x_interp = linspace(track_x(i-1), track_x(i), length(missing_frames)+2);
%             y_interp = linspace(track_y(i-1), track_y(i), length(missing_frames)+2);
%             % Exclude endpoints (only keep the interpolated points)
%             new_frames = [new_frames; missing_frames'];
%             new_x = [new_x; x_interp(2:end-1)'];
%             new_y = [new_y; y_interp(2:end-1)'];
%         end
%     end
% 
%     % If we found missing frames, insert them into the original track
%     if ~isempty(new_frames)
%         % Create a table for the interpolated data with NaN for other columns
%         num_vars = size(track, 2);  % Get the number of columns in the original track
%         interpolated_data = array2table(NaN(length(new_frames), num_vars), 'VariableNames', track.Properties.VariableNames);
% 
%         % Fill the appropriate columns (Frame, X, Y) with interpolated values
%         interpolated_data{:, 1} = new_frames;  % Column 1: Frames
%         interpolated_data{:, 10} = new_x;      % Column 10: X positions
%         interpolated_data{:, 11} = new_y;      % Column 11: Y positions
% 
%         % Append interpolated data to original track
%         track = [track; interpolated_data];
%         track = sortrows(track, 1);  % Sort by frame to maintain order (use column 1)
% 
%         % Set flag indicating that this track has been interpolated
%         interpolated_flags(t) = 1;  % Mark as interpolated
%     end
% 
%     % Separate original and interpolated points
%     is_interpolated = ismember(track{:, 1}, new_frames);  % Compare frame numbers with interpolated frames
% 
%     % Plot the entire track with a line, assigning a unique color for each track
%     plot(track{:, 10}, track{:, 11}, '-', 'Color', colors(t, :), 'LineWidth', 1.5, 'DisplayName', ['Track ', num2str(t)]);
% 
%     % Calculate lighter fill color for markers (blending track color with white)
%     lighter_color = colors(t, :) + (1 - colors(t, :)) * 0.5;  % Make it lighter
% 
%     % Add markers to every data point with lighter fill
%     plot(track{:, 10}, track{:, 11}, 'o', 'MarkerEdgeColor', colors(t, :), 'MarkerFaceColor', lighter_color, ...
%          'MarkerSize', 6, 'DisplayName', ['Track Markers ', num2str(t)]);
% 
%     % Plot the interpolated points as large black crosses for clarity
%     if any(is_interpolated)
%         plot(track{is_interpolated, 10}, track{is_interpolated, 11}, 'x', 'Color', 'black', ...
%             'MarkerSize', 12, 'LineWidth', 2.5, 'DisplayName', ['Interpolated Track ', num2str(t)]);
%     end
% 
%     % Highlight the start of each track with a marker (optional)
%     plot(track_x(1), track_y(1), 'o', 'MarkerSize', 8, 'MarkerEdgeColor', 'black', ...
%         'MarkerFaceColor', colors(t, :), 'DisplayName', ['Start Track ', num2str(t)]);
% end
% 
% % Set axis labels and title
% xlabel('X Position (\mum)');
% ylabel('Y Position (\mum)');
% %title('XY Scatter Plot of All Tracks with Interpolated Points and Markers');
% 
% % Show grid, legend, and finish
% grid off;
% %legend('show');
% hold off;
% 
% % Output the number of tracks created and track lengths
% fprintf('Number of tracks created: %d\n', track_num);
% disp('Track lengths:');
% disp(track_lengths);
