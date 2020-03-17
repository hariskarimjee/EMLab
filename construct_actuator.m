% CI ACTUATOR FEMM ANALYSIS PROGRAM

% show matlab where femm files are and setup
addpath(genpath('C:\femm42'));
openfemm()
opendocument('femm_template.fem');
mi_saveas('actuator.fem');

% load in position and group no. for all components.
load('coil1p.mat');
load('coil2p.mat');
load('coil3p.mat');
load('coil4p.mat');
load('corep.mat');
load('moverp.mat');

% set create component array
components = {corep moverp coil1p coil2p coil3p coil4p};

mi_probdef(0, 'millimeters', 'planar', 1e-008, 20, 30, 0)

% add all nodes from data
mi_addnode(components{1}(:,1), components{1}(:,2))
mi_addnode(components{2}(:,1), components{2}(:,2))
mi_addnode(components{3}(:,1), components{3}(:,2))
mi_addnode(components{4}(:,1), components{4}(:,2))
mi_addnode(components{5}(:,1), components{5}(:,2))
mi_addnode(components{6}(:,1), components{6}(:,2))

% set node groups and draw lines for all components
for i = 1:length(components)
    modifyNodes(components{i});
    addLines(components{i});
end

% create array with coordinates of centre's of component blocks
blockCoords = [(min(components{1}(:,1)) + 3) mean(components{1}(:,2));
                mean(components{2}(:,1)) mean(components{2}(:,2));
                mean(components{3}(:,1)) mean(components{3}(:,2));
                mean(components{4}(:,1)) mean(components{4}(:,2));
                mean(components{5}(:,1)) mean(components{5}(:,2));
                mean(components{6}(:,1)) mean(components{6}(:,2));
                -25 0];

% create array of block properties 
blockProps = {'core_linear' 1 0 '<None>' 0 1 0;
              'core_linear' 1 0 '<None>' 0 2 0;
              'copper' 1 0 'winding_1' 0 3 100;
              'copper' 1 0 'winding_1' 0 4 -100;
              'copper' 1 0 'winding_2' 0 5 100;
              'copper' 1 0 'winding_2' 0 6 -100;
              'air' 1 0 '<None>' 0 7 0};
            
% for all the different blocks, add labels and set its properties              
for i = 1:max(size(blockCoords))
    mi_addblocklabel(blockCoords(i,1), blockCoords(i,2));
    mi_selectlabel(blockCoords(i,1), blockCoords(i,2));
    mi_setblockprop(blockProps{i,1}, blockProps{i,2}, ...
                    blockProps{i,3}, blockProps{i,4}, ...
                    blockProps{i,5}, blockProps{i,6}, ...
                    blockProps{i,7});
    mi_clearselected
end

% create system boundary, switch on smart-meshing & set winding currents
mi_makeABC();
smartmesh(1);
mi_setcurrent('winding_1', 0);
mi_setcurrent('winding_2', 0);

mi_saveas('actuator.fem')


% function to add nodes to groups
function modifyNodes(component)
    for j = 1:size(component,1)
        mi_selectnode(component(j,1), component(j,2));
        mi_setnodeprop(component, component(j,3));
        mi_clearselected
    end
end
% function to create lines between nodes in each group
function addLines(component)
    for j = 1:size(component,1)
        if j<size(component,1)
            mi_addsegment(component(j,1), component(j,2), ...
                          component(j+1,1), component(j+1,2));
            if j == 10 && component(j,3) == 1
                mi_selectsegment(midpoint([component(j,1) component(j,2)...
                                   component(j+1,1) component(j+1,2)]));
                mi_setsegmentprop('<None>', 0.5, 0, 0, component(j,3));
            end
            mi_selectsegment(midpoint([component(j,1) component(j,2) ...
                                      component(j+1,1) component(j+1,2)]));
            mi_setsegmentprop('<None>', 0, 1, 0, component(j,3));
            mi_clearselected
        else
            mi_addsegment(component(j,1), component(j,2), ...
                          component(1,1), component(1,2));
            if component(j,3) == 2
                mi_selectsegment(midpoint([component(j,1) component(j,2)...
                                          component(1,1) component(1,2)]));
                mi_setsegmentprop('<None>', 0.5, 0, 0, component(j,3));
            end
            mi_selectsegment(midpoint([component(j,1) component(j,2) ...
                                      component(1,1) component(1,2)]));
            mi_setsegmentprop('<None>', 0, 1, 0, component(j,3));
            mi_clearselected
        end
    end
end

function mid = midpoint(coords)
    mid = [(coords(1) + coords(3))/2 (coords(2) + coords(4))/2];
end