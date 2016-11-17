
rng(0,'twister'); 
D = simulateData(200, 2, 3);
X = D.X; Xd = D.Xd; A = D.A; B = D.B; lambda = 1;
A0 = A + 0.1*(rand(size(A))-0.5);
objFcn = @(A) objFull(X, Xd, A, B, A0, lambda);
opts = optimoptions(@fminunc, 'Algorithm', 'quasi-newton', ...
    'GradObj', 'on', 'FunValCheck', 'on', ...
    'DerivativeCheck', 'on', 'Diagnostics', 'on');
[Ah fval exitflag output] = fminunc(objFcn, A0, opts);
