%% Flight characteristics

opts = detectImportOptions("sortie_5.csv"); % Determining reading options
opts.SelectedVariableNames = ["Longitude","Latitude","Altitude","Roll","Pitch","Yaw","Heading"]; % Needed variables
F = readtable("sortie_5.csv",opts); % Importing flight data

figure%histograms
subplot(1,4,1);
histogram(F.Roll);
ylabel("Number of Samples")
xlabel("Roll (\zeta), deg.");


subplot(1,4,2);
histogram(F.Pitch);
xlabel("Pitch (\eta), deg.");


subplot(1,4,3);
histogram(F.Heading);
xlabel("Heading (\xi), deg.");
yticklabels(0:5000:25000);


subplot(1,4,4);
histogram(F.Altitude);
xlabel("Altitude (m)");


fontname("Times New Roman");
fontsize(20,"points")

figure%time series plots
subplot(4,1,1);
plot(F.Roll, "LineWidth",3)
ylabel("Roll (\zeta), deg.");
xticklabels(0:20:120);
yticks(-180:90:180);
xlim([0 height(F)])
grid

subplot(4,1,2);
plot(F.Pitch, "LineWidth",3)
ylabel("Pitch (\eta), deg.");
xticklabels(0:20:120);
yticks(-90:30:90);
xlim([0 height(F)])
grid

subplot(4,1,3);
plot(F.Heading, "LineWidth",3)
ylabel("Heading (\xi), deg.");
xticklabels(0:20:120);
yticks(0:90:360);
ylim([-10 370])
xlim([0 height(F)])
grid

subplot(4,1,4);
plot(F.Altitude, "LineWidth",3);
xlabel("time (seconds)");
ylabel("Altitude (m)")
xticklabels(0:20:120);
yticks(0:300:900);
ylim([0 850])
xlim([0 height(F)])
grid
fontname("Times New Roman");
fontsize(20,"points")