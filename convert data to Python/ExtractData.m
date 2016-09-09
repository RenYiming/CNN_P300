function [trainSamples,trainLabels]=ExtractData(rawSignal,event)
%% ������ȡ�����趨
trialStartPoints = find(event.type>=41 & event.type<=80); % 30*1 30��trial��ʼ��ʱ��㣨λ��ֵ����401*n+1~11630
numTrials = length(trialStartPoints)-1; % ���һ���ַ���Ϊ����������������ֻ��29��
numEpochs = 40; % ��Ļ���ܹ�40���ַ�
numRounds = round( (trialStartPoints(2)-trialStartPoints(1))/numEpochs ); % ÿ���ַ��ظ�10��
epochLength = 150; % ʱ�䴰Ϊ150��������

filterCoefB = [0.0083   -0.0260    0.0464   -0.0551    0.0580   -0.0551    0.0464   -0.0260    0.0083];
filterCoefA = [1.0000   -5.0983   11.7635  -15.9105   13.7377   -7.7295    2.7616   -0.5718    0.0525];

channelSelected = [9 14 19 24 28:32 34:36]; % NuAmps��ͨ��ѡ��
numChannels = length(channelSelected); % ��12��ͨ��

timeWindowLeft = 25;
timeWindowRight = 125;
timeWindow = timeWindowRight - timeWindowLeft;

%% ��ȡ���ݲ��˲�
% trainFeatureMaps,trainLabelsΪ��ȡ����ѵ����������ǩֵ
trainSamples = zeros(numTrials*numRounds*numEpochs, timeWindow, numChannels); % (29*10*40)*20*12=11600*100*12 11600�����ѵ������
trainLabels = zeros(numTrials*numRounds*numEpochs, 1); % (29*10*40)*1=11600*1

targetChars = zeros(numTrials, 1);

disp('Extracting features...');
% ����forѭ���ֱ�Ϊ 1-29 trials * 1-10 rounds * 1-40 epochs
for trial_Iter = 1:numTrials
    targetChars(trial_Iter) = event.type( trialStartPoints(trial_Iter) )-40;
    for round_Iter = 1:numRounds
        for epoch_Iter = trialStartPoints(trial_Iter) + (round_Iter - 1)*numEpochs + 1 : trialStartPoints(trial_Iter) + round_Iter*numEpochs
            % ����һʱ����Ļ�����ַ���36��Ƶ�����ź�ֵ��ȡ
            flashingCode = event.type(epoch_Iter);
            signalEpoch = rawSignal(event.pos(epoch_Iter):event.pos(epoch_Iter)+epochLength-1, :)';%36*150
            
            if (flashingCode > 0 && flashingCode <= numEpochs)
                signalEpoch = signalEpoch(:,timeWindowLeft+1:timeWindowRight);%36*100 ȡ�м�ʱ�䴰
                %signalDebased = signalEpoch - kron(mean(signalEpoch(:,2:24),2), ones(1, size(signalEpoch,2)) );
                signalFiltered = filter( filterCoefB, filterCoefA, signalEpoch(channelSelected, :)',[],1);%100*12
                trainSamples( (trial_Iter-1)*numRounds*numEpochs + (round_Iter-1)*numEpochs + flashingCode, :, :) = signalFiltered; %11600*100*12
            end
                
        end
        trainLabels( (trial_Iter-1)*numRounds*numEpochs + (round_Iter-1)*numEpochs + targetChars(trial_Iter) ) = 1;%11600*1
    end
end

%% ȥ��©���������׼����ȡ��������
featureDim1 = size(trainSamples, 2);
featureDim2 = size(trainSamples, 3);
trainSamples = reshape(trainSamples, size(trainSamples,1), []); % 11600*1200

trainLabels( all(trainSamples==0, 2) ) = []; % �����ĳһ����ȫΪ0����ȥ��
trainSamples( all(trainSamples==0, 2), :) = []; % 11600*1200

% ��һ��
trainSamples = zscore(trainSamples')';

% �ָ�ԭ�ṹ
trainSamples = reshape(trainSamples, size(trainSamples, 1), featureDim1, featureDim2); % 11600*100*12

% �������ݽṹ������CNN
trainSamples = permute(trainSamples, [2 3 1]); % 100*12*11600
trainLabels = [trainLabels'; ~trainLabels']; % 2*11600
end