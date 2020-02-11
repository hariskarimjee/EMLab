addpath(genpath('C:\femm42'));
openfemm()
opendocument('femm_template.fem');
mi_saveas('actuator.fem');


components = {coil1p coil2p coil3p coil4p corep moverp};

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



for i = 1:length(components)
    modifyNodes(components{i});
end

mi_saveas('actuator.fem');

function modifyNodes(component)
    for j = 1:size(component,1)
        mi_selectnode(component(j,1), component(j,2));
        mi_setnodeprop(component(j,3), component(j,3));
    end
end

