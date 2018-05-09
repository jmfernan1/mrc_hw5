clear all; clc; close all
% Create a bag file object with the file name
bag = rosbag('~/mrc_hw5_data/joy1.bag');
   
% Display a list of the topics and message types in the bag file
bag.AvailableTopics;
   
% Since the messages on topic /odom are of type Odometry,
% let's see some of the attributes of the Odometry

% This helps determine the syntax for extracting data
msg_odom = rosmessage('nav_msgs/Odometry');
showdetails(msg_odom);
   
% Get just the topic we are interested in
bagselect = select(bag,'Topic','/odom');
   
% Create a time series object based on the fields of the turtlesim/Pose
% message we are interested in
ts = timeseries(bagselect,'Pose.Pose.Position.X','Pose.Pose.Position.Y',...
    'Twist.Twist.Linear.X','Twist.Twist.Angular.Z',...
    'Pose.Pose.Orientation.W','Pose.Pose.Orientation.X',...
    'Pose.Pose.Orientation.Y','Pose.Pose.Orientation.Z');

x=ts.data(:,1);
y=ts.data(:,2);
vel=ts.data(:,3);
e=quat2eul([ts.data(:,5) ts.data(:,6) ts.data(:,7) ts.data(:,8)]);
yaw=(e(:,1));
yaw=yaw*180/pi;

u=vel.*cos(yaw);
v=vel.*sin(yaw);
ii=1:10:length(x);

% The time vector in the timeseries (ts.Time) is "Unix Time"
% which is a bit cumbersome.  Create a time vector that is relative
% to the start of the log file
tt = ts.Time-ts.Time(1);
% Plot the X position vs time
%figure(1);
%clf();
%plot(tt,ts.Data(:,1))
%xlabel('Time [s]')
%ylabel('X [m]')

figure
plot(x,y);title('X vs Y');
xlabel('X (m)'); ylabel('Y (m)'); hold on
plot(x(1),y(1),'g*'); hold on
plot(x(1799),y(1799),'r*'); hold off; legend('path','start','stop');
figure
plot(tt,yaw); title('Yaw vs Time');
xlabel('Time (s)'); ylabel('Yaw (deg)'); legend('Yaw');
figure
plot(tt,vel,'b.:'); title('FWD Velocity vs Time');
xlabel('Time (s)'); ylabel('Forward Velocity (m/s)');
figure
quiver(x(ii),y(ii),u(ii),v(ii)); title('Quiver Plot of Bot');
xlabel('X (m)'); ylabel('Y (m)'); hold on
plot(x(1),y(1),'g*'); hold on
plot(x(1799),y(1799),'r*'); hold off; legend('path','start','stop');
