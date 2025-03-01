

close all;
%% Given Wing Parameters
% Sweep Angles (degrees)
front_spar_sweep = 32.9384;  % constant sweep of front spar [deg]
aft_spar_sweep = 28.4604;  % constant sweep of aft spar [deg]

sweep_LE = 35; % Pre-kink leading edge sweep
sweep_TE = 25.0626;


% Wing Dimensions (metres)
b_half = 27.6941; % Wing half-span
root_chord = 12.653; % Root chord
tip_chord = 2.9102; % Tip chord
kink_span = 7.4113; % Kink spanwise location

% Spar Locations (percentage of local chord)
front_spar_frac = 0.225; % 22.5% of chord
rear_spar_frac = 0.68;   % 68% of chord

% Structural Elements
num_stringers = 20;  % Number of stringers
num_ribs = 30;
L = 0.9467;  % Rib spacing (m)

% Key spanwise locations
y_kink = 10.5422 - 3.1309;  % spanwise position of kink from where wing meets the fuselage [m]
%% Compute Wing Planform Points

% **Leading Edge Calculations**
LE_root = [0, 0];  % Root leading edge at fuselage
LE_tip = [b_half* tand(sweep_LE), b_half]; % Tip LE

% **Trailing Edge Calculations**
TE_root = [root_chord, 0];  % Root trailing edge

% Calculate kink chord length
kink_chord = odyGetChord(y_kink);

% Kink LE point
LE_kink = [tand(sweep_LE) * y_kink, y_kink];
% Kink TE point
TE_kink = [root_chord, kink_span];

% Tip TE point
TE_tip = [LE_tip(1) + tip_chord, b_half];



%% Compute Spar Locations
% Front Spar
front_spar_root = [2.1039, 0];
front_spar_tip = LE_tip + front_spar_frac * (TE_tip - LE_tip);

% Rear Spar
rear_spar_root = [6.3587, 0];
rear_spar_kink = y_kink + rear_spar_frac * (TE_kink - LE_kink);
rear_spar_tip = LE_tip + rear_spar_frac * (TE_tip - LE_tip);

%% Plot the Wing Planform
figure; hold on; axis equal;
xlabel('Chordwise Distance (m)'); ylabel('Spanwise Distance (m)');
title('Cranked Wing - Upper Skin Panel');
% 
    
% **Plot Wing Edges**
% Leading Edge
plot([LE_root(1), LE_tip(1)], [LE_root(2), LE_tip(2)], 'k', 'LineWidth', 2);
% 
% % Trailing Edge
plot([TE_root(1), TE_kink(1)], [TE_root(2), TE_kink(2)], 'k', 'LineWidth', 2);
plot([TE_kink(1), TE_tip(1)], [TE_kink(2), TE_tip(2)], 'k', 'LineWidth', 2);

% Root and Tip Chord
plot([LE_root(1), TE_root(1)], [LE_root(2), TE_root(2)], 'k', 'LineWidth', 2);
plot([LE_tip(1), TE_tip(1)], [LE_tip(2), TE_tip(2)], 'k', 'LineWidth', 2);

%% **Plot Spars**
% Front Spar
plot([front_spar_root(1), front_spar_tip(1)], [front_spar_root(2), front_spar_tip(2)], 'b--', 'LineWidth', 2);
% 
% Rear Spar
plot([rear_spar_root(1), rear_spar_tip(1)], [rear_spar_root(2), rear_spar_tip(2)], 'b--', 'LineWidth', 2);


%% Plot Stringers (Red Lines Parallel to Front Spar)
%{
- stringers run parallel to front spar
- should terminate when they intersect with the rear spar or the tip chord
(whichever comes first)
- ribs are perpendicular to the front spar

%}
stringer_spacing = (rear_spar_root(1) - front_spar_root(1)) / (num_stringers + 1);

for i = 1:num_stringers
    stringer_start = front_spar_root + i * stringer_spacing * [1, 0];

    % Find intersection with the rear spar
    x_intersection = (-8.4832 + 1.5435 * i * stringer_spacing)/-0.3013;
    y_intersection = 1.8448*(x_intersection - 6.3587);
    stringer_end = [x_intersection, y_intersection];

    % Ensure termination at tip chord
    if stringer_end(2) >= b_half
        stringer_end(1) = front_spar_tip(1) + i * stringer_spacing;
        stringer_end(2) = b_half;
        plot([stringer_start(1), stringer_end(1)], [stringer_start(2), stringer_end(2)], 'green', 'LineWidth', 1);
    end

    % Ensure termination at the rear spar
    if stringer_end(2) <= rear_spar_tip(2) && stringer_end(2) >= rear_spar_root(2)
        plot([stringer_start(1), stringer_end(1)], [stringer_start(2), stringer_end(2)], 'green', 'LineWidth', 1);
    end
end
% 
%% Plot Ribs (Black Lines) perpendicular to front spar
rib_positions = 0:L:b_half; % Spanwise rib locations

% Calculate front spar angle
front_spar_angle = atand((front_spar_tip(1) - front_spar_root(1)) / (front_spar_tip(2) - front_spar_root(2)));
perp_angle = front_spar_angle + 114; % Perpendicular angle

for i = 1:length(rib_positions)
    span_loc = rib_positions(i);

    % Find intersection with front spar
    frac = span_loc / b_half;
    front_spar_intersection = front_spar_root + frac * (front_spar_tip - front_spar_root);

    % Calculate rib direction perpendicular to front spar
    rib_length = (rear_spar_root(1) - front_spar_root(1)) * 1.5; % Enough length to reach rear spar
    dx = rib_length * cosd(perp_angle);
    dy = rib_length * sind(perp_angle);

    % Potential end point of perpendicular rib
    rib_end = [front_spar_intersection(1) + dx, front_spar_intersection(2) + dy];

    % Find intersection with rear spar (line equation intersection)
    % Line 1: Rear spar
    m1 = (rear_spar_tip(2) - rear_spar_root(2)) / (rear_spar_tip(1) - rear_spar_root(1));
    b1 = rear_spar_root(2) - m1 * rear_spar_root(1);

    % Line 2: Perpendicular rib
    m2 = (rib_end(2) - front_spar_intersection(2)) / (rib_end(1) - front_spar_intersection(1));
    b2 = front_spar_intersection(2) - m2 * front_spar_intersection(1);

    % Find intersection
    x_intersect = (b2 - b1) / (m1 - m2);
    y_intersect = m1 * x_intersect + b1;

    rear_spar_intersection = [x_intersect, y_intersect];
    
    if rear_spar_intersection(2) < rear_spar_root(2) && rear_spar_intersection(1) > 6
        rear_spar_intersection = [6.24, 0];
        plot([front_spar_intersection(1), rear_spar_intersection(1)], [front_spar_intersection(2), rear_spar_intersection(2)], 'red', 'LineWidth', 1);
    end

    % Check if intersection is within bounds of rear spar
    if rear_spar_intersection(2) >= rear_spar_root(2) && rear_spar_intersection(2) <= rear_spar_tip(2)
        % Plot rib from front spar to rear spar
        plot([front_spar_intersection(1), rear_spar_intersection(1)], [front_spar_intersection(2), rear_spar_intersection(2)], 'red', 'LineWidth', 1);
    end

    % enforce root at where wing meets fuselage
    plot([front_spar_root(1), rear_spar_root(1)], [front_spar_root(2), rear_spar_root(2)], 'red', 'LineWidth', 1);

    % enforce rib at winglet end
    plot([front_spar_tip(1), rear_spar_tip(1)], [front_spar_tip(2), rear_spar_tip(2)], 'red', 'LineWidth', 1);
end
%% Pseudo-ribs for leading edge slats
%{ 
N_pr: number of pseudo-ribs 
Ns = N_pr - 1: number of slat mechanics
Start of a pseudo-rib: where it starts on the leading edge
End of a pseudo-rib: find the equation of the front spar and use that
Slats start 30cm (spanwise direction) from fuselage wall.
Slats end 20cm before winglets (spanwise direction)
Should be perpendicular to the front spar
    how to enforce perpendicular?
Enforce termination at the front spar
%}

slat_start = [0.3 * tand(sweep_LE), 0.3];  % start co-ordinates of the leading edge slats [m]
slat_end = [tand(sweep_LE) * (b_half - 0.2), b_half - 0.2];  % end of leading edge slats

slat_LE_x = linspace(slat_start(1), slat_end(1), 7);  % leading edge x-coordinate of all pseudo-ribs
slat_LE_y = linspace(slat_start(2), slat_end(2), 7);  % leading edge y-coordinate of all pseudo-ribs

% pseudo-rib equation
m_pr = -0.6478781989;  % gradient of a pseudo-rib (must be perpendicular to front spar)
m_fs = -1/m_pr;  % gradient of front spar

slat_FS_x = 4000000*slat_LE_x/13529569 + 6174000*slat_LE_y/13529569 + 200492602191/135295690000;
slat_FS_y = 6174000*slat_LE_x/13529569 + 9529569*slat_LE_y/13529569 - 64947393/67647845;

% % ** Plot pseudo-ribs ** 
for slat = 2:length(slat_FS_x)
    hold on
    plot([slat_LE_x(slat), slat_FS_x(slat)], [slat_LE_y(slat), slat_FS_y(slat)], 'magenta', 'LineWidth', 2);
end


grid on
% Add legend with distinctive markers
h0 = plot(NaN, NaN, 'magenta', 'LineWidth', 2);
h1 = plot(NaN, NaN, 'k', 'LineWidth', 2);
h2 = plot(NaN, NaN, 'b--', 'LineWidth', 2);
h3 = plot(NaN, NaN, 'g', 'LineWidth', 1);
h4 = plot(NaN, NaN, 'r', 'LineWidth', 1);

legend([h0, h1, h2, h3, h4], {'Pseudo-ribs', 'Wing Edges', 'Spars', 'Stringers', 'Ribs'}, 'Location', 'Best');