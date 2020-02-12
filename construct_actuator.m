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
    %mi_setblockprop('copper', 1, 0, 'winding_2', '0', 1, 0);
    mi_clearselected
end


mi_makeABC();
mi_createmesh();
mi_analyse();
mi_loadsolution();
mi_saveas('actuator.fem');

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
            mi_selectsegment(midpoint([component(j,1) component(j,2) component(j+1,1) component(j+1,2)]));
            mi_setsegmentprop('<None>', 0, 1, 0, component(j,3));
            mi_clearselected
        else
            mi_addsegment(component(j,1), component(j,2), component(1,1), component(1,2));
            mi_selectsegment(midpoint([component(j,1) component(j,2) component(1,1) component(1,2)]));
            mi_setsegmentprop('<None>', 0, 1, 0, component(j,3));
            mi_clearselected
        end
    end
end

function mid = midpoint(coords)
    mid = [(coords(1) + coords(3))/2 (coords(2) + coords(4))/2];
end