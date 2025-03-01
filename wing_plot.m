% Wing characteristics

load wing.mat
load fuselage.mat

% Input spanwise location (from fuselage centreline. Add 3.1309 to
% calculate from where wing meets fuselage
y = 3.1309;

% Calculate Characteristics
dihedral = 3.5;
local_twist = @(span_pos) span_pos/(wing.b/2);
if y<=wing.y_kink
chord = wing.c_root + ((wing.c_kink - wing.c_root)/((wing.y_kink)-0))*(y-0); % chords before kink
else
chord = wing.c_kink + ((wing.c_tip - wing.c_kink)/((wing.b/2)-wing.y_kink))*(y-wing.y_kink); % chords after kink
end
wing_shift = 23;
x_position = tand(wing.sweep_le) + wing_shift;

% Results
disp(['x position: ',num2str(x_position)])
disp(['chord: ',num2str(chord)])
disp(['twist: ',num2str(local_twist(y))])
disp(['dihedral: ',num2str(dihedral)])  