addpath(genpath('C:/femm42'));

construct_actuator


blockCoords = [(min(components{1}(:,1)) + 3) mean(components{1}(:,2));
                mean(components{2}(:,1)) mean(components{2}(:,2));
                mean(components{3}(:,1)) mean(components{3}(:,2));
                mean(components{4}(:,1)) mean(components{4}(:,2));
                mean(components{5}(:,1)) mean(components{5}(:,2));
                mean(components{6}(:,1)) mean(components{6}(:,2));
                -25 0];
            
blockProps = {'core_linear' 1 0 '<None>' 0 1 0;
              'core_linear' 1 0 '<None>' 0 2 0;
              'copper' 1 0 'winding_1' 0 3 100;
              'copper' 1 0 'winding_1' 0 4 -100;
              'copper' 1 0 'winding_2' 0 5 100;
              'copper' 1 0 'winding_2' 0 6 -100;
              'air' 1 0 '<None>' 0 7 0};


steps = 50;
armaturePosition = 0.0;
minPos = 0.0;
maxPos = -5.0;
stepSize = (maxPos - minPos + 0.1) / (steps - 1);

L = zeros(steps, 5, 11);
Ec = zeros(steps, 1);

%function to loop through and analyse each armature position for current
%ranging from 0:10A
for p = 1:steps
    armaturePosition
    mi_purgemesh();
    mi_createmesh();
    set_linear(blockCoords, blockProps);
    for i = 0:1:10
        mi_setcurrent('winding_1', i);
        mi_setcurrent('winding_2', i);
        L(p, 1:4, i+1) = linear_inductances(armaturePosition);
    end
    set_nonlinear(blockCoords, blockProps);
    for i  = 0:1:10
        mi_setcurrent('winding_1', i);
        mi_setcurrent('winding_2', i);
        [L(p, 5, i+1), Ec(p)] = nonlinear_inductances();
    end
    move_armature(stepSize, armaturePosition, maxPos);
    armaturePosition = armaturePosition + stepSize;
end

%
function move_armature(dx, armPos, maxPos)
    if armPos > maxPos
        mi_selectgroup(2);
        mi_movetranslate(dx,0);
        mi_clearselected();
    end
end

function linInd = linear_inductances(armPos)
    g = 5 + armPos;
    Rcore = (134.5e-3)/(4e-7 * pi * 1000 * 400e-6);
    Rair = (0.5e-3)/(4e-7 * pi * 400e-6);
    Rarmature = ((70 - g)*10^-3)/(4e-7 * pi * 1000 * 400e-6);
    Rairvariable = (g*10^-3)/(4e-7 * pi * 400e-6);
    Rtot = Rcore + Rair + Rarmature + Rairvariable;
    Rairfringe = (0.5e-3)/(4e-7 * pi * (20e-3 + 2*0.5e-3)^2);
    Rairvariablefringe = (g*10^-3)/(4e-7 * pi * (20e-3 + 2*g*10^-3)^2);
    Rtotfringe = Rcore + Rairfringe + Rarmature + Rairvariablefringe;
    Lanalytical = (100^2)/Rtot;
    Lanalyticalfringe = (100^2)/Rtotfringe;
    mi_saveas('linear.fem');
    mi_analyze();
    mi_loadsolution();
    CP = mo_getcircuitproperties('winding_1');
    Lnumericallinear = CP(3)/CP(1);
    % Inductance values doubled as they are based off of the half
    % circuit
    linInd = [armPos 2*Lanalytical ...
                         2*Lanalyticalfringe 2*Lnumericallinear];
end

function [nonLinInd, Ec] = nonlinear_inductances()
    mi_saveas('nonlinear.fem');
    mi_analyze();
    mi_loadsolution();
    CP = mo_getcircuitproperties('winding_1');
    mo_groupselectblock();
    Ec = mo_blockintegral(17);
    nonLinInd = 2*CP(3)/CP(1);
end

function set_linear(blockCoords, blockProps)
    for i = 1:2
        mi_selectlabel(blockCoords(i,1), blockCoords(i,2));
        mi_setblockprop('core_linear', blockProps{i,2}, ...
                        blockProps{i,3}, blockProps{i,4}, ...
                        blockProps{i,5}, blockProps{i,6}, ...
                        blockProps{i,7});        
        mi_clearselected
    end
end

function set_nonlinear(blockCoords, blockProps)
    for i = 1:2
        mi_selectlabel(blockCoords(i,1), blockCoords(i,2));
        mi_setblockprop('core_nonlinear', blockProps{i,2}, ...
                        blockProps{i,3}, blockProps{i,4}, ...
                        blockProps{i,5}, blockProps{i,6}, ...
                        blockProps{i,7});
        mi_clearselected
    end  
end
