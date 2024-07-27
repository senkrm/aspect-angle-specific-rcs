%% Meshing
p = platform; 
p.FileName = "f-16.stl"; 
p.Units = "m";
figure
show(p)
zlabel("z (m)","Rotation",0);
legend off
t1 = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z');
fontname("Times New Roman");
fontsize(36,"points")
figure
mesh(p,MaxEdgeLength=0.02)% Out of memory at 0.018 m, 1.57 GHz wavelength corresponds to 0.019 m according to lambda/10 rule
t2 = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z');
fontname("Times New Roman");
%% RCS Simulation
az=0:1:361;
el=0;
platformsigma = zeros(361);
while el<=0 % Elevation is the variable, you can set to any value between 0-360 as desired, it determines the extent of the spherical simulation
frequency = 1.4e9;%1.4 GHz
sigma = rcs(p,frequency,az,el,Solver="PO", EnableGPU=false, Polarization="HH");
figure('DefaultTextFontName', "Times New Roman", 'DefaultAxesFontName', "Times New Roman");
rcs(p,frequency,az,el,Solver="PO", EnableGPU=false, Polarization="HH");
fontsize(50,"points")
saveas(gcf, [num2str(el), '_degrees_elevation_radial_RCS'], 'fig')
figure
plot(az, sigma)
title(['Elevation angle ',num2str(el),' deg.'])
xlabel("Azimuth angle (deg.)")
ylabel("RCS - dBsm")
% saveas(gcf, [num2str(el), '_degrees_elevation_RCS'], 'fig')
t3 = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z');
el = el+1;
platformsigma(:,el) = sigma;
end
%% Write the results as csv and txt files
writematrix(platformsigma,'f16RCS.csv');
writematrix(platformsigma,'f16RCS_tab.txt','Delimiter','tab')
%% Simulation duration
t4 = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z');
duration = t4-t1;
disp(t1)
disp(t4)
disp(duration)