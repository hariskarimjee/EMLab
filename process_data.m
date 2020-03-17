load('psi.mat');

psitemp = zeros(1,11);

figure('Name', 'Psi-I Curves')
tiledlayout(2,2);
for n = 1:4
    nexttile
    hold on
    for i = 1:10
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
        F(i) = (Coenergy(n,i+1) - Coenergy(n,i))/(4.9e-3/9);
    end
    plot(linspace(0, 4.9, 9), F)
    
   
end
legend('Linear No Fringing', 'Linear Fringing', 'Linear Numerical', 'Non-Linear Numerical', 'location', 'northwest')

hold off

