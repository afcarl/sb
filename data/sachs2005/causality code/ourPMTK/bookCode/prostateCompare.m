load prostate;

[wMLE, mseMLE, seMLE] = prostateMLE();
[wridge, mseRidge, seRidge] = prostateRidgeBLT();
  
fprintf('%10s & %10s & %10s \\\\ \n', 'Term', 'LS', 'ridge');
fprintf('\\hline\\\\\n');
fprintf('%10s & %10.3f & %10.3f \\\\ \n', 'intercept',  wMLE(1), wridge(1));
for i=1:8
  fprintf('%10s & %10.3f & %10.3f \\\\ \n', names{i},  wMLE(i+1), wridge(i+1));
end
fprintf('\\hline\\\\\n');
fprintf('%10s & %10.3f & %10.3f\\\\ \n', 'Test MSE',  mseMLE, mseRidge);
fprintf('%10s & %10.3f & %10.3f\\\\ \n', 'SE',  seMLE, seRidge);