%% ��ʼ��CNNÿ���������
% ����ṹ��
% L0����� ÿ������Ϊ100*12������ͼ 
% L1����� �����Ϊ1*12���õ�10��100*1��ʱ������
% L2����ػ��� �����Ϊ20*1����ÿ��L1������������õ�5��5*1������������50��5*1����
% ������ΪBP��������㣬��250����Ԫ
% L3ΪBP�������ز㣬��L2ȫ��ͨ
% L4����㣬������
function net = CNNInitParam(net)
%% �趨�淶������
r1 = 2 * sqrt( 6 / ( 10*100 + 12 + 1));     % L1�����
r2 = 2 * sqrt( 6 / ( 10*100 + 50*20 + 1));  % L2����ػ���
r3 = 2 * sqrt( 6 / ( 100 + 50*20 +1));      % L3ȫ��ͨBP�������ز�
r4 = 2 * sqrt( 6 / ( 100 + 2 + 1));         % L4�����
%% L1 ����� 10������map
for map_Iter = 1:net.layers{2}.numMaps % L1������
    %ÿ�������Ϊ1*12��С����Ƶ����
    net.layers{2}.k{map_Iter} = (rand(1,12)-0.5) * r1;
    net.layers{2}.b(map_Iter) = 0;
end
%% L2 ����ػ��㣬��10*5������map
for map_Iter1 = 1:net.layers{2}.numMaps
    for map_Iter2 = 1:net.layers{3}.numMaps
        %ÿ������˴�СΪ20*1����ʱ�������ػ�
        net.layers{3}.k{map_Iter1}{map_Iter2} = (rand(1,20)-0.5) * r2;
        net.layers{3}.b(map_Iter1, map_Iter2) = 0;
    end
end
%% L3 ȫ��ͨ�㣬100����Ԫ
for map_Iter = 1:net.layers{4}.hiddenSize
    net.layers{4}.k{map_Iter} = (rand(1, net.layers{2}.numMaps * net.layers{3}.numMaps * net.layers{3}.mapSize) - 0.5) * r3;
    net.layers{4}.b(map_Iter) = 0;
end
%% L4 ����� ������
net.layers{5}.k{1} = (rand(1,100)-0.5) * r4;
net.layers{5}.b(1) = 0;
net.layers{5}.k{2} = (rand(1,100)-0.5) * r4;
net.layers{5}.b(2) = 0;
end