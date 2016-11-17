homedir = pwd;
MANOPT_PATH = fullfile(homedir, '..', 'manopt'); % change if yours is different

addpath(genpath(fullfile(homedir, 'bin'))); % add paths used by jPCA
cd(MANOPT_PATH); importmanopt; cd(homedir); % add paths for manopt
