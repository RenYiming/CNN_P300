function W = SparseEncoderLearn(trainFeatures,visibleSize,hiddenSize,opt)
fprintf('Learning features with sparse auto encoder, max iteration %d \n',opt.maxIteration);

%�����������ѡȡnumPatches��1*nChannel��patch����ϡ���Ա��������룬��ѵ���������
patches=SamplePatches(trainFeatures,opt.numPatches);%numPatches*visibleSize 10000*12

theta=SparseEncoderInitParam(visibleSize,hiddenSize);

%��ʼ����ѧϰ
addpath minFunc/;
options.Method = 'lbfgs'; 
options.maxIter = opt.maxIteration;
options.display = 'on';

[opttheta, ~] = minFunc( @(p) SparseEncoderCost(p,visibleSize, hiddenSize,...
    opt.lambda, opt.sparsityParam, opt.beta, patches'),theta,options);

W = reshape(opttheta(1:hiddenSize*visibleSize), hiddenSize, visibleSize);
end