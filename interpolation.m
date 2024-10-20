clc; clear;

% Select the folder containing the CSV files
folder_path = uigetdir();  % Opens a dialog for the user to select the folder
files = dir(fullfile(folder_path, '*.csv'));  % Get all CSV files in the folder

% Create the output folder for saving the interpolated tracks
output_folder = fullfile(folder_path, 'Interpolated_tracks');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Loop through each CSV file in the folder
for k = 1:length(files)
    % Get the current file's full path
    file_path = fullfile(folder_path, files(k).name);
    
    % Load the CSV data (assuming no headers)
    data = readtable(file_path, 'ReadVariableNames', false);  % Read the CSV data without headers

    % Extract the original filename without path or extension
    [~, file_name, ~] = fileparts(file_path);

    % Extract columns 1, 2, 3, 4 for Time, X, Y, Z
    time = data{:, 1};  % Column 1 is Time
    x = data{:, 2};     % Column 2 is X
    y = data{:, 3};     % Column 3 is Y
    z = data{:, 4};     % Column 4 is Z

    % Skip the row where all values in X, Y, Z are zero (usually the first row)
    valid_indices = ~(x == 0 & y == 0 & z == 0);  % Identify non-zero rows
    time = time(valid_indices);
    x = x(valid_indices);
    y = y(valid_indices);
    z = z(valid_indices);

    % Time step (assuming 30 ms per frame)
    time_step = 0.03;  % Time step in seconds

    % Initialize arrays for new interpolated data
    new_time = time(1);  % Start with the first time point
    new_x = x(1);        % Start with the first X point
    new_y = y(1);        % Start with the first Y point
    new_z = z(1);        % Start with the first Z point

    % Loop through the data to find gaps and interpolate missing points
    for i = 2:length(time)
        % Calculate the time difference between consecutive points
        time_diff = time(i) - time(i-1);

        % If the time difference is larger than the time step, interpolate
        if time_diff > time_step
            % Calculate how many time steps are missing
            num_missing_steps = round(time_diff / time_step) - 1;

            % Generate the missing time points
            missing_times = linspace(time(i-1) + time_step, time(i) - time_step, num_missing_steps);

            % Linearly interpolate X, Y, Z for the missing time points
            x_interp = linspace(x(i-1), x(i), num_missing_steps + 2);
            y_interp = linspace(y(i-1), y(i), num_missing_steps + 2);
            z_interp = linspace(z(i-1), z(i), num_missing_steps + 2);

            % Append the missing time points and interpolated coordinates
            new_time = [new_time; missing_times'];  % Add missing times
            new_x = [new_x; x_interp(2:end-1)'];   % Skip the original endpoints
            new_y = [new_y; y_interp(2:end-1)'];
            new_z = [new_z; z_interp(2:end-1)'];
        end

        % Append the original data points
        new_time = [new_time; time(i)];
        new_x = [new_x; x(i)];
        new_y = [new_y; y(i)];
        new_z = [new_z; z(i)];
    end

    % Create a new table for the interpolated data
    interpolated_data = table(new_time, new_x, new_y, new_z, ...
        'VariableNames', {'Time', 'X', 'Y', 'Z'});

    % Save the interpolated data with the same filename in the 'Interpolated_tracks' folder
    output_file_path = fullfile(output_folder, [file_name, '.csv']);
    writetable(interpolated_data, output_file_path);

    % Display the path where the file is saved
    fprintf('Interpolated data for %s saved to: %s\n', file_name, output_file_path);
end

% Notify completion
fprintf('All files have been processed and saved to %s.\n', output_folder);


% Initialize a variable to store the total length and number of trajectories
total_length = 0;
num_trajectories = 0;

% Loop through each CSV file in the folder
for k = 1:length(files)
    % Get the current file's full path
    file_path = fullfile(folder_path, files(k).name);
    
    % Load the CSV data (assuming no headers)
    data = readtable(file_path, 'ReadVariableNames', false);  % Read the CSV data without headers

    % Extract columns 1, 2, 3, 4 for Time, X, Y, Z
    time = data{:, 1};  % Column 1 is Time
    x = data{:, 2};     % Column 2 is X
    y = data{:, 3};     % Column 3 is Y
    z = data{:, 4};     % Column 4 is Z

    % Skip rows where all values in X, Y, Z are zero
    valid_indices = ~(x == 0 & y == 0 & z == 0);  % Identify non-zero rows
    valid_data_length = sum(valid_indices);  % Get the length of valid data

    % Add to total length and increment the trajectory count
    total_length = total_length + valid_data_length;
    num_trajectories = num_trajectories + 1;
end

% Calculate the average trajectory length
if num_trajectories > 0
    avg_length = total_length / num_trajectories;
    fprintf('Average trajectory length: %.2f points\n', avg_length);
else
    fprintf('No valid trajectories found.\n');
end
