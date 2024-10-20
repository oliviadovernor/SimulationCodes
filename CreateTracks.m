% Group Tracks based on 3D input localisations 
% Olivia Dovernor - 2024

clear; close all; clc;

%% 1. Read localisation file
% Select 2D localisation file (must be a .csv file)
[file, path] = uigetfile({'*.csv'}, 'Select 3D Localisations', 'C:\');
if isequal(file, 0)
    disp('User selected Cancel');
    return;  % Exit if the user cancels the file selection
else
    disp(['User selected ', fullfile(file)]);
end
filepath = fullfile(path, file);
locs3D = readmatrix(fullfile(path, file));

% If save = 'yes' on line 17, then a '3D Fitting' folder will be made, and results saved here
outputFolder = fullfile(path, 'Results\');
mkdir(outputFolder);

exposure = (30/1000);
saveFlag = 'yes'; % save output files

%% 3. Plot trajectories for each particle in 3D
% Change parameters in function: graph of 1D changes in time outputted
% Go into function to change parameters that tracks are calculated from
tracks = SPTrajectories(locs3D); % without fiducial 

% Define the minimum track length
min_track_length = 1; % for 30 ms is 1s of data (x3 for 10ms) 
% x_limit = 0;
% y_limit = -2;
%z_limit = -2;
% 2. Filter data based on Z position
% Define the Z position range
% z_min = 0;
% z_max = 6;

% Initialize an empty cell array to store tracks longer than the minimum length
filtered_tracks = {};

% % Loop through each track
for i = 1:numel(tracks)
    % Check if the track length is longer than the minimum length
    if size(tracks{i}, 1) > min_track_length
    %if size(tracks{i}, 1) > min_track_length &&  all(tracks{i, 1}(:, 3)> y_limit) reject in column data
    %if size(tracks{i}, 1) > min_track_length &&  all(tracks{i, 1}(:, 3)> y_limit) &&  all(tracks{i, 1}(:, 2)< x_limit) %&& all(tracks{i, 1}(:, 4)> z_limit) 
        % Multiply the first column by (10/1000) to convert time to milliseconds
        tracks{i}(:, 1) = tracks{i}(:, 1) * exposure;
        % Multiply the localisation columns xyz by (x10-6) to convert to m
        % tracks{i}(:, 2:4) = tracks{i}(:, 2:4) * 1e-6;
        % Store the track in the filtered_tracks cell array
        filtered_tracks{end+1} = tracks{i};
    end
end
% Now filtered_tracks contains only tracks longer than min_track_length
% Initialize empty arrays to store concatenated data
    all_x = [];
    all_y = [];
    all_z = [];

    for trackIndex = 1:numel(filtered_tracks)    
        % Extract x, y, z positions for the current track
        track_x = filtered_tracks{trackIndex}(:, 2);
        track_y = filtered_tracks{trackIndex}(:, 3);
        track_z = filtered_tracks{trackIndex}(:, 4);

        % Concatenate track_x, track_y, track_z to the global arrays
        all_x = [all_x; track_x];
        all_y = [all_y; track_y];
        all_z = [all_z; track_z];

        % Use a different color for each point in the track
        colormap_lines = viridis(numel(filtered_tracks));
        colors = colormap_lines(trackIndex, :);
        % Plot the 3D scatter plot with points
        scatter3(track_x, track_y, track_z, 20, colors, 'filled');
        % Plot linking lines
        hold on;
        plot3(track_x, track_y, track_z, 'Color', colors); % Use the same color for the lines
    end

    hold off;  % Release the hold on the figure
    xlabel('X Position (\mum)');
    ylabel('Y Position (\mum)');
    zlabel('Z Position (\mum)');
    title('3D Trajectories', 'FontSize', 12);
    grid on;




% Loop through each track
% for i = 1:numel(tracks)
%     % Check if the track length is longer than the minimum length
%     if size(tracks{i}, 1) > min_track_length
%         % Multiply the first column by (10/1000) to convert time to milliseconds
%         tracks{i}(:, 1) = tracks{i}(:, 1) * exposure;
%         % Multiply the localisation columns xyz by (x10-6) to convert to m
%         % tracks{i}(:, 2:4) = tracks{i}(:, 2:4) * 1e-6;
% 
%         % Filter out rows where Z is not in the range [z_min, z_max]
%         if all(tracks{i}(:, 4) >= z_min & tracks{i}(:, 4) <= z_max)
%             % Store the track in the filtered_tracks cell array
%             filtered_tracks{end+1} = tracks{i};
%         end
%     end
% end
% Now filtered_tracks contains only tracks longer than min_track_length and within Z range


%% Save tracks
switch saveFlag
    case 'yes'
        fprintf('Writing time series data for each track to output files...\n');
        mkdir(outputFolder);

        % Iterate over each track and save it as a separate CSV file 
        % data saved in = time,x,y,z format. 
        for i = 1:numel(filtered_tracks)
            trackData = filtered_tracks{i};
            % Add headings
            headings = {'Time', 'X', 'Y', 'Z'};
            trackData = [0, zeros(1, size(trackData, 2)-1); trackData]; % Add 0 column
            trackData = [headings; num2cell(trackData)]; % Add headings
            filename = fullfile(outputFolder, ['track_' num2str(i) '.csv']);
            writecell(trackData, filename);
        end

    case 'no'
        % Handle the case when 'saveFlag' is 'no'
        disp('Not saving files.');
end



% %% For multi-emitter 3D locs with numerous tracks per emitter: 
% % 1) Reject extremeties where emitter consistently goes out of DOF (above
% % uncomment filtering code and replace above)
% % OR
% % 2) Keep all tracks >1 in length and save assigned to emitter for ref 
% 
% % Olivia Dovernor - 2024
% 
% clear; close all; clc;
% 
% % 1. Read localisation file
% % Select 3D localisation file (must be a .csv file)
% [file, path] = uigetfile({'*.csv'}, 'Select 3D Localisations', 'C:\');
% if isequal(file, 0)
%     disp('User selected Cancel');
%     return;  % Exit if the user cancels the file selection
% else
%     disp(['User selected ', fullfile(file)]);
% end
% filepath = fullfile(path, file);
% locs3D = readmatrix(fullfile(path, file));
% 
% % Define exposure time
% exposure = (30/1000);
% 
% % 2. Define the emitters and their range thresholds
% emitters = [
%     0.2, -6, 2.7;  % Emitter 1
%     1.8, 0.8, 2; % Emitter 2
%     % 5.3, -4.6, 0.6; % Emitter 3
% ];
% range_threshold = 1.2;
% 
% % Create output folders for each emitter
% outputFolders = {};
% for i = 1:size(emitters, 1)
%     emitter_folder = fullfile(path, ['Emitter_' num2str(i)]);
%     mkdir(emitter_folder);
%     outputFolders{i} = emitter_folder;
% end
% 
% % 3. Plot trajectories for each particle in 3D
% % Go into function to change parameters that tracks are calculated from
% tracks = SPTrajectories(locs3D); % without fiducial 
% 
% % Define the minimum track length
% min_track_length = 1; % for 30 ms is 1s of data (x3 for 10ms) 
% 
% % Loop through each track
% for i = 1:numel(tracks)
%     % Check if the track length is longer than the minimum length
%     if size(tracks{i}, 1) > min_track_length
%         % Multiply the first column by (10/1000) to convert time to milliseconds
%         tracks{i}(:, 1) = tracks{i}(:, 1) * exposure;
% 
%         % Check which emitter the track is closest to and within the range
%         for j = 1:size(emitters, 1)
%             emitter = emitters(j, :);
%             distances = sqrt(sum((tracks{i}(:, 2:4) - emitter).^2, 2));
% 
%             % Check if all distances are within the threshold
%             if all(distances <= range_threshold)
%                 % Save the track to the corresponding emitter folder
%                 trackData = tracks{i};
%                 % Add headings
%                 headings = {'Time', 'X', 'Y', 'Z'};
%                 trackData = [0, zeros(1, size(trackData, 2)-1); trackData]; % Add 0 column
%                 trackData = [headings; num2cell(trackData)]; % Add headings
%                 filename = fullfile(outputFolders{j}, ['track_' num2str(i) '.csv']);
%                 writecell(trackData, filename);
%                 break; % Stop checking other emitters if this one is a match
%             end
%         end
%     end
% end
% 
% fprintf('Tracks have been processed and saved to corresponding emitter folders.\n');
