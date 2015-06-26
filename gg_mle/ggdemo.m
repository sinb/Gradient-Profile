% GGDEMO
% Demonstrations of the main functions in the generalized Gaussian density package
%


disp('Model parameter:')
mu = 10       % mean
alpha = 2     % scale
beta = 0.7    % shape

% Generate 10^4 random samples from the generalize Gaussian density
r = ggrnd(mu, alpha, beta, 1, 10^3);

disp('Moment matching estimate:');
[mu1, alpha1, beta1] = ggmme(r)

disp('Maximum likelihood estimate:');
[mu2, alpha2, beta2] = ggmle(r)


% Compare the estimated PDF's with the histogram
[N, X] = hist(r, 31);

clf;
bar(X, N ./ (X(2) - X(1)) / sum(N));
hold;

plot(X, ggpdf(X, mu1, alpha1, beta1), 'b');
plot(X, ggpdf(X, mu2, alpha2, beta2), 'r');
