%%% mesh convergence %%%#

% blank_data = readtable("E:\Aeronautics\AVD\Detailed\WrkDir\max_values_results.csv");
new_data = readtable("E:\Aeronautics\AVD\Detailed\MESHCONV_FINALDESIGN\max_values_results.csv");
max_vm = new_data.("s_max");
mc = new_data.("element_count");
max_u = new_data.("u_max");
buckling_load = new_data.("P_crit");

% plot(mc, max_vm, LineWidth=2, color="red");
% hold on
% scatter(mc, max_vm, 100, "o", color="blue")
% xlabel("Mesh count")
% ylabel("Maximum Von Mises Stress (MPa)")
% title("Mesh convergence (final design)")
% % max_u = new_data.("u_max");
% grid on

% max_von_mises = blank_data.("sgma_max");
% % mesh_count = blank_data.("count");
% % buckling_load = blank_data.("buck");
% 
% plot(mc, max_vm, LineWidth=2, color="red");
% hold on
% scatter(mc, max_vm, 100, "o", color="blue")
% grid on
% xlabel("Mesh count")
% ylabel("Maximum Von Mises Stress (MPa)")
% title("Mesh convergence (blank geometry)")

%%
% plot(mc, max_vm, LineWidth=2, color="red");
% hold on
% scatter(mesh_count, max_von_mises, 100, "o", color="blue")
% grid on
% xlabel("Mesh count")
% ylabel("Maximum Von Mises Stress (MPa)")
% title("Mesh convergence (blank geometry)")

% %%
% plot(mc, max_u, LineWidth=2, color="red");
% hold on
% scatter(mc, max_u, 100, "o", color="blue")
% grid on
% xlabel("Mesh count")
% ylabel("Maximum displacement (mm)")
% title("Mesh convergence (final design)")
% 
% hold off
%%
plot(mc, buckling_load, LineWidth=2, color="red");
hold on
scatter(mc, buckling_load, 100, "o", color="blue")
grid on
xlabel("Mesh count")
ylabel("Buckling load (N)")
title("Mesh convergence (final design)")