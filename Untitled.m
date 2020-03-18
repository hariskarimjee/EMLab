load('y1.mat');
load('y2.mat');
load('x.mat');

hold on
plot(x,y1,'mx');
plot(x,y2,'bx');
f1 = fit(transpose(x), y1, 'poly2');
f2 = fit(transpose(x), y2, 'poly2');
plot(f1,'m');
plot(f2, 'b');
xlabel('Applied Current, I [A]');
ylabel('Power Losses, P_{Loss} [W]');
legend('FEMM Predicted', 'Analytical', 'location', 'northwest');
