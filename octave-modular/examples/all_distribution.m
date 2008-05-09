init_shogun

num=12;
leng=50;
rep=5;
weight=0.3;

% Explicit examples on how to use distributions

% generate some random DNA =;-]
acgt='ACGT';
trainlab_dna=[ones(1,num/2) -ones(1,num/2)];
traindata_dna=acgt(ceil(4*rand(leng,num)));
testdata_dna=acgt(ceil(4*rand(leng,num)));

% generate a sequence with characters 1-6 drawn from 3 loaded cubes
for i = 1:3,
    a{i}= [ ones(1,ceil(leng*rand)) 2*ones(1,ceil(leng*rand)) 3*ones(1,ceil(leng*rand)) 4*ones(1,ceil(leng*rand)) 5*ones(1,ceil(leng*rand)) 6*ones(1,ceil(leng*rand)) ];
    a{i}= a{i}(randperm(length(a{i})));
end

s=[];
for i = 1:size(a,2),
    s= [ s i*ones(1,ceil(rep*rand)) ];
end
s=s(randperm(length(s)));
cubesequence={''};
for i = 1:length(s),
    f(i)=ceil(((1-weight)*rand+weight)*length(a{s(i)}));
    t=randperm(length(a{s(i)}));
    r=a{s(i)}(t(1:f(i)));
    cubesequence{1}=[cubesequence{1} char(r+'0')];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% distributions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Histogram
disp('Histogram')

order=3;
gap=0;
reverse=false;

charfeat=StringCharFeatures(DNA);
charfeat.set_string_features(traindata_dna);
feats=StringWordFeatures(charfeat.get_alphabet());
feats.obtain_from_char(charfeat, order-1, order, gap, reverse);
preproc=SortWordString();
preproc.init(feats);
feats.add_preproc(preproc);
feats.apply_preproc();

histo=Histogram(feats);
histo.train();

histo.get_histogram();

num_examples=feats.get_num_vectors();
num_param=histo.get_num_model_parameters();
for i=0:(num_examples-1),
	for j=0:(num_param-1),
		histo.get_log_derivative(j, i);
	end
end

histo.get_log_likelihood();
histo.get_log_likelihood_sample();

% Linear HMM
disp('LinearHMM')

order=3;
gap=0;
reverse=false;

charfeat=StringCharFeatures(DNA);
charfeat.set_string_features(traindata_dna);
feats=StringWordFeatures(charfeat.get_alphabet());
feats.obtain_from_char(charfeat, order-1, order, gap, reverse);
preproc=SortWordString();
preproc.init(feats);
feats.add_preproc(preproc);
feats.apply_preproc();

hmm=LinearHMM(feats);
hmm.train();

hmm.get_transition_probs();

num_examples=feats.get_num_vectors();
num_param=hmm.get_num_model_parameters();
for i=0:(num_examples-1),
	for j=0:(num_param-1),
		hmm.get_log_derivative(j, i);
	end
end

hmm.get_log_likelihood();
hmm.get_log_likelihood_sample();

% HMM
disp('HMM')

N=3;
M=6;
pseudo=1e-1;
order=1;
gap=0;
reverse=false;
num_examples=2;
charfeat=StringCharFeatures(CUBE);
charfeat.set_string_features(cubesequence);
feats=StringWordFeatures(charfeat.get_alphabet());
feats.obtain_from_char(charfeat, order-1, order, gap, reverse);
preproc=SortWordString();
preproc.init(feats);
feats.add_preproc(preproc);
feats.apply_preproc();

hmm=HMM(feats, N, M, pseudo);
hmm.train();
hmm.baum_welch_viterbi_train(BW_NORMAL);

num_examples=feats.get_num_vectors();
num_param=hmm.get_num_model_parameters();
for i=0:(num_examples-1),
	for j=0:(num_param-1),
		hmm.get_log_derivative(j, i);
	end
end

best_path=0;
best_path_state=0;
for i=0:(num_examples-1),
	best_path = best_path + hmm.best_path(i);
	for j=0:(N-1),
		best_path_state = best_path_state + hmm.get_best_path_state(i, j);
	end
end

hmm.get_log_likelihood();
hmm.get_log_likelihood_sample();
