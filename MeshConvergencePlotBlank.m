%%% Plot mesh convergence %%% 

clf
clear
clc

m = [9056
10436
12291
15443
25626
54382
91512];

buckle = [13434
13438
13462
13424
13353
13033
13278];

def_max = [2.08261
2.08114
2.07842
2.08169
2.08654
2.08963
2.09076];

sgma_max = [481.252 
499.875
486.995
509.272
506.577
493.891
498.617];

plot(m, sgma_max, color="red")
hold on
scatter(m, sgma_max, "x", color="blue")
hold off