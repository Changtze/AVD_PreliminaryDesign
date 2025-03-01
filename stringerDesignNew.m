%%%%%% skin-stringer panel code %%%%%
clc
load stringerNewDesignSpace.mat

%%%%%%%%%%% NOTES %%%%%%%%%%%%%%
% CHOSEN STRINGER: EXTRUDED Z-STRINGER

% CHOSEN MATERIAL: 7075 Al-Alloy
% https://asm.matweb.com/search/specificmaterial.asp?bassnum=ma7075t6
nu = 0.33;  % Poisson Ratio
E = 71.7;  % Young's Modulus [GPa]
G = 26.9;  % Shear Modulus [GPa]
c0 = 12.653;  % root chord [m] 
tc = 0.12;  % max thickness at 37% chord
sigma_yield = 503;  % Yield strength [MPa]
rho = 2.81e3;  % density [kg/m^3]


%%%%%%%%%%% PREVIOUSLY CALCULATED/KNOWN VARIABLES
b_wing = 61.65-(2*3.1309);  % wingspan with winglets [m], not including fuselage wingbox
half_b = b_wing/2;  % halfspan with winglets [m]
spar_fpos = 0.225;  % position of front spar as % of chord
spar_apos = 0.68;  % position of aft spar as % of chord
M_max = 1.6268E7;  % [Nm]
b2 = @(chord) chord * tc;  % wing box height [m]
c = @(chord) chord*(spar_apos-spar_fpos);  % wing box width [m]
y_kink = 10.5422 - 3.1309;  % spanwise position of kink from where wing meets fuselage


% %%%%%%%%%%% STRINGER PARAMETERS
% ns = 0;  % number of stringers
% b = 0;  % stringer spacing/pitch [m]
% h = 0;  % stringer height
% t = 0;  % skin thickness
% t_s = 0;  % stringer web thickness
% t_d = 0;  % stringer flange width
% d = 0;  % flange width of stringer
% b1 = @(ch) c(ch)/ns;  % panel width
% % t_eff = t + (A_s/b);  % effective thickness
    

%%%%%%%%%%%% FARRAR efficiency
% sig_fail = 0;  % mean stress realised by the skin and stringer at failure
N = @(moment, box_width, box_height) moment/(box_width * box_height);  % Axial compressive end load per unit width of skin stringer panel [N/m]
% sigma_N = @(mo, bw, bh) N(mo, bw, bh)/t;  % Axial stress
% rho = 2810;  % Density of 7075 Al [kg/m^3]
E_t = E;  % tangent modulus (assume it to be E for FARRAR equation)
% L = (half_b/30):0.01:(half_b/7);  % rib spacing sweeping between 7 ribs and 30 ribs
% 
% F = @(sig, N, E_t, L) sig * sqrt(L/(N*E_t));  % FARRAR efficiency
% sigma_crit = @(K, E, t, b) K*E*(t./b).^2;  % Critical buckling stress of skin-stringer panel


%%%%%%%%%%%% Effective skin thickness estimation
% t_eff = @(cho) ((M*b1(cho))/(cho * b2(cho) * 3.62 * E))^(1/3);
N_max = N(M_max, c(c0), b2(c0));  % max axial load per unit width (N/m)


%%%%%%%%%%%% Parametric sweep for one skin (top or bottom) %%%%%%%%%%%%%%

% Note that design constraints are enforced as soon as possible, to avoid
% memory capacity issues.

%%% Design variables for stringers)
b = c(c0)*1000./ns;  % stringer spacing/pitch [mm]
t_s = 1:0.5:5;  % stringer thickness [mm]
ts_t_ratio = 0.5:0.1:1.5;  % ts/t ratito
h_b = 0.1:0.1:0.7;  % stringer height to spacing ratio
d_h = 0.1:0.1:0.7;  % stringer flange width to stringer height ratio
td_ts = 0.5:0.3:1.8; % stringer flange thickness to stringer thickness ratio

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% UNCOMMENT ALL OF THIS IF YOU WANT TO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RE-RUN THE PARAMETRIC SWEEP
%%% Design space %%%
% ds = combinations(b, t_s, ts_t_ratio, h_b, d_h, td_ts);

% re-run the parametric sweep (11/02/2025)
% feasibility line - for each rib spacing, draw line going through minimum
% weights at each rib spacing
% taper (function of chord)
% stringers have to end at a rib; construct logic to make sure stringers
% don't meet or hit trailing/leading edge

%%% Calculating parameters, h, d, t_d, t  %%% 
ds.t = ds.t_s ./ ds.ts_t_ratio;  % skin thickness (NOT INCLUDING STRINGERS)
ds.h = ds.h_b .* ds.b;  % stringer height
ds.d = ds.d_h .* ds.h;  % flange width
ds.t_d = ds.td_ts .* ds.t_s;  % flange thickness

ds.A_s = stringer_area(ds.h, ds.t_s, ds.d, ds.t_d);  % skin-stringer area 
ds.t_eff = effective_thickness(ds.A_s, ds.b, ds.t);  % [mm]

% removing thicknesses less than 1mm
ds(ds.t_d < 1, :) = [];  
ds(ds.t < 1, :) = [];

sigma_crit_global = @(E, t_eff, c) 3.62 * E * 1e3 * (t_eff./c).^2;  % [MPa, assumnig E is given in GPa]

ds.sigma_cr = sigma_crit_global(E, ds.t_eff, ds.b);  % [MPa]
ds.sigmaComp = N_max./(ds.t*1000);

% Removing designs where sigmaComp > sigma_cr
ds(ds.sigmaComp > ds.sigma_cr, :) = [];

% Compute Farrar efficiency
ds.As_bt = ds.A_s ./ (ds.b .* ds.t);
ds(ds.As_bt > 2, :) = [];

for k = 1:height(ds)
     ds.F(k) = FarrEff(ds.As_bt(k), ds.ts_t_ratio(k));
end

% Removing designs with invalid Farrar efficiency ( < 0.7 or NaN)
ds(isnan(ds.F), :) = []; 
% ds(ds.F < 0.7, :) = [];  

% Compute optimal rib spacing using Farrar equation
ds.L = (ds.F./(ds.sigma_cr*1e6)).^2 * N_max * (E_t * 1e9);  % [m]

% Compute crushing force
ds.I = c(c0) * 1000 * ds.t_eff * (b2(c0)*1000/2).^2 * 2;  % moment of inertia for both panels [mm^4]
ds.F_crush = (M_max^2 * ds.L .* ds.t_eff/1000 * b2(c0) * c(c0))./(2*E*1e9*ds.I/1e12);  % crushing force [N]

t_rib_y = @(crush_force) crush_force./(sigma_yield * 1e6 * c(c0));
t_rib_cr = @(crush_force) ((crush_force * b2(c0)^2)/(3.62 * E * 1e9 * c(c0))).^(1/3);


% Take the larger thickness value from the two formulas according to the
% stress criteria
if t_rib_y(ds.F_crush) > t_rib_cr(ds.F_crush)
    ds.t_rib = t_rib_y(ds.F_crush);  % [m]
else
    ds.t_rib = t_rib_cr(ds.F_crush);  % [m]
end


% % Removing design points with a rib thickness of more than 0.1m
% ds(ds.t_rib > 0.1, :) = [];

% Number of ribs is given by half_wingspan/L (Convert units)
ds.Nr = ceil(half_b./ ds.L);  

% Number of stringers is given by w_box/b (Convert units)
ds.Ns = ceil(c(c0)*1000./ds.b);  

% Removing design points where Nr > 50
% ds(ds.Nr > 50, :) = [];

% Remove number of stringers > 20
constraint1 = ds.F < 0.7;
constraint2 = ds.Nr > 30;
constraint3 = ds.t_rib > 0.1;

ds.isValid = ~(constraint1 | constraint2 | constraint3);
mask = ds.isValid == 1;

dsValid = ds(mask, :);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Weight function
% Total weight of ribs = Nr* t_rib * w_box * h_box * rho (check units)
% THE ABOVE WEIGHT EQUATION ASSUMES NO FLANGED HOLES, OR ANY
% WEIGHT-REDUCING STRUCTURE. 
% Total weight of skin-stringer panels = t_eff * w_box * half_b * rho
ds.Wr_total = ds.Nr .* ds.t_rib * c(c0) * b2(c0) * rho;
ds.Wss_total = ds.t_eff/1000 .* c(c0) * half_b * rho;  % what should it be?
ds.W_total = ds.Wr_total + ds.Wss_total;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Weight functions accounting for taper (UPPER WING SURFACE ONLY)
USW_pre_kink = @(t_eff) rho/2 * (c(c0) + c(c_kink)) * t_eff * 1e-3 * y_kink;
USW_post_kink = @(t_eff) rho/2 * (c(c_kink) + c(c_tip)) * t_eff * 1e-3 * (half_b - y_kink);

% Key parameters
y_kink = 10.5422 - 3.1309;  % spanwise position of wing kink - measured from the fuselage centreline [m]
c_kink = 7.4636;  % chord kink [m]

y_c0 = 3.1309;  % spanwise position of root chord [m]
c_c0 = 12.653;  % root chord (where wing meets fuselage) [m]

y_tip = 30.1207;  % spanwise position of tip chord [m] 
c_tip = 2.9102;  % tip chord [m]

%%% calculating the weight of the top surface of the idealised wing box
%%% with taper (PRE-KINK)
dsValid.Wss_taper_pre_kink = USW_pre_kink(dsValid.t_eff);

% POST-KINK WEIGHT
dsValid.Wss_taper_post_kink = USW_post_kink(dsValid.t_eff);

% TOTAL SKIN-STRINGER WEIGHT FOR UPPER WING SURFACE (TAPERED)
dsValid.Wss_total_tapered = dsValid.Wss_taper_post_kink + dsValid.Wss_taper_pre_kink;

% Tapered wing rib weight:
% Pre-kink: ribs are perpendicular to rear spar
% Post-kink: ribs are perpendicular to rear spar too (or trailing edge)

%%%%%%%%%%%% UNCOMMENT THIS BLOCK TO RECALCULATE TAPERED RIB WEIGHTS %%%%%%%%%%%% %%%%%%%%%%%% 
% Pre-allocate column for total tapered rib weights 
% dsValid.Wr_taper_total = zeros(height(dsValid), 1);
% 
% for i = 1:height(dsValid)
%     delta_y = dsValid.L(i);
%     NumRibs = dsValid.Nr(i);
% 
%     total_weight = 0;  % initialise total weight
% 
%     for rib = 1:NumRibs
%         rib_chord = odyGetChord(delta_y * rib + 3.1309);
%         rib_weight = dsValid.t_rib(i) * c(rib_chord) * b2(rib_chord) * rho;
%         total_weight = total_weight + rib_weight;
% 
%     end
% 
%     dsValid.Wr_taper_total(i) = total_weight;
% end
%%%%%%%%%%%% %%%%%%%%%%%% %%%%%%%%%%%% %%%%%%%%%%%% %%%%%%%%%%%% %%%%%%%%%%%% %%%%%%%%%%%% 
%% 

dsValid.W_taper_total = dsValid.Wr_taper_total + dsValid.Wss_total_tapered;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finding minimum weight line
% Take minimum weight at set intervals of rib spacing and spline
% MW_pairs = [0.00367214 54613; 0.0041236 50865.6; 0.00464661 47721.8;
            % 0.00601897 41177.3; 0.0010899 29140.8; 0.0133482 26048.3;
            % 0.013943 25436.4; 0.014586 24811.9; 0.0164678 23174.9; 
            % 0.0177441 22329.7; 0.0198113 20901.1; 0.0218437 19950.7;
            % 0.0237771 18758.4; 0.0321585 16293.6; 0.0353249 15682.1;
            % 0.0391369 14837; 0.0456848 13781.3; 0.0489564 13344.9; 
            % 0.0564791 12453.5; 0.0665028 11362.7; 0.0840975 10105.3;
            % 0.115842 8548.26; 0.137984 7883.76; 0.186994 6797.66;
            % 0.251248 6050.85; 0.318165 5415.83; 0.37829 5178.9; 
            % 0.430878 5034.11; 0.499035 4970.87; 0.592997 4905.91;
            % 0.70081 4933.25; 0.840052 5116.86; 0.979209 5291.58;
            % 1.11442 5461.88; 1.25726 5761.36; 1.40183 5988.22;
            % 1.57963 6256.54; 1.75169 6433.2; 1.92835 6702.31;
            % 2.12317 7021.39; 2.3263 7611.91; 2.43654 7730.1;
            % ];
            %% 

min_des_point = sortrows(dsValid, "W_taper_total", "ascend");
min_des_point = min_des_point(1, :);
disp("----- Minimum Design Point -----")
disp("Total weight (incl. taper): " + min_des_point.W_taper_total + "kg")
disp("Stringer spacing: " + min_des_point.b + "mm")
disp("Stringer thickness: " + min_des_point.t_s + "mm")
disp("Skin thickness: " + min_des_point.t + "mm" )
disp("Stringer height: " + min_des_point.h + "mm")
disp("Stringer flange width: " + min_des_point.d + "mm")
disp("Stringer flange thickness: " + min_des_point.t_d + "mm")
disp("Skin-stringer panel area: " + min_des_point.A_s + "mm")
disp("Skin-stringer effective thickness: " + min_des_point.t_eff + "mm")
disp("Global critical buckling stress: " + min_des_point.sigma_cr + " MPa")
disp("Compressive stress experienced: " + min_des_point.sigmaComp + " MPa")
disp("Farrar Efficiency: " + min_des_point.F)
disp("Rib spacing: " + min_des_point.L + "m")
disp("Rib thickness: " + min_des_point.t_rib*1000 + "mm")
disp("Number of ribs: " + min_des_point.Nr)
disp("Number of stringers: " + min_des_point.Ns)

 %% 
      
hold on
scatter(ds.L, ds.W_total, 10, "red", "filled", "o")
grid on
scatter(ds.L, ds.Wss_total_pre_kink, 10, "blue", "filled", "o")
scatter(ds.L, ds.Wr_total, 10, "black", "filled", "o")
alpha(0.01)
% MW_L = MW_pairs(:, 1);
% MW_W = MW_pairs(:, 2);
% plot(MW_L, MW_W, 'LineWidth', 2.5, 'Color', 'green');
xlabel("Rib spacing (m)")
ylabel("Total weight (kg)")
legend("Total", "Skin-stringer", "Ribs")
% legend("Total", "Skin-stringer", "Ribs", "Minimum Total Weight")

% Highlighting possible and impossible points
hold off
scatter(ds.L, ds.W_total, 10, "black", "filled", "o")
grid on
hold on
scatter(dsValid.L, dsValid.W_total, 10, "red", "filled", "o")

% alpha(0.2)
% MW_L = MW_pairs(:, 1);
% MW_W = MW_pairs(:, 2);

% plot(MW_L, MW_W, 'LineWidth', 2.5, 'Color', 'green');
% xlabel("Rib spacing (m)")
% ylabel("Total weight (kg)")
% title("Valid design space")
% legend("Invalid design points", "Feasible")
% 
% hold off
% scatter(ds.Nr, ds.Ns, 'red', 'o', 'filled')
% xlabel("Number of ribs")
% ylabel("Number of stringers on the skin")
% alpha(0.2)

