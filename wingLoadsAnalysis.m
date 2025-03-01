%%% WING LOADS ANALYSIS %%%
% AEROFOIL SECTION: NASA SC(2)-0712
% reading in airfoil data for aerofoil section
afoil = importdata("sc20712.dat");
u_surf = afoil(:, 1);  % upper surface x-coordinates
l_surf = afoil(:, 2);  % lower surface y-coordinates



%%%%%%%%%%%%%%%%%%%%%% AEROFOIL PARAMETERS %%%%%%%%%%%%%%%%%%%%%%
t_c = 0.12;  % thickness-chord ratio



%%%%%%%%%%%%%%%%%%%%%% WING PARAMETERS %%%%%%%%%%%%%%%%%%%%%%
S_ref = 438.288;  % wing reference area [m^2]
taper = 0.25;  % wing taper ratio
AR = 9.2;  % wing aspect ratio
c_bar = 8.148;  % mean aerodynamic chord [m]
MAC = 12.0483;  % spanwise position of aerodynamic centre from datum line
spar_fpos = 0.225;  % wing front spar position as % of chord
spar_apos = 0.68;  % wing aft spar position as % of chord


%%%%%% chord distribution %%%%%%




%%%%%%%%%%%%%%%%%%%%%% WING BOX IDEALISATION PARAMETERS %%%%%%%%%%%%%%%%%%%%%%
spar_top_c = max(afoil);
spar_bot_c = min(afoil);

% aerofoil centroid
avg = mean(afoil);
x_cg = avg(:, 1);
y_cg = avg(:, 2);

% aerofoil aerodynamic centre
x_ac = 0.25;
y_ac = 0;

% shear centre
x_sc = 0;
y_sc = 0; 


% cell 1 (main torsion box)
spar_top = spar_top_c(2);  % max-coord of spar
spar_bot = spar_bot_c(2);  % min-coord of spar
spar_ic = spar_bot:0.0001:spar_top;  % idealised spar vertical coordinates
panel = spar_fpos:0.0001:spar_apos;  % idealised skin horizontal coordinates


% cell 1 centroid
c1_xcg = (spar_apos + spar_fpos)*0.5;
c1_ycg = 0;

%%%% PLOTTING %%%%
clf
hold on
grid on
lw = 1.4;
plot(u_surf, l_surf, color="black", linewidth=lw)
plot(spar_fpos*ones(size(spar_ic)), spar_ic, color="red", linewidth=lw)  % front spar
plot(spar_apos*ones(size(spar_ic)), spar_ic, color="red", linewidth=lw)  % aft spar
plot(panel, spar_top*ones(size(panel)), color="red", linewidth=lw)  % top panel 
plot(panel, spar_bot*ones(size(panel)), color="red", linewidth=lw)  % bottom panel
plot(c1_xcg, c1_ycg, "x", color="magenta", linewidth=lw, markersize=10)  % torsion box centroid
plot(c1_xcg, c1_ycg, "+", color="black", linewidth=lw, markersize=10)  % torsion box shear centre
plot(x_cg, y_cg, "x", color="blue", linewidth=lw, markersize=10)
plot(x_ac, y_ac, "x", color="green", linewidth=lw, markersize=10)
axis equal;
title("Real & Idealised wing section")
xlabel("x/c")
ylabel("y/c")

legend("Real wing", "Structural Idealisation", "", "", "", "Torsison box centroid", "Torsion box shear centre", "Aerofoil centroid", "Aerodynamic centre")