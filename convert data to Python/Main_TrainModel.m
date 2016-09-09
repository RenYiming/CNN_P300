%% =======================ѵ��ģ��������==============================
% ���������̣�
% 1����ȡԭʼEEG�źţ�Ԥ�����100��ʱ��*12��Ƶ����������Ƭ�Σ�ReadData�ļ��У�
% (�ѷ���)��ϡ���Ա�����ѧϰ�õ������W 100*240��AutoEncoder�ļ��У�
% 2����ÿһ������Ƭ������CNN��ѵ��
% 3��ѵ����ɣ�����ѵ�������ԣ����ò��Լ�����
%
% ע��1��Ԥ������ȥ�������ڿ˻�����
%     2��������������
%
%
%
% =========================================================================
%% ����·����Ҫѵ���������ļ����ɵ���
clear;clc;
addpath data/
% cntTrainFileName = 'kangyarui_20150709_train_1.cnt';
% cntTestFileName = 'kangyarui_20150709_test_1.cnt';

cntTrainFileName = 'chenzhubing_20150627_train_1.cnt';
cntTestFileName = 'chenzhubing_20150627_test_1.cnt';

%% ��ȡ����
addpath ReadData/

% ��ȡѵ������
disp('Reading train data...');
[rawSignalTrain, eventTrain] = readcnt(cntTrainFileName); % rawSignal 136410*36 36��Ƶ���Ĳ���ֵ
[trainData, trainLabel] = ExtractData(rawSignalTrain, eventTrain);
% ��ȡ��������
disp('Reading test data...');
[rawSignalTest, eventTest] = readcnt(cntTestFileName);
[testData, testLabel] = ExtractData(rawSignalTest, eventTest);

%% ϡ���Ա�������ȡ��������CNN�����
% addpath AutoEncoder/
% 
% % �ɵ�������ϡ���Ա�����ѵ���������
% visibleSize=1*12; % �������ֻ��ʱ������У��ʾ���˸���ȫ��Ƶ��
% hiddenSize = 6; % �Ա��������ز���Ԫ������Ϊfeature map��
% opt.numPatches=100000; % �ɵ�������ѡȡ��ѧϰ������,��С��11600*20
% opt.sparsityParam = 0.01; % ϡ���Բ���
% opt.lambda = 0.01; % regularization
% opt.beta = 1; % ϡ���Գͷ�����
% opt.maxIteration = 1000; % ����������
% 
% % ϡ���Ա�����ѧѧϰ�õ������
% W = SparseEncoderLearn(trainFeatures, visibleSize, hiddenSize, opt);
% W = reshape(W,size(W,1),1,visibleSize);%hiddenSize*1*12
% clearvars -except W trainFeatures trainLabels 
% % ���ˣ���ѵ���õ�hiddenSize��1*visibleSize�ľ���ˣ�����CNN�������

%% ȡ��������
% ��������Ԥ����õ� trainData 100*20*numData �� trainLabel 2*numData
% ����ֱ���ȡ��������������������CNNѵ����
posIndex = find(trainLabel(1,:)); % 1*290
negIndex = find(trainLabel(2,:)); % 1*11600
numPos = size(posIndex,2); % 290��������
numNeg = size(negIndex,2); % 11310��������
randNegIndex = randperm(numNeg, numPos); % �Ӹ������������ȡ��������������ѵ��

% preallocate for speed
inputX = zeros( size(trainData,1), size(trainData,2), 2*numPos); % 100*12*580
inputY = zeros( size(trainLabel,1), 2*numPos); % 2*580
for pos_Iter = 1:numPos % 290��������
    inputX(:, :, pos_Iter) =  trainData(:, :, posIndex(pos_Iter) );
    inputY(:, pos_Iter) = trainLabel(:, posIndex(pos_Iter) );
end
for neg_Iter = 1:numPos % 290��������
    inputX(:, :, neg_Iter + numPos) = trainData(:, :, randNegIndex(neg_Iter) );
    inputY(:, neg_Iter + numPos) = trainLabel(:, randNegIndex(neg_Iter) );
end

inputX = permute(inputX,[3,1,2]);
inputY = inputY';
clearvars -except inputX inputY trainData trainLabel testData testLabel cntTrainFileName cntTestFileName

% %% CNNѵ��
% % ����ṹ��CNNInitParam.m�ļ�
% 
% addpath CNN/
% % �趨ѵ������opt���ɵ���
% CNNOpt.numIteration = 3000;
% CNNOpt.lambda = 0;
% CNNOpt.alpha = 5e-4; % ѧϰ����
% % ��ʼ���������
% CNN.layers = {
%     struct('type','L0', 'dimension','100x12')
%     struct('type','L1', 'numMaps',10, 'mapSize',100, 'kernelSize',12)
%     struct('type','L2', 'numMaps',5, 'mapSize',5, 'kernelSize',20)
%     struct('type','L3', 'hiddenSize',100)
%     struct('type','L4', 'dimension',2)
% };
% %rng(0);
% % ��ʼ���������
% CNN = CNNInitParam(CNN);
% % ѵ������
% CNN = CNNTrain(CNN, inputX, inputY, CNNOpt);
% 
% %% ��������
% fprintf('Train completed.\nTesting training set...\n');
% 
% testTrainingSet = CNNTest(CNN, trainData, trainLabel); % ����ѵ����
% testTestSet = CNNTest(CNN, testData, testLabel); % ���Բ��Լ�
% 
% % ÿ�ε�����������ѵ�����ϵ�׼ȷ��g
% figure; plot(testTrainingSet.accuracyPerTrain);
% xlabel('Iteration'); ylabel('Output accuracy on training set');
% 
% % ÿ��batch�����ʧ����Loss
% figure; plot(testTrainingSet.Loss);
% xlabel('batch'); ylabel('Loss');
% 
% % ��¼ʵ�����
% NOTE = {'normalization', true;...
%         'kronecker', false;...
%         'lambda', CNNOpt.lambda;...
%         'alpha', CNNOpt.alpha;...
%         'iter',CNNOpt.numIteration;...
%         'trainFile',cntTrainFileName;...
%         'testFile', cntTestFileName};
