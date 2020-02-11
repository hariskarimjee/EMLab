addpath(genpath('C:\femm42'));
opendocument('femm_template.fem');
mi_saveas('acutator.fem');

load('coil1p.mat');
load('coil2p.mat');
load('coil3p.mat');
load('coil4p.mat');
load('corep.mat');
load('moverp.mat');


mi_addnode(corep(:,1), corep(:,2))
mi_addnode(coil1p(:,1),coil1p(:,2))
mi_addnode(coil2p(:,1), coil2p(:,2))
mi_addnode(coil3p(:,1), coil3p(:,2))
mi_addnode(coil4p(:,1), coil4p(:,2))
mi_addnode(moverp(:,1), moverp(:,2))

components := [coil1p coil2p coil3p coil4p corep moverp];

for i = 1:length(components)
    for j = length(components(i))
        mi_selectnode(components(i,j,1), components(i,j,2));
        mi_setnodeprop('<None>', components(i,j,3));
        mi_clearselected
    end
end
   
            
    