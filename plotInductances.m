%load('psi.mat');

psitemp = zeros(1,10);
hold on
for i = 1:4
    for j = 10:1:30
      psitemp(j) = psi(i,2,j);
    end
    plot(1:30, psitemp)
    
end
hold off
