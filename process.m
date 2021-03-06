load('L.mat');
load('CoEnergyFEMM.mat');
linetypes = [":", "--", "-", "-."]; 

figure('Name', 'Inductance-Displacement')
hold on
%plot inductance characteristic for the four cases
for i = 1:1:4
    x = L(1:49,1,11);
    y = L(1:49,i+1,11);
    plot(x, y, linetypes(i));
end
xlabel('Armature displacement [mm]');
ylabel('Magnetic circuit inductance, L [H]');
legend('Analytical (no fringing)', 'Analytical (fringing)', ...
       'Numerical (linear)', 'Numerical (non-linear)') 
hold off
movegui([2,-2])

figure('Name', 'Psi-I')
subplot(2,2,1)
hold on
%plot psi-I characteristic for the analytical case without fringing
for i = 1:6:49
    x = 0:1:10;
    y = [];
    for j = 1:1:11
        if j ~= 1
            y(j) = L(i,2,j)*(j-1);
        else
            y(j) = 0;
        end
    end
    if i == 1 || i == 49
        plot(x, y, '-');
    else
        plot(x, y, '--');
    end
end
xlabel('Current, I [A]');
ylabel('Flux linkage, \Psi [Wb turns]');
title('Analytical (no fringing)');
hold off

subplot(2,2,2)
hold on
%plot psi-I characteristic for the analytical case with fringing
for i = 1:6:49
    x = 0:1:10;
    y = [];
    for j = 1:1:11
        if j ~= 1
            y(j) = L(i,3,j)*(j-1);
        else
            y(j) = 0;
        end
    end
    if i == 1 || i == 49
        plot(x, y, '-');
    else
        plot(x, y, '--');
    end
end
xlabel('Current, I [A]');
ylabel('Flux linkage, \Psi [Wb turns]');
title('Analytical (fringing)');
hold off

subplot(2,2,3)
hold on
%plot psi-I characteristic for the numerical linear case
for i = 1:6:49
    x = 0:1:10;
    y = [];
    for j = 1:1:11
        if j ~= 1
            y(j) = L(i,4,j)*(j-1);
        else
            y(j) = 0;
        end
    end
    if i == 1 || i == 49
        plot(x, y, '-');
    else
        plot(x, y, '--');
    end
end
xlabel('Current, I [A]');
ylabel('Flux linkage, \Psi [Wb turns]');
title('Numerical (linear)');
hold off

subplot(2,2,4)
hold on
%plot psi-I characteristic for the numerical non-linear case
for i = 1:6:49
    x = 0:1:10;
    y = [];
    for j = 1:1:11
        if j ~= 1
            y(j) = L(i,5,j)*(j-1);
        else
            y(j) = 0;
        end
    end
    if i == 1 || i == 49
        plot(x, y, '-');
    else
        plot(x, y, '--');
    end
end
xlabel('Current, I [A]');
ylabel('Flux linkage, \Psi [Wb turns]');
title('Numerical (non-linear)');
hold off
movegui([2, -510])

figure('Name', 'Force-Displacement')
hold on
%calculate coenergy for each armature position
linetypes = [":", "--", "-", "-."]; 
for count = 1:1:4
    for i = 1:1:50
        x = 0:1:10;
        y = [];
        for j = 1:1:11
            if j ~= 1
                y(j) = L(i,count+1,j)*(j-1);
            else
                y(j) = 0;
            end
        end
       
        CoEnergy(count,i) = trapz(x, y);
    end
end
%calculate and plot force-displacement characteristic for the four cases
for n = 1:1:4
   for i = 1:1:49
      F(i,n) = (CoEnergy(n,i+1) - CoEnergy(n,i))/((4.9e-3)/49); 
   end
   plot(linspace(-4.9,0,49),flip(F(:,n)),linetypes(n));
end
%calculate force from the co-energy extracted directly from FEMM
for i = 1:1:49
    Ff(i) = (Ec(i+1) - Ec(i))/((4.9e-3)/49); 
end

xlabel('Armature displacement [mm]');
ylabel('Force [N]');
legend('Analytical (no fringing)', 'Analytical (fringing)', ...
       'Numerical (linear)', 'Numerical (non-linear)') 
hold off
movegui([590 -2])

figure('Name', '\Psi - I Co-energy vs FEMM Co-energy')
hold on
plot(linspace(-4.9,0,49), flip(Ff(:)), '--')
plot(linspace(-4.9,0,49), flip(F(:,4)), 'x')
xlabel('Armature displacement [mm]');
ylabel('Force [N]');
legend('Numerical (non-linear)', 'Extracted from FEMM')
hold off
movegui([590 -510])
%generate values for table comparing co-energy between trapz() and
%blockintegral
Cotable = zeros(2,50);
Cotable(1,:) = round(CoEnergy(4,:), 6, 'significant');
Cotable(2,:) = round(Ec, 6, 'significant');