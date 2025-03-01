function [FarrarEfficiency] = FarrEff(As_bt,ts_t)
% Compute the Farrar Efficiency factor
%   Create a database of points by reading the graph
% Use linear interpolation to extract Farrar values from the graph
% Note that the Farrar paper on minimum weight compression structures
% (March 1949) provides this graph.

% t_s/t ratios for Z-stringers are given between 0 and 1.8 on Farrar's graph 
% but we restrict the search to 0.5 < t_s/t < 1.6

% A_s/(bt) ratios for Z-stringers are given between 0 and 2 but we restrict
% the search to 0.4 < A_s/(bt) < 2

% Consider the case 

switch ts_t
    case 0.5
        x = [0.18, 0.22, 0.3, 0.38, 0.43, 0.81, 1.26];  % from Farrar paper
        F_y = [0.5, 0.6, 0.7, 0.75, 0.8, 0.8, 0.75];  % corresponding contours
        FarrarEfficiency = interp1(x, F_y, As_bt);
    case 0.6
        x = [0.19, 0.26, 0.37, 0.41, 0.48, 0.6, 0.77, 1.31];
        F_y = [0.5, 0.6, 0.7, 0.75, 0.8, 0.9, 0.9, 0.8];
        FarrarEfficiency = interp1(x, F_y, As_bt);
    case 0.7
        x = [0.2, 0.29, 0.39, 0.45, 0.54, 0.66, 1.19, 1.7];
        F_y = [0.5, 0.6, 0.7, 0.75, 0.8, 0.9, 0.9, 0.8];
        FarrarEfficiency = interp1(x, F_y, As_bt);
    case 0.8
        x = [0.22, 0.31, 0.42, 0.51, 0.6, 0.72, 0.88, 1, 1.48, 1.95];
        F_y = [0.5, 0.6, 0.7, 0.75, 0.8, 0.85, 0.9, 0.9, 0.85, 0.8];
        FarrarEfficiency = interp1(x, F_y, As_bt);
    case 0.9
        x = [0.23, 0.35, 0.48, 0.58, 0.68, 0.81, 1.1, 1.44, 1.8];
        F_y = [0.5, 0.6, 0.7, 0.75, 0.8, 0.85, 0.9, 0.9, 0.85];
        FarrarEfficiency = interp1(x, F_y, As_bt);
    case 1
        x = [0.25, 0.39, 0.5, 0.62, 0.73, 0.9, 1.1, 1.76];
        F_y = [0.5, 0.6, 0.7, 0.75, 0.8, 0.85, 0.9, 0.9];
        FarrarEfficiency = interp1(x, F_y, As_bt);
    case 1.1
        x = [0.28, 0.41, 0.58, 0.68, 0.81, 1.03, 1.29];
        F_y = [0.5, 0.6, 0.7, 0.75, 0.8, 0.85, 0.9];
        FarrarEfficiency = interp1(x, F_y, As_bt);
    case 1.2
        x = [0.3, 0.43, 0.62, 0.75, 0.9, 1.12, 1.42];
        F_y = [0.5, 0.6, 0.7, 0.75, 0.8, 0.85, 0.9];
        FarrarEfficiency = interp1(x, F_y, As_bt);
    case 1.3
        x = [0.32, 0.48, 0.68, 0.82, 1, 1.29, 1.68];
        F_y = [0.5, 0.6, 0.7, 0.75, 0.8, 0.85, 0.9];
        FarrarEfficiency = interp1(x, F_y, As_bt);
    case 1.4
        x = [0.34, 0.52, 0.72, 0.9, 1.1, 1.41, 1.92];
        F_y = [0.5, 0.6, 0.7, 0.75, 0.8, 0.85, 0.9];
        FarrarEfficiency = interp1(x, F_y, As_bt);
    case 1.5
        x = [0.38, 0.58, 0.8, 0.99, 1.25, 1.66];
        F_y = [0.5, 0.6, 0.7, 0.75, 0.8, 0.85];
        FarrarEfficiency = interp1(x, F_y, As_bt);  
end