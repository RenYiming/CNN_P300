%% CNNѵ������
% ���룺
%   X 100*12*560
%   Y 2*560
%   opt numIteration lambda alpha
function net = CNNTrain(net, X, Y, opt)
%% ����ѵ��
disp('Training network...');
sample = 1;
net.RMSe = 0;
figure; hold on;
for iter = 1:opt.numIteration
    tic;
    disp(['Iteration ' num2str(iter) '/' num2str(opt.numIteration)]);
    
    % ��ʼ����ѵ��
    randIndex = randperm(size(Y,2)); % ����ѵ������������˳��
    numCorrect = 0;
    for sample_Iter = 1:size(X,3) % ÿ��ѵ������
        batchX = X(:, :, randIndex(sample_Iter) );
        batchY = Y(:, randIndex(sample_Iter) );
        state = Y(1, sample_Iter); % 1����P300��0�����P300
        
        net = CNNFeedforward(net, batchX, batchY); % ǰ��
        net = CNNBackPropagation(net, batchX, batchY, opt); % BP����Ȩֵ
        
        % ��BP���������ǰ����������Ƿ���ϱ�ǩֵ
        netCheck = CNNFeedforward(net, batchX, batchY);
        
        % ��¼�������ֵ��ѵ����ǩ
        net.trainOutput(:, sample_Iter) = netCheck.layers{5}.a;
        net.trainY(:, sample_Iter) = batchY;
        
        % ȷ������Ƿ�P300
        if net.trainOutput(1, sample_Iter) > net.trainOutput(2, sample_Iter)
            output = 1;
        else
            output = 0;
        end
        
        % ������ѵ�����ϵ�׼ȷ��
        if state == output
            numCorrect = numCorrect + 1;
        end
        
        net.Loss(:, sample) = netCheck.loss;
        sample = sample + 1;
    end
    net.accuracyPerTrain(iter) = numCorrect/size(X, 3); % ��¼�˴ε�������������ѵ�����ϵ�׼ȷ��
    fprintf('Accuracy on training set: %d%% \n', net.accuracyPerTrain(iter)*100 );
    toc;
end

end