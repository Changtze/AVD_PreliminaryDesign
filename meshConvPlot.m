%%% mesh convergence %%%

% blank_data = readtable("E:\Aeronautics\AVD\Detailed\WrkDir\max_values_results.csv");
stress = readtable("F:\AVD Detailed Design\HexVonMises\max_values_results.csv");

% max_displacement = blank_data.("u_max");
% max_von_mises = blank_data.("sgma_max");
% mesh_count = blank_data.("count");
% buckling_load = blank_data.("buck");

max_vm = stress.("s_max");
mc = stress.("mc");
plot(mc, max_vm, LineWidth=2, color="red");
hold on
scatter(mc, max_vm, 100, "o", color="blue")
grid on
xlabel("Mesh count")
ylabel("Maximum Von Mises Stress (MPa)")
title("Mesh convergence (blank geometry)")

%%
% plot(mesh_count, max_von_mises, LineWidth=2, color="red");
% hold on
% scatter(mesh_count, max_von_mises, 100, "o", color="blue")
% grid on
% xlabel("Mesh count")
% ylabel("Maximum Von Mises Stress (MPa)")
% title("Mesh convergence (blank geometry)")
% 
% hold off
% %%
% plot(mesh_count, max_displacement, LineWidth=2, color="red");
% hold on
% scatter(mesh_count, max_displacement, 100, "o", color="blue")
% grid on
% xlabel("Mesh count")
% ylabel("Maximum displacement (mm)")
% title("Mesh convergence (blank geometry)")
% 
% hold off
% %%
% plot(mesh_count, buckling_load, LineWidth=2, color="red");
% hold on
% scatter(mesh_count, buckling_load, 100, "o", color="blue")
% grid on
% xlabel("Mesh count")
% ylabel("Buckling load (N)")
% title("Mesh convergence (blank geometry)")