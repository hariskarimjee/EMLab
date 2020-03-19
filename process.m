load('L.mat');

figure()
hold on
for i = 1:1:4
    x = L(1:49,1,11);
    y = L(1:49,i+1,11);
    plot(x, y, '-');
end
xlabel('Armature displacement [m]');
ylabel('Magnetic circuit inductance, L [H]');
legend('Analytical (no fringing)', 'Analytical (fringing)', 'Numerical (linear)', 'Numerical (non-linear)') 
hold off

figure()
subplot(2,2,1)
hold on
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