addpath(genpath('C:\femm42'));
openfemm()
opendocument('femm_template.fem');
mi_saveas('actuator.fem');

load('coil1p.mat');
load('coil2p.mat');
load('coil3p.mat');
load('coil4p.mat');
load('corep.mat');
load('moverp.mat');

armaturePos = 0;
components = {corep moverp coil1p coil2p coil3p coil4p};

mi_probdef(0, 'millimeters', 'planar', 1e-008, 20, 30, 0)

mi_addnode(corep(:,1), corep(:,2))
mi_addnode(coil1p(:,1),coil1p(:,2))
mi_addnode(coil2p(:,1), coil2p(:,2))
mi_addnode(coil3p(:,1), coil3p(:,2))
mi_addnode(coil4p(:,1), coil4p(:,2))
mi_addnode(moverp(:,1), moverp(:,2))



for i = 1:length(components)
    modifyNodes(components{i});
    addLines(components{i});
end

blockCoords = [(min(corep(:,1)) + 3) mean(corep(:,2));
                mean(moverp(:,1)) mean(moverp(:,2));
                mean(coil1p(:,1)) mean(coil1p(:,2));
                mean(coil2p(:,1)) mean(coil2p(:,2));
                mean(coil3p(:,1)) mean(coil3p(:,2));
                mean(coil4p(:,1)) mean(coil4p(:,2));
                -25 0];
blockProps = {'core_linear' 1 0 '<None>' 0 1 0;
              'core_linear' 1 0 '<None>' 0 2 0;
              'copper' 1 0 'winding_1' 0 3 100;
              'copper' 1 0 'winding_1' 0 4 -100;
              'copper' 1 0 'winding_2' 0 5 100;
              'copper' 1 0 'winding_2' 0 6 -100;
              'air' 1 0 '<None>' 0 7 0};
            
            
for i = 1:max(size(blockCoords))
    mi_addblocklabel(blockCoords(i,1), blockCoords(i,2));
    mi_selectlabel(blockCoords(i,1), blockCoords(i,2));
    mi_setblockprop(blockProps{i,1}, blockProps{i,2}, blockProps{i,3}, blockProps{i,4}, blockProps{i,5}, blockProps{i,6}, blockProps{i,7});
    mi_clearselected
end

mi_makeABC();
smartmesh(1);
mi_setcurrent('winding_1', 10);
mi_setcurrent('winding_2', 10);


% CP = mo_getcircuitproperties('winding_1');
% mo_groupselectblock(3)
% A = mo_blockintegral(5);
% V = mo_blockintegral(10);
% mo_clearblock()
% l = V/A;
% sigma = 58e6;
% kpf = 0.6;
% l_real = 125.47e-3;
% Rw = 100*l_real/(sigma*((kpf*A)/100));
% Rfem = CP(2)/CP(1);
% current = 0:0.1:10;
% power_diss_real = current.^2 * Rw;
% power_diss_femm = current.^2 * Rfem;
linearInductances = zeros(50, 4);
for i = 0:10:40
    mi_purgemesh();
    mi_createmesh();
    linearInductances(i + 1,:) = getLinearInductances(armaturePos);
    moveArmature(-1);
    armaturePos = -0.1*i - 1;
end

moveArmature(-armaturePos)
armaturePos = 0;
for i = 1:2
    mi_selectlabel(blockCoords(i,1), blockCoords(i,2));
    mi_setblockprop('core_nonlinear', blockProps{i,2}, blockProps{i,3}, blockProps{i,4}, blockProps{i,5}, blockProps{i,6}, blockProps{i,7});
    mi_clearselected
end

nonlinearInductance = zeros(50,1);

for i = 0:10:40
    mi_purgemesh();
    mi_createmesh();
    nonlinearInductance(i+1) = nonlinearInductances();
    moveArmature(-1);
    armaturePos = -0.1*i;
end    

% mi_createmesh();
% mi_analyze();
% mi_loadsolution();

inductances = [linearInductances(:,1) linearInductances(:,2) linearInductances(:,3) linearInductances(:,4) nonlinearInductance(:,1)];

hold on
plot(inductances(:,1), inductances(:,2), 'x');
plot(inductances(:,1), inductances(:,3), 'x');
plot(inductances(:,1), inductances(:,4), 'x');
plot(inductances(:,1), inductances(:,5), 'x');
hold off

mi_saveas('actuator.fem');

function linearInductances = getLinearInductances(armaturePos)
    g = 5+armaturePos;
    Rcore = (134.5e-3)/(4e-7 * pi * 1000 * 400e-6);
    Rair = (0.5e-3)/(4e-7 * pi * 400e-6);
    Rarmature = ((70 - g)*10^-3)/(4e-7 * pi * 1000 * 400e-6);
    Rairvariable = (g*10^-3)/(4e-7 * pi * 400e-6);
    Rtot = Rcore + Rair + Rarmature + Rairvariable;
    Rairfringe = (0.5e-3)/(4e-7 * pi * (20e-3 + g*10^-3)^2);
    Rairvariablefringe = (g*10^-3)/(4e-7 * pi * (20e-3 + g*10^-3)^2);
    Rtotfringe = Rcore + Rairfringe + Rarmature + Rairvariablefringe;
    Lanalytical = 100^2/Rtot;
    Lanalyticalfringe = 100^2/Rtotfringe;
    mi_saveas('linear.fem');
    mi_analyze();
    mi_loadsolution();
    CP = mo_getcircuitproperties('winding_1');
    Lnumericallinear = CP(3)/CP(1);
    linearInductances = [armaturePos Lanalytical Lanalyticalfringe Lnumericallinear];
end

function Lnumericalnonlinear = nonlinearInductances()
    
    mi_saveas('nonlinear.fem');
    mi_analyze();
    mi_loadsolution();
    CP = mo_getcircuitproperties('winding_1');
    Lnumericalnonlinear = CP(3)/CP(1);
    
end

function moveArmature(dx)
    mi_selectgroup(2)
    mi_movetranslate(dx,0)
    mi_clearselected()
end

function modifyNodes(component)
    for j = 1:size(component,1)
        mi_selectnode(component(j,1), component(j,2));
        mi_setnodeprop(component, component(j,3));
        mi_clearselected
    end
end

function addLines(component)
    for j = 1:size(component,1)
        if j<size(component,1)
            mi_addsegment(component(j,1), component(j,2), component(j+1,1), component(j+1,2));
            if j == 10 && component(j,3) == 1
                mi_selectsegment(midpoint([component(j,1) component(j,2) component(j+1,1) component(j+1,2)]));
                mi_setsegmentprop('<None>', 0.5, 0, 0, component(j,3));
            end
            mi_selectsegment(midpoint([component(j,1) component(j,2) component(j+1,1) component(j+1,2)]));
            mi_setsegmentprop('<None>', 0, 1, 0, component(j,3));
            mi_clearselected
        else
            mi_addsegment(component(j,1), component(j,2), component(1,1), component(1,2));
            if component(j,3) == 2
                mi_selectsegment(midpoint([component(j,1) component(j,2) component(1,1) component(1,2)]));
                mi_setsegmentprop('<None>', 0.5, 0, 0, component(j,3));
            end
            mi_selectsegment(midpoint([component(j,1) component(j,2) component(1,1) component(1,2)]));
            mi_setsegmentprop('<None>', 0, 1, 0, component(j,3));
            mi_clearselected
        end
    end
end

function mid = midpoint(coords)
    mid = [(coords(1) + coords(3))/2 (coords(2) + coords(4))/2];
end