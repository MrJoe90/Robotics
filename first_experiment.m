classdef first_experiment

   properties (SetAccess = public)
       clientID % The variable to manage the Coppellia socket client
        leftMotor % right_wheel front handler
        rightMotor  % left wheel front handler
        front_left
        front_right
        sensorL
        sensorR    
        map 
        logic_map
        vrep       %  variable for the api
        to_do
        current_x
        current_y
        keyboard_event
        speed
        position
   end
   
   methods

   function self = first_experiment()
             close all
             clc
             %using the prototype file (remoteApiProto.m)
             self.to_do = 1;
             self.vrep=remApi('remoteApi'); 
             self.vrep.simxFinish(-1);  % ended all the pended connection
             self.clientID =self.vrep.simxStart('127.0.0.1',19999,true,true,5000,5);
             self.map = plot(10,5);
             %disp('inizio')
             errors_config=[];
             self.logic_map = zeros(10,5);
             %self.logic_map = self.logic_map+1/2;
             self.current_x=0;
             self.current_y=2; 
             self.speed=0.5;
             self.position=0;

             if self.clientID>-1
                   disp ("Client connected..");
                  [gestore,self.leftMotor]=self.vrep.simxGetObjectHandle(self.clientID,'Pioneer_p3dx_leftMotor',self.vrep.simx_opmode_oneshot_wait);
                  [gestore,self.rightMotor]=self.vrep.simxGetObjectHandle(self.clientID,'Pioneer_p3dx_rightMotor',self.vrep.simx_opmode_oneshot_wait);
                  [gestore,self.front_left]=self.vrep.simxGetObjectHandle(self.clientID,'Front_Left',self.vrep.simx_opmode_oneshot_wait);
                  [gestore,self.front_right]=self.vrep.simxGetObjectHandle(self.clientID,'Front_Right',self.vrep.simx_opmode_oneshot_wait);
                  [gestore,self.sensorL]=self.vrep.simxGetObjectHandle(self.clientID,'Pioneer_p3dx_ultrasonicSensor1',self.vrep.simx_opmode_oneshot_wait);
                  [gestore,self.sensorR]=self.vrep.simxGetObjectHandle(self.clientID,'Pioneer_p3dx_ultrasonicSensor2',self.vrep.simx_opmode_oneshot_wait);
                  %[gestore,self.position]= self.vrep.simxGetObjectPosition(self.clientID,'Robot_Learning',-1,self.vrep.simx_opmode_streaming);
                  for i=1: length(errors_config)
                     if errors_config(i)~= 0
                         disp('I cannot communicate properly with Coppelia due to an handler error');
                         break
                     end
                   end

            else
                  disp("No response from the socket interface..");
                  self.to_do=0;
             end
 
 end   

   
 function run(self)


      while self.to_do

         
          c= waitforbuttonpress;
          if c ==1 
              res= double(get(gcf,'CurrentCharacter'));
              self.keyboard_holder(res);
          end
    
          %[err,self.position] = sim.simxGetObjectPosition(self.clientID,self.keyboard_holder,-1,self.vrep.simx_opmode_streaming);
           disp(self.position);
          [errorCode, detectionState1, detectedPoint1, detectedObjectHandle, detectedSurfaceNormalVector] = self.vrep.simxReadProximitySensor(self. clientID, self.front_left, self.vrep.simx_opmode_streaming);
          [errorCode, detectionState3, detectedPoint3, detectedObjectHandle, detectedSurfaceNormalVector] = self.vrep.simxReadProximitySensor(self.clientID, self.sensorL, self.vrep.simx_opmode_streaming);
          [errorCode, detectionState4, detectedPoint4, detectedObjectHandle, detectedSurfaceNormalVector] = self.vrep.simxReadProximitySensor(self.clientID, self.sensorR, self.vrep.simx_opmode_streaming);

         if detectionState1==1
                 disp("sensors 1");
                 disp(cast(detectedPoint1(2)*100,"int8"))
                 self.map(cast(detectedPoint1(2)*100,"int8"),0,'.', 'MarkerSize', 30);
         else 
             disp ("Nothing in Range");
         end

         if detectionState3==1
                 disp("sensors 3");
                 disp(cast(detectedPoint3(2)*100,"int8"))
         else 
            
             disp ("Nothing in Range");
         end

         if detectionState4==1
                 disp("sensors 4");
                 disp(cast(detectedPoint4(2)*100,"int8"))
         else 
             disp ("Nothing in Range");
         end
             pause(1);
      end
      disp("end@");
      
          
 end

function keyboard_holder(self,event)
    
    disp(event);

    if (event==99)
        self.to_do=0;
        disp("wait the window event");
        close ('all', 'force');
    end
    
    if (event==28)
        disp("left");
        self.vrep.simxSetJointTargetVelocity(self.clientID, self.leftMotor, -self.speed, self.vrep.simx_opmode_streaming);
        self.vrep.simxSetJointTargetVelocity(self.clientID, self.rightMotor, self.speed, self.vrep.simx_opmode_streaming);
  
    end
    

    if (event==29)
        disp("right");
        self.vrep.simxSetJointTargetVelocity(self.clientID, self.leftMotor, self.speed, self.vrep.simx_opmode_streaming);
        self.vrep.simxSetJointTargetVelocity(self.clientID, self.rightMotor, -self.speed, self.vrep.simx_opmode_streaming);
  
    end

    
    if (event==30)
        disp("up");
        self.vrep.simxSetJointTargetVelocity(self.clientID, self.leftMotor, self.speed, self.vrep.simx_opmode_streaming);
        self.vrep.simxSetJointTargetVelocity(self.clientID, self.rightMotor, self.speed, self.vrep.simx_opmode_streaming);
    end


    if (event==31)
        disp("down");
        self.vrep.simxSetJointTargetVelocity(self.clientID, self.leftMotor, -self.speed, self.vrep.simx_opmode_streaming);
        self.vrep.simxSetJointTargetVelocity(self.clientID, self.rightMotor, -self.speed, self.vrep.simx_opmode_streaming);
  
    end
    


end

   
 end



end


 


  


 function main_thread(app)
        
        if app.first_sensors_call== true
             [result_sensors,~,err] = app.vrep.simxReadProximitySensor(app.clientID,app.sensors,app.vrep.simx_opmode_streaming);
             disp(result_sensors);
             app.first_sensors_call=false;
          else
              [e1,d,C] = app.vrep.simxReadProximitySensor(app.clientID,app.sensors,app.vrep.simx_opmode_streaming);
              error_velocity= app.vrep.simxSetJointTargetVelocity(app.clientID,app.leftwheel,0.2,app.vrep.simx_opmode_blocking);
              error_velocity= app.vrep.simxSetJointTargetVelocity(app.clientID,app.rightwheel,0.2,app.vrep.simx_opmode_blocking);
              [e1,d,C] = app.vrep.simxReadProximitySensor(app.clientID,app.sensors,app.vrep.simx_opmode_streaming);

        end
 end