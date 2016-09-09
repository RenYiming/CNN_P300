%% CNN��������
% BPԭ��μ�UFLDL���򴫵��㷨
%
% ���㼤��ֵ
%    L1 net.layers{2}.a 10*100
%    L2 net.layers{3}.a {50} 1*5
%    L3 net.layers{4}.a 100*1
%    L4 net.layers{5}.a 2*1

% ����Ȩ��
%    L1 net.layers{2}.k {10} 1*12
%    L2 net.layers{3}.k {10}{5} 1*20
%    L3 net.layers{4}.k {100} 1*250
%    L4 net.layers{5}.k {2} 1*100

function net = CNNBackPropagation(net, batchX, batchY, opt)
%% �������в�
% L4    net.layers{5}.delta 2*1
net.layers{5}.delta = - (batchY - net.layers{5}.a) .* sigmoidGradient(net.layers{5}.a);
% L3    net.layers{4}.delta 100*1
net.layers{4}.delta = reshape(cell2mat(net.layers{5}.k), net.layers{4}.hiddenSize, net.layers{5}.dimension)... 100*2
                        * net.layers{5}.delta .* sigmoidGradient(net.layers{4}.a);
% L2    net.layers{3}.delta 250*1
net.layers{3}.delta = reshape( cell2mat(net.layers{4}.k)', size( cell2mat(net.layers{3}.a), 2), net.layers{4}.hiddenSize ) * ... 250*100
                     net.layers{4}.delta .* tanhGradient( cell2mat(net.layers{3}.a)' );
% L1    net.layers{2}.delta 1*1000
wL = cell(net.layers{3}.mapSize); % 5*5 cell
wLs = cell(net.layers{3}.numMaps, 1); % 5*1 cell
wXd = zeros(1, net.layers{2}.numMaps * net.layers{2}.mapSize);
for mapL1_Iter = 1:net.layers{2}.numMaps % 10������
    for mapL2_Iter = 1:net.layers{3}.numMaps % 5������
        for i=1:net.layers{3}.mapSize % ����˴�СΪ5
        for j=1:net.layers{3}.mapSize
            if i == j
                wL{i,j} = net.layers{3}.k{mapL1_Iter}{mapL2_Iter};
            else
                wL{i,j} = zeros(1,net.layers{3}.kernelSize); % 1*20
            end
        end
        end
        wLs{mapL2_Iter,1} = cell2mat(wL); % {5} 5*100 diag
    end
    wXd( (1:net.layers{2}.mapSize) + (mapL1_Iter-1) * net.layers{2}.mapSize) = ...
        net.layers{3}.delta( (1:25) + (mapL1_Iter-1)*25 )'* cell2mat(wLs);
end
net.layers{2}.delta = wXd .* tanhGradient( reshape(net.layers{2}.a', 1, net.layers{2}.numMaps * net.layers{2}.mapSize) );
%% ��������ݶȲ�����Ȩ��
alpha = opt.alpha;
lambda = opt.lambda;

% =================================L4======================================
% �ݶ�
kGradL4 = net.layers{5}.delta * net.layers{4}.a'; % 2*100
bGradL4 = net.layers{5}.delta; % 2*1

kL4 = reshape( cell2mat(net.layers{5}.k), net.layers{4}.hiddenSize, net.layers{5}.dimension )'; % 2*100
kL4 = kL4 - alpha .* ( kGradL4 + lambda .* kL4 );
net.layers{5}.k{1} = kL4(1,:);
net.layers{5}.k{2} = kL4(2,:);
net.layers{5}.b = net.layers{5}.b - alpha .* bGradL4';

% =================================L3======================================
% �ݶ�
kGradL3 = net.layers{4}.delta * cell2mat(net.layers{3}.a); % 100*250
bGradL3 = net.layers{4}.delta; % 100*1

for k_Iter = 1:net.layers{4}.hiddenSize % 100�����ز���Ԫ��ÿ����ԪkΪ1*250
    net.layers{4}.k{k_Iter} = net.layers{4}.k{k_Iter} - alpha .* ( kGradL3(k_Iter, :) + lambda .* net.layers{4}.k{k_Iter} );
end
net.layers{4}.b = net.layers{4}.b - alpha .* bGradL3'; % 1*100

% =================================L2======================================
bGradL2 = net.layers{3}.delta;

L2KernelSize = net.layers{3}.kernelSize; % 20
L2MapSize = net.layers{3}.mapSize; % 5
map_Iter = 1;
for mapL1_Iter = 1:net.layers{2}.numMaps % 10
    for mapL2_Iter = 1:net.layers{3}.numMaps % 5
         kGradL2 = reshape( net.layers{2}.a(mapL1_Iter, :), L2KernelSize, L2MapSize ) * net.layers{3}.delta( (1:L2MapSize) + (map_Iter-1) * L2MapSize ); % 20*1
         net.layers{3}.k{mapL1_Iter}{mapL2_Iter} = net.layers{3}.k{mapL1_Iter}{mapL2_Iter} - alpha .* ( kGradL2' + lambda .* net.layers{3}.k{mapL1_Iter}{mapL2_Iter} );
         net.layers{3}.b(mapL1_Iter,mapL2_Iter) = net.layers{3}.b(mapL1_Iter,mapL2_Iter) - alpha .* sum( bGradL2(1:L2MapSize)+(map_Iter - 1) * L2MapSize );
         map_Iter = map_Iter + 1;
    end
end

% =================================L1======================================
kGradL1 = reshape(net.layers{2}.delta, net.layers{2}.mapSize,  net.layers{2}.numMaps)' * batchX; % 10*12
bGradL1 = net.layers{2}.delta; % 1*1000

kL1 = reshape( cell2mat(net.layers{2}.k), net.layers{2}.kernelSize, net.layers{2}.numMaps )'; % 10*12
kL1 = kL1 - alpha .* ( kGradL1 + lambda .* kL1); % 10*12
L1mapSize = net.layers{2}.mapSize; % 100
for map_Iter = 1:net.layers{2}.numMaps % 10
    net.layers{2}.k{map_Iter} = kL1(map_Iter,:);
    net.layers{2}.b(map_Iter) = net.layers{2}.b(map_Iter) - alpha.* sum( bGradL1( (1:L1mapSize) + L1mapSize * (map_Iter - 1) ) );
end

end

%% sigmoid����
function sigGrad = sigmoidGradient(x)
    sigGrad = x .* ( 1 - x );
end
%% tanh����
function tanhGrad = tanhGradient(x)
    tanhGrad = 1 - x .* x;
end