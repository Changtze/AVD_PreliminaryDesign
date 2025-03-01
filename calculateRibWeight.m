function rib_weight = calculateRibWeight(rib_thickness, rib_width, rib_height, rho)
% Assumes a rectangular rib
% 
% Calculates rib weight based on 7075 Aluminium Alloy
rib_weight = rib_thickness  * rib_width * rib_height * rho;
end