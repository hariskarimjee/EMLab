

psitemp = zeros(1,10);
hold on
for i = 1:10
    for j = 1:10
      psitemp(j) = psi(i,4,j);
       
    end
    plot(1:1:10, psitemp)
    
end
hold off
