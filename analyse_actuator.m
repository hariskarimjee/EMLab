addpath(genpath('C:\femm42'));

construct_actuator

% set number of steps for the armature to move and initialise 3D psi array
numOfSteps = 10;
psi = zeros(numOfSteps,4,11);

% for all the different currents, get inductances and hence psi values
for i = 0:1:10
    mi_setcurrent('winding_1', i);
    mi_setcurrent('winding_2', i);
    inductances = getInductances(blockProps, blockCoords, numOfSteps);
    psi(:,:,i+1) = inductances(:,2:5) * i;
end

figure('Name', 'Inductance - displacement')
hold on
plot(inductances(:,1), inductances(:,2), 'x');
plot(inductances(:,1), inductances(:,3), 'x');
plot(inductances(:,1), inductances(:,4), 'x');
plot(inductances(:,1), inductances(:,5), 'x');
hold off

function moveArmature(dx)
    mi_selectgroup(2)
    mi_movetranslate(dx,0)
    mi_clearselected()
end

function inductances = getInductances(blockProps, blockCoords, numOfSteps)
    % reset armature to zero, define max & min positions & step size
    armaturePos = 0.0;
    maxPos = -5;
    minPos = 0.0;
    stepSize = (maxPos-minPos)/(numOfSteps-1);

    % initialise arrays for each type of analysis (linear/non-linear)
    linearInductances = zeros(numOfSteps, 4);
    nonlinearInductance = zeros(numOfSteps,1);
    
    % set the core and mover properties to linear
    for i = 1:2
        mi_selectlabel(blockCoords(i,1), blockCoords(i,2));
        mi_setblockprop('core_linear', blockProps{i,2}, ...
                        blockProps{i,3}, blockProps{i,4}, ...
                        blockProps{i,5}, blockProps{i,6}, ...
                        blockProps{i,7});
        mi_clearselected
    end
    
    % for all the linear states, analyse and get inductances
    for i = 1:numOfSteps
        mi_purgemesh();
        mi_createmesh();
        linearInductances(i,:) = getLinearInductances(armaturePos);
        % catch to stop the mover being displaced into the core on last
        % iteration
        if i < numOfSteps
            moveArmature(stepSize);
            armaturePos = armaturePos + stepSize;
        end
    end
    
    % reset armature to zero displacement
    moveArmature(-armaturePos);    
    armaturePos = 0.0;
    
    % set core and mover properties to non-linear
    for i = 1:2
        mi_selectlabel(blockCoords(i,1), blockCoords(i,2));
        mi_setblockprop('core_nonlinear', blockProps{i,2}, ...
                        blockProps{i,3}, blockProps{i,4}, ...
                        blockProps{i,5}, blockProps{i,6}, ...
                        blockProps{i,7});
        mi_clearselected
    end  
    
    % for all the non-linear states, analyse and get inductances
    for i = 1:numOfSteps
        mi_purgemesh();
        mi_createmesh();
        nonlinearInductance(i) = nonlinearInductances();
        if i < numOfSteps
            moveArmature(stepSize);
            armaturePos = armaturePos + stepSize;
        end
    end
    
    % reset armature to zero displacement
    moveArmature(-armaturePos);
    armaturePos = 0.0;
    
    % collate all data outcomes
    inductances = [linearInductances(:,1) linearInductances(:,2) ...
                   linearInductances(:,3) linearInductances(:,4) ...
                   nonlinearInductance(:,1)];
end

function linearInductances = getLinearInductances(armaturePos)
    g = 5 + armaturePos;
    Rcore = (134.5e-3)/(4e-7 * pi * 1000 * 400e-6);
    Rair = (0.5e-3)/(4e-7 * pi * 400e-6);
    Rarmature = ((70 - g)*10^-3)/(4e-7 * pi * 1000 * 400e-6);
    Rairvariable = (g*10^-3)/(4e-7 * pi * 400e-6);
    Rtot = Rcore + Rair + Rarmature + Rairvariable;
    Rairfringe = (0.5e-3)/(4e-7 * pi * (20e-3 + g*10^-3)^2);
    Rairvariablefringe = (g*10^-3)/(4e-7 * pi * (20e-3 + g*10^-3)^2);
    Rtotfringe = Rcore + Rairfringe + Rarmature + Rairvariablefringe;
    Lanalytical = (100^2)/Rtot;
    Lanalyticalfringe = (100^2)/Rtotfringe;
    mi_saveas('linear.fem');
    mi_analyze();
    mi_loadsolution();
    CP = mo_getcircuitproperties('winding_1');
    Lnumericallinear = CP(3)/CP(1);
    linearInductances = [armaturePos Lanalytical ...
                         Lanalyticalfringe Lnumericallinear];
end



function Lnumericalnonlinear = nonlinearInductances()
    
    mi_saveas('nonlinear.fem');
    mi_analyze();
    mi_loadsolution();
    CP = mo_getcircuitproperties('winding_1');
    Lnumericalnonlinear = CP(3)/CP(1);
    
end