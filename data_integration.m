%% RCS Data and Aspect Angle Integration
%% Reading RCS data
RCS = readtable("f16RCS.csv"); % Importing flight data columns are elevation, rows are azimuth, both starting from 0 degrees
%% Reading Aspect Angle Data
opts = detectImportOptions("sortie_5_aspect_angles.csv"); % Determining reading options
opts.SelectedVariableNames = ["Azimuth","Elevation"]; % Needed variables
AA = readtable("sortie_5_aspect_angles.csv",opts); % Importing flight data
AspectAngle = round(AA); %Since RCS data is generated only with decimal degree values, any decimals should be rounded to nearest decimal for integration
optsM = detectImportOptions("sortie_5_aspect_angles_manipulated.csv"); % Determining reading options
optsM.SelectedVariableNames = ["Azimuth","Elevation"]; % Needed variables
AAM = readtable("sortie_5_aspect_angles_manipulated.csv",optsM); % Importing flight data
AspectAngleM = round(AAM); %Since RCS data is generated only with decimal degree values, any decimals should be rounded to nearest decimal for integration
%% Integrating RCS and Aspect Angle Data
IntegratedData=zeros(height(AspectAngle),1);
IntegratedDataM=zeros(height(AspectAngleM),1);
i=1;
j=1;
RCSArray=table2array(RCS);
while i<=height(AspectAngle)
elevation=AspectAngle{i,2}; 
azimuth=AspectAngle{i,1};
    if elevation<0 % Since aspect angle calculation can result negative values and RCS simulaton is done within 0-360 degrees a transformation must be carried out
        elevation=(-elevation+180); % -90° of aspect angle calculation corresponds 270° for RCS table, -60°->240° and -30°->210 the calculation is 180+(-(negative angle value)
    end
IntegratedData(i)=RCSArray(azimuth+1,elevation+1);% RCS simulation angles start from 0 but array indices start from 1
i=i+1;
end

while j<=height(AspectAngleM)
elevationM=AspectAngleM{j,2}; 
azimuthM=AspectAngleM{j,1};
    if elevationM<0 % Since aspect angle calculation can result negative values and RCS simulaton is done within 0-360 degrees a transformation must be carried out
        elevationM=(-elevationM+180); % -90° of aspect angle calculation corresponds 270° for RCS table, -60°->240° and -30°->210 the calculation is 180+(-(negative angle value)
    end
IntegratedDataM(j)=RCSArray(azimuthM+1,elevationM+1);% RCS simulation angles start from 0 but array indices start from 1
j=j+1;
end

instancenumber=1:1:height(AspectAngle);
figure
subplot(1,2,1)
histogram(AspectAngle.Azimuth)
xlabel("Azimuth (\theta), deg.")
ylabel("Number of instances")
subplot(1,2,2)
histogram(AspectAngle.Elevation)
xlabel("Elevation (\phi), deg.")
fontname("Times New Roman");
fontsize(30,"points")

offset=zeros(height(IntegratedData),1);
figure
plot(IntegratedData, Color=[1 0 0], LineWidth=1.5)
hold on
plot(offset, Color=[0 0 0], linewidth=1)
hold on
plot(IntegratedDataM, Color="#0072BD",LineWidth=2)
xlim([0, 113648])
ylabel("dBsm", "Rotation", 0);
xlabel("time (seconds)");
xticklabels({'0','20','40','60','80','100','120'});
fontname("Times New Roman");
fontsize(32,"points")

legend("Full disturbance","","Zero roll&pitch");

origin = [42.424722, 42.1925, 0]; % Location of Radar
opts = detectImportOptions("sortie_5.csv"); % Determining reading options
opts.SelectedVariableNames = ["Longitude","Latitude","Altitude","Roll","Pitch","Yaw","Heading"]; % Needed variables
F = readtable("sortie_5.csv",opts); % Importing flight data

[xEast,yNorth] = latlon2local(F.Latitude,F.Longitude,F.Altitude,origin); % Global degrees to local meters conversion

figure;
plot3(xEast,yNorth,F.Altitude,Linewidth=6,Color=[0 0.4470 0.7410]);
hold on
plot3(xEast,yNorth,IntegratedData.*50,Linewidth=0.5,Color=[1 0 0]);
hold on
grid on;
plot3(0,0,0,".",LineWidth=10,Color=[1 1 1]);% Location of radar is the origin
daspect([1 1 0.4]);
xlabel("W-E (km)");
xticklabels({-10 -5 0})
ylabel("N-S (km)");
yticklabels({ -30 -25 -20 -15 -10 -5})
zlabel("Alt (m)","Rotation",0);
zticks([-2000 500])
zticklabels({0 500})
fontname("Times New Roman");
fontsize(32,"points")

pctErrorRCS = mean(100 * abs(IntegratedDataM-IntegratedData) ./ IntegratedData); % c1 is the reference, mean error between two RCS estimations estimated;

RCSDiff = abs(IntegratedData-IntegratedDataM);
figure
plot(RCSDiff, Color="#666666", LineWidth=1);
xlabel("time (seconds)");
ylabel("Difference (dBsm)");
xlim([0, 113648])
xticklabels({'0','20','40','60','80','100','120'});
fontname("Times New Roman");
fontsize(32,"points")
figure
histogram(RCSDiff, FaceColor=[0 0 0], EdgeColor=[0 0 0]);
xlabel("Difference (dBsm)");
ylabel("Instance number");
xlim([0, 41])
fontname("Times New Roman");
fontsize(32,"points")