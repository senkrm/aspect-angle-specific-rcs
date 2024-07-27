%% Conversion of degrees-minutes-seconds to degrees
%  Only needed for radar location and it could be done once, airplane 
%  coordinates in dataset are already in degrees
%  Radar location in degrees: (Latitude, Longitude) = (42.424722, 42.1925)
%% Conversion of geographic coordinates to local cartesian coordinates
% Longitude and Latitude are in degrees, altitude in meters for flight data

origin = [42.424722, 42.1925, 0]; % Location of Radar
opts = detectImportOptions("sortie_5.csv"); % Determining reading options
opts.SelectedVariableNames = ["Longitude","Latitude","Altitude","Roll","Pitch","Yaw","Heading"]; % Needed variables
F = readtable("sortie_5.csv",opts); % Importing flight data

[xEast,yNorth] = latlon2local(F.Latitude,F.Longitude,F.Altitude,origin); % Global degrees to local meters conversion

figure
plot3(xEast,yNorth,F.Altitude);
hold on
grid on;
% ax = gca;
% tick_scale_factor = 0.001;
% ax.XTickLabel = ax.XTick * tick_scale_factor;
% ax.YTickLabel = ax.YTick * tick_scale_factor;
plot3(xEast,yNorth,F.Altitude,".",Linewidth=0.5 ,Color=[0 0.4470 0.7410]);
plot3(0,0,0,".",LineWidth=0.00001,Color=[0 0 0]);% Location of radar is the origin
axis image; % Set axis aspect ratio
title("Flight Trajectory")
daspect([1 1 0.4]);
xlabel("West-East (m)");
ylabel("North-South (m)");
zlabel("Altitude (m)","Rotation",0);
fontname("Times New Roman");
fontsize(50,"points")
% %% Conversion of global rectangular to local spherical 

[azimuth,elevation,Rng] = cart2sph(xEast,yNorth,F.Altitude); % Local cartesian (meters) lo local spherical (radians and meters conversion)

Az=rad2deg(azimuth);   % Radians to degrees conversion
El=rad2deg(elevation); % Radians to degrees conversion
%% Computation of aspect angle.

% ksi=heading angle , nu=pitch angle, zeta=roll angle of aircraft
% since heading angle is respect to north but x axis of radar is aligned to
% east, new heading angle is needed ksi_new=90-ksi

ksi=F.Heading;
ksi_new=ksi;% Due to explanation about heading angle adjustment at page 4 of the reference %When ksi is used instead of 90-ksi nose of the aircraft corresponds to 0 degrees instead of 90 degrees in azimuth
nu=F.Pitch;
zeta=F.Roll;

%According to "the reference" Eq.14a/b/c

V_AR_x_prime = -cosd(ksi_new).*cosd(nu).*sind(Az).*cosd(El)+sind(ksi_new).*cosd(nu).*cosd(Az).*cosd(El)-sind(nu).*sind(El); % Eq. 14a
V_AR_y_prime = -(cosd(ksi_new).*sind(nu).*sind(zeta)+sind(ksi_new).*cosd(zeta)).*sind(Az).*cosd(El)-(-sind(ksi_new).*sind(nu).*sind(zeta)+cosd(ksi_new).*cosd(zeta)).*cosd(Az).*cosd(El)+cosd(nu).*sind(zeta).*sind(El); % Eq. 14b
V_AR_z_prime = -(-cosd(ksi_new).*sind(nu).*cosd(zeta)+sind(ksi_new).*sind(zeta)).*sind(Az).*cosd(El)-(sind(ksi_new).*sind(nu).*cosd(zeta)+cosd(ksi_new).*sind(zeta)).*cosd(Az).*cosd(El)-cosd(nu).*cosd(zeta).*sind(El); % Eq. 14c

%% Final calculation for theta(Azimuth) and Phi(Elevation) aspect angles
theta =zeros(height(F),1);
phi = zeros(height(F),1);

for i = 1:height(F)
     theta(i)=(acosd(V_AR_x_prime(i)/(sqrt((V_AR_x_prime(i)).^2 + (V_AR_y_prime(i)).^2))));% Eq. 1 %Azimuth?
     phi(i)=atand(V_AR_z_prime(i)/(sqrt((V_AR_x_prime(i)).^2 + (V_AR_y_prime(i)).^2)));% Eq. 2 %Elevation?     
     progressbar(i/height(F))
end

aspect_angles=zeros(height(F),2);
aspect_angles(:,1)= theta;
aspect_angles(:,2)= phi;
varNames={'Azimuth', 'Elevation'};
T = table(theta,phi,'VariableNames',varNames);

writetable(T, 'sortie_5_aspect_angles.csv')

disp('Computation completed');