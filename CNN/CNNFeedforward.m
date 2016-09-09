%% CNNǰ������
% ���룺
%   X 100*12
%   Y 2*1
%
% ���������
%   L0  dimension   '100x12'
%   net.layers{1}
%
%	L1  numMaps 10  mapSize 100 kernelSize  12
%   net.layers{2}    k{10} 1*12  b 1*10
%
%	L2  numMaps 5   mapSize 5   kernelSize  20
%   net.layers{3}    k{10}{5} 1*20   b 10*5
%
%	L3  dimension   100
%   net.layers{4}    k{100} 1*250    b 1*100
%
%	L4  dimension   2
%   net.layers{5}    k{2} 1*100  b 1*2
function net = CNNFeedforward(net, batchX, batchY)
%% L0��L1ǰ��
w = reshape( cell2mat(net.layers{2}.k), net.layers{2}.kernelSize, net.layers{2}.numMaps)'; % L1Ȩ�� 10 numMaps * 12 kernels
net.layers{2}.a = tanh_opt( bsxfun(@plus,w * batchX', net.layers{2}.b') ); % 10*100 L1����ֵ��10��100*1�����ʱ������
%% L1��L2ǰ��
% L2���aΪ50��5*1������ͼ
map_Iter = 1;
% L1������10��100*1����ͼ����Ҫ�������ػ�Ϊ5*1��С�������Ϊ1*20
for mapL1_Iter = 1:net.layers{2}.numMaps % 10������ͼ
    z1 = reshape( net.layers{2}.a(mapL1_Iter, :), net.layers{3}.kernelSize, net.layers{3}.numMaps); % ��1*100����Ϊ20*5
    bias = net.layers{3}.b(mapL1_Iter,:); % 1*5
    for mapL2_Iter = 1:net.layers{3}.numMaps % ÿ������ͼ�־���ػ���5������ͼ���ʹ�50��
        net.layers{3}.a{map_Iter} = tanh_opt( bsxfun(@plus, net.layers{3}.k{mapL1_Iter}{mapL2_Iter} * z1, bias(mapL2_Iter)) );
        map_Iter = map_Iter+1;
    end
end
%% L2��L3ǰ��
z2 = cell2mat( net.layers{3}.a ); % 1*250 50��1*5Ƭ��
w = reshape( cell2mat(net.layers{4}.k), size(z2,2), net.layers{4}.hiddenSize )'; % 100*250
net.layers{4}.a = sigmoid( w*z2' + net.layers{4}.b' ); % 100*1
%% L3��L4ǰ��
w = [ net.layers{5}.k{1} ; net.layers{5}.k{2} ]; % 2*100
net.layers{5}.a = sigmoid( w*net.layers{4}.a + net.layers{5}.b' ); % 2*1
%% �������
net.e = batchY - net.layers{5}.a; % 2*1
net.loss = 1/2 * (sumsqr(net.e))^2;
end

%% sigmoid����
function sig = sigmoid(x)
sig = 1 ./ ( 1 + exp(-x) );
end
%% tanh_opt����
function  f = tanh_opt(x)
    f = 1.7159 * tanh( 2/3 .*x);
end