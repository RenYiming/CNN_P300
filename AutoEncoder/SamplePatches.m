%% ��ȡ��numPatches��1*nChannel�ľ��������ϡ���Ա�����������ѧϰ
function patches=SamplePatches(inputData,numPatches)
%inputData 11600*20*12
nFeature = size(inputData,1);%11600
nTime = size(inputData,2);%20
nChannel = size(inputData,3);%12

randF=randi(nFeature,numPatches,1);%numPatches*1
randT=randi(nTime,numPatches,1);%numPatches*1

patches = zeros(numPatches,nChannel);%patchesΪnumPatches*nChannel
for patch_Iter=1:numPatches
    patches(patch_Iter,:)=inputData(randF(patch_Iter),randT(patch_Iter),:);
end

patches = bsxfun(@minus, patches, mean(patches));
end