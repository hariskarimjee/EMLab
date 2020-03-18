load('L.mat');

psi = zeros(49,5,11);
for i = 0:1:10
    psi(:,1,i+1) = L(:,1,i+1);
    psi(:,2:end,i+1) = L(:,2:end,i+1) * i;
end



figure('Name', '\Psi - I Curves');
tiledlayout(2,2);
for n = 2:5
    nexttile
    hold on
    for i = 1:11
        
        
    end
end
