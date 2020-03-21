load('psi.mat');

psitemp = zeros(1,11);

figure('Name', 'Psi-I Curves')

for n = 1:4
    hold on
    subplot(2,2,n)
    for i = 1:1:10
        for j = 1:11
          psitemp(j) = psi(i,n,j);

        end
        plot(0:10, psitemp)

        Coenergy(n,i) = trapz(0:10, psitemp);

    end
    hold off
end

figure('Name', 'Force-Displacement Characteristic')
hold on
for n = 1:4
    
    for i = 1:9
        F(i) = (Coenergy(n,i+1) - Coenergy(n,i))/((4.9e-3)/9);
    end
    plot(linspace(-4.9, 0, 9), flip(F))
    
   
end
xlabel('Armature displacement [mm]')
ylabel('Force [N]')
legend('Analytical (no fringing)', 'Analytical (fringing)', 'Numerical (linear)', 'Numerical (non-linear)') 

hold off

