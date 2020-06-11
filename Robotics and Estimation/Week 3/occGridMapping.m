% Robotics: Estimation and Learning 
% WEEK 3
% 
% Complete this function following the instruction. 
function myMap = occGridMapping(ranges, scanAngles, pose, param)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% Parameters 
% 
% % the number of grids for 1 meter.
myResol = param.resol;
r = param.resol;
% % the initial map size in pixels
myMap = zeros(param.size);
% % the origin of the map in pixels
myorigin = param.origin; 
% 
% % 4. Log-odd parameters 
lo_occ = param.lo_occ;
lo_free = param.lo_free; 
lo_max = param.lo_max;
lo_min = param.lo_min;

% No need to calculate Scan angles as they are invariant to time. They are
% with respect to the body frame
a = scanAngles; 
N = size(pose,2);
n = size(a,1);
for j = 1:N % for each time,

    % Get the poses at the current timeStemp
        x = pose(1,j);
        y = pose(2,j);
    theta = pose(3,j);
    
    % Get all the range values from Lidar
    d = ranges(:,j);
    
    % Get the real Location of points
    pOcc = [d'.*cos(theta + a'); -d'.*sin(theta + a')] + [x; y];
    
%     for angle = 1:n
%       % Find grids hit by the rays (in the gird map coordinate)
%       x_o(angle) = ranges(angle,j) * cos(scanAngles(angle,1) + pose(3,j)) + pose(1,j);
%       y_o(angle) = -1*ranges(angle,j) * sin(scanAngles(angle,1) + pose(3,j)) + pose(2,j);
%       occ= [ceil(x_o*r)+myorigin(1); ceil(y_o*r) + myorigin(2)];
%       car = [ceil(pose(1,j)*r) + myorigin(1)  ceil(pose(2,j)*r) + myorigin(2)];
%     end
    
    % Get the indexed location of the Robot
    currLoc = ceil(myResol * [x;y]) + myorigin;
    
    % Find grids hit by the rays (in the gird map coordinate)
    iOcc = (ceil(myResol * pOcc)  + myorigin)';
    
    % Find occupied-measurement cells and free-measurement cells
    for t = 1 : size(iOcc,1)
        xPos = iOcc(t,1);
        yPos = iOcc(t,2);
        
        % Results were better if used this instead of directly indexing
        RoboIDX = sub2ind(size(myMap),yPos,xPos);
        myMap(RoboIDX) = myMap(RoboIDX) + lo_occ;
        [freex,freey]  = bresenham(currLoc(1),currLoc(2),xPos,yPos);
        FreeIDX = sub2ind(size(myMap),freey,freex);
        myMap(FreeIDX) = myMap(FreeIDX)-lo_free;
    end
    

    % Saturate the log-odd values
    myMap = min(myMap,lo_max);
    myMap = max(myMap,lo_min);
    
%     % Visualize the map as needed
%     imagesc(myMap);
%     colormap('gray'); 
%     axis equal;
%     drawnow limitrate
%     
%     % Display Iteration:
%     fprintf("timestep: %d \n", j)
end

end

