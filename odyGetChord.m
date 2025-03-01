function chord = getChord(y)
% Spanwise coordinate measured from datum line
% Gets the chord at a distance y from the fuselage centreline
load wing.mat
load fuselage.mat

if y<=wing.y_kink
chord = wing.c_root + ((wing.c_kink - wing.c_root)/((wing.y_kink)-0))*(y-0); % chords before kink
else
chord = wing.c_kink + ((wing.c_tip - wing.c_kink)/((wing.b/2)-wing.y_kink))*(y-wing.y_kink); % chords after kink
end

end