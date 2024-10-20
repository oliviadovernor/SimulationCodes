% Load the CSV data from the specified folder, skipping the header row
file_path = 'C:\Users\ojd34\OneDrive - University of Cambridge\Desktop\Code\diffusion_3D_PSF_simulation\results\20000 signal photons, 10.00 bkgnd photons per 100-by-100 nm pixel, sCMOS_CAMRIG camera\repeat 1\standard\200nm\2Dlocs.csv';
data = readtable(file_path, 'HeaderLines', 1); % Skip the header row

% Extract x and y from columns 10 and 11, and frame from column 1
frames = data{:, 1};   % Assuming first column is frame
x = data{:, 10};       % Column 10 is x
y = data{:, 11};       % Column 11 is y

% Calculate the midpoint of the x and y ranges
x_mid = (max(x) + min(x)) / 2;
y_mid = (max(y) + min(y)) / 2;

% Shift x and y to be relative to the midpoint
x_shifted = (x - x_mid) / 1000; % Convert to micrometers
y_shifted = (y - y_mid) / 1000; % Convert to micrometers

figure(10); % Create a new figure for the 2D scatter plot

% Create a scatter plot with frame numbers as the color, using shifted x and y
scatter(x_shifted, y_shifted, 80, frames, '.');

% Add labels for the axes
xlabel('X Position (\mum)');
ylabel('Y Position (\mum)');

% Increase font size of axes labels
set(gca, 'FontSize', 14);  % Change 14 to the desired font size

% Add colorbar and label it
c = colorbar;
c.Label.String = 'Frame Number';

% Set axis equal for proper aspect ratio
axis equal;

% Set color limits explicitly to range from 0 to 500
clim([0, 500]);

% Ensure the colorbar reflects the new clim range
caxis([0, 500]);

% Save the figure as SVG in the same folder as the CSV file
[folder, name, ~] = fileparts(file_path);  % Extract folder path and file name
save_path = fullfile(folder, '2Dlocalisations_plot.svg');  % Save as SVG with a new name
saveas(gcf, save_path);  % Save the current figure as SVG
% Load the CSV data from the specified folder, skipping the header row
file_path = 'C:\Users\ojd34\OneDrive - University of Cambridge\Desktop\Code\diffusion_3D_PSF_simulation\results\20000 signal photons, 10.00 bkgnd photons per 100-by-100 nm pixel, sCMOS_CAMRIG camera\repeat 1\standard\200nm\2Dlocs.csv';
data = readtable(file_path, 'HeaderLines', 1); % Skip the header row

% Extract x and y from columns 10 and 11, and frame from column 1
frames = data{:, 1};   % Assuming first column is frame
x = data{:, 10};       % Column 10 is x
y = data{:, 11};       % Column 11 is y

% Calculate the midpoint of the x and y ranges
x_mid = (max(x) + min(x)) / 2;
y_mid = (max(y) + min(y)) / 2;

% Shift x and y to be relative to the midpoint
x_shifted = (x - x_mid) / 1000; % Convert to micrometers
y_shifted = (y - y_mid) / 1000; % Convert to micrometers

figure(10); % Create a new figure for the 2D scatter plot

% Create a scatter plot with frame numbers as the color, using shifted x and y
scatter(x_shifted, y_shifted, 80, frames, '.');

% Add labels for the axes
xlabel('X Position (\mum)');
ylabel('Y Position (\mum)');

% Increase font size of axes labels
set(gca, 'FontSize', 14);  % Change 14 to the desired font size

% Add colorbar and label it
c = colorbar;
c.Label.String = 'Frame Number';

% Set axis equal for proper aspect ratio
axis equal;

% Set color limits explicitly to range from 0 to 500
clim([0, 500]);

% Ensure the colorbar reflects the new clim range
caxis([0, 500]);

% Save the figure as SVG in the same folder as the CSV file
[folder, name, ~] = fileparts(file_path);  % Extract folder path and file name
save_path = fullfile(folder, '2Dlocalisations_plot.svg');  % Save as SVG with a new name
saveas(gcf, save_path);  % Save the current figure as SVG
% Load the CSV data from the specified folder, skipping the header row
file_path = 'C:\Users\ojd34\OneDrive - University of Cambridge\Desktop\Code\diffusion_3D_PSF_simulation\results\20000 signal photons, 10.00 bkgnd photons per 100-by-100 nm pixel, sCMOS_CAMRIG camera\repeat 1\standard\200nm\2Dlocs.csv';
data = readtable(file_path, 'HeaderLines', 1); % Skip the header row

% Extract x and y from columns 10 and 11, and frame from column 1
frames = data{:, 1};   % Assuming first column is frame
x = data{:, 10};       % Column 10 is x
y = data{:, 11};       % Column 11 is y

% Calculate the midpoint of the x and y ranges
x_mid = (max(x) + min(x)) / 2;
y_mid = (max(y) + min(y)) / 2;

% Shift x and y to be relative to the midpoint
x_shifted = (x - x_mid) / 1000; % Convert to micrometers
y_shifted = (y - y_mid) / 1000; % Convert to micrometers

figure(10); % Create a new figure for the 2D scatter plot

% Create a scatter plot with frame numbers as the color, using shifted x and y
scatter(x_shifted, y_shifted, 80, frames, '.');

% Add labels for the axes
xlabel('X Position (\mum)');
ylabel('Y Position (\mum)');

% Increase font size of axes labels
set(gca, 'FontSize', 14);  % Change 14 to the desired font size

% Add colorbar and label it
c = colorbar;
c.Label.String = 'Frame Number';

% Set axis equal for proper aspect ratio
axis equal;

% Set color limits explicitly to range from 0 to 500
clim([0, 500]);

% Ensure the colorbar reflects the new clim range
caxis([0, 500]);

% Save the figure as SVG in the same folder as the CSV file
[folder, name, ~] = fileparts(file_path);  % Extract folder path and file name
save_path = fullfile(folder, '2Dlocalisations_plot.svg');  % Save as SVG with a new name
saveas(gcf, save_path);  % Save the current figure as SVG


