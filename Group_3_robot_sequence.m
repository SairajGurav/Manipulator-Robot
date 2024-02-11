clc;
clear;

% % Setting Parameters
robo = legoev3('USB');

% Declaration of Sensors
t_sens1 = touchSensor(robo,1);
t_sens2 = touchSensor(robo,3);
sonicsens = sonicSensor(robo,2);

% Declaration of motors and starting it
claw = motor(robo,'A');
incl = motor(robo,'B');
base = motor(robo,'C');
start(base)
start(incl)
start(claw)

% Initial Parameter for stations
a = [-90,0];
b = [0,0];
c = [90,0];

disp("Going to home position")
disp(" ")

% Inspecting the Environment for stations height

flag0 = 0;
while(flag0 == 0)
    disp("Inspecting the Environment for stations height")
    disp(" ")
    home(t_sens1,base,t_sens2,incl,claw);           % Homing the Robot

    locate(base,a(1));                              % Moving to A station
    a(2) = readdis(sonicsens);                      % Measuring Height of A station
    
    home(t_sens1,base,t_sens2,incl,claw);           % Moving to B or Home station
    b(2) = readdis(sonicsens);                      % Measuring Height of B station
    
    locate(base,c(1));                              % Moving to C station
    c(2) = readdis(sonicsens);                      % Measuring Height of C station

    home(t_sens1,base,t_sens2,incl,claw)
    flag0 = 1;
end

% Displaying station values

disp("The height of station A = ")
disp(a(2))
disp("The height of station B = ")
disp(b(2))
disp("The height of station C = ")
disp(c(2))

% Task Sequence to be performed

p_ick = ['b','c','a','b','a','c'];
p_lace =['c','a','b','a','c','b'];

for d = 1:1:6
    switch p_ick(d)
        case 'a'
            disp(" ")
            disp('Now picking ball from A station')
            base_thetai = a(1);
            theta2 = calc_inv(a(2));
            
        case 'b'
            disp(" ")
            disp('Now picking ball from B station')
            base_thetai = b(1);
            theta2 = calc_inv(b(2));
            
        case 'c'
            disp(" ")
            disp('Now picking ball from C station')
            base_thetai = c(1);
            theta2 = calc_inv(c(2));
       
    end
    pause(0.5)
    
    switch p_lace(d)
        case 'a'
             switch p_ick(d)
                case 'a'
                    base_thetaf = 0;
                case 'b'
                    base_thetaf = -90;
                case 'c'
                    base_thetaf = -180;
             end    
            disp('Now placing ball at A station')
            theta2_f = calc_inv(a(2));
            
        case 'b'
            switch p_ick(d)
                case 'a'
                    base_thetaf = 90;
                case 'b'
                    base_thetaf = 0;
                case 'c'
                    base_thetaf = -90;
             end 
            disp('Now placing ball at B station')
            theta2_f = calc_inv(b(2));
            
        case 'c'
            switch p_ick(d)
                case 'a'
                    base_thetaf = 180;
                case 'b'
                    base_thetaf = 90;
                case 'c'
                    base_thetaf = 0;
            end
            disp('Now placing ball at C station')
            theta2_f = calc_inv(c(2));
            
    end
    pause(0.5)
    
    locate(base,base_thetai);                           % Locating picking base 
    pick(incl,claw,t_sens2,theta2);                     % Calling picking funtion to pick up the ball
    
    locate(base,base_thetaf);                           % Locating placing base
    place(incl,claw,t_sens2,theta2_f);                  % Calling placing funtion to place the ball
    
    home(t_sens1,base,t_sens2,incl,claw);
end

% Homing function to go to home position

function home(t_sens1,base,t_sens2,incl,claw)               
    while(readTouch(t_sens2)~=1)
        incl.Speed = -30;
    end
    incl.Speed=0;
    resetRotation(incl)

    while(readTouch(t_sens1)~=1)
        base.Speed = 30;  
    end
    base.Speed=0;

    resetRotation(base)
    rot_base=3.3*90;

    if(rot_base >= (-readRotation(base)))
        while(rot_base >=(-readRotation(base)))
            readRotation(base);
            base.Speed = -30;
        end
        base.Speed=0;
    resetRotation(base)
    end

    pause(0.5)
    resetRotation(base)
    resetRotation(incl)
    claw.Speed = +5;
end

% Station Locating function

function locate(base,theta)                                 
    rot_base = 3.3 * theta;
    if(rot_base >= (-readRotation(base)))
        while(rot_base >= (-readRotation(base)))
            readRotation(base);
            base.Speed = -30;
        end
    elseif(rot_base < (-readRotation(base)))
        while(rot_base <= -readRotation(base))
            readRotation(base);
            base.Speed = +30;
        end
    end
    
    resetRotation(base)
    base.Speed=0;
    pause(0.5)
end

% Picking function

function pick(incl,claw,t_sens2,theta2)                      
    resetRotation(incl)

    rot_incl = theta2;
    claw.Speed = -4;                                      % Claw opening
    pause(0.4)
    claw.Speed = 0;   
    
    while(rot_incl> readRotation(incl))                 % Moving arm link down
        incl.Speed = 25;
    end
    incl.Speed = 0;

    claw.Speed = 40;                                      % Claw closing
    pause(0.7)
    claw.Speed = 0;
    
    while(readTouch(t_sens2)~=1)                        % Moving arm link up
        incl.Speed = -50;
    end
    incl.Speed = 0;
    resetRotation(incl)  
end

% Placing function

function place(incl,claw,t_sens2,theta2)                    
    resetRotation(incl);

    rot_incl=theta2;
    while(rot_incl>readRotation(incl))                  % Moving arm link down
        readRotation(incl);
        incl.Speed = 25;
    end
    incl.Speed = 0;

    claw.Speed = -5;                                      % Claw opening
    pause(0.4)
    claw.Speed = 0;
    
    while(readTouch(t_sens2)~=1)                        % Moving arm link up
        incl.Speed = -50;
    end
    incl.Speed = 0;
    
    
    claw.Speed=40;                                      % Claw closing
    pause(0.7)
    claw.Speed=0;

    resetRotation(incl);
end

% Read distance function

function dis = readdis(sonicsens)
    dis = readDistance(sonicsens);    
end

 % Inverse kinematics function

function theta_2 = calc_inv(Z)                         
    O_ffset = 55;
    l0 = 70;
    l1 = 50;
    l2 = 95;
    l3 = 185;
    l4 = 110;
    
    theta_2 = (asind((l4 - O_ffset + Z*1000 - l2*sind(45) - l1 - l0)/l3) + 45) * 4 ;
    %disp(theta_2)    

end
