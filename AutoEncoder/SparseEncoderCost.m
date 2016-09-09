function [cost, grad] = SparseEncoderCost(theta,visibleSize,hiddenSize,lambda,sparsityParam,beta,X)

W1 = reshape(theta(1:hiddenSize*visibleSize), hiddenSize, visibleSize);
W2 = reshape(theta(hiddenSize*visibleSize+1:2*hiddenSize*visibleSize), visibleSize, hiddenSize);
b1 = theta(2*hiddenSize*visibleSize+1:2*hiddenSize*visibleSize+hiddenSize);
b2 = theta(2*hiddenSize*visibleSize+hiddenSize+1:end);

numData=size(X,2);
%�������ݣ�
%W1 100*240
%W2 240*100
%b1 100*1
%b2 240*1
%X 240*11600
%sparsityParam 
%beta=3

%ǰ��
z2 = W1*X+repmat(b1,1,numData);
a2 = Sigmoid(z2);%100*11600

z3 = W2*a2+repmat(b2,1,numData);
a3 = Sigmoid(z3);%240*11600

%ϡ���Բ���
rho = mean(a2,2);%100*1

%����
delta3 = -(X-a3).*SigmoidGradient(z3);%240*11600
delta2 = (W2'*delta3 + repmat(beta*(-sparsityParam ./ rho + (1-sparsityParam) ./(1-rho)),1,numData)).*SigmoidGradient(z2);%100*11600

squareError = sum(sum((a3-X).^2))/(2*numData);
weightDecay = (lambda/2)*(sum(sum(W1.^2))+sum(sum(W2.^2)));
sparsityPenalty = beta*sum(sparsityParam*log(sparsityParam ./ rho) + (1-sparsityParam)*log((1-sparsityParam) ./(1-rho)));
cost = squareError + weightDecay + sparsityPenalty;

deltaW1 = delta2*X';
deltaW2 = delta3*a2';
deltab1 = sum(delta2,2);
deltab2 = sum(delta3,2);

W1grad = (1/numData)*deltaW1 + lambda*W1;
W2grad = (1/numData)*deltaW2 + lambda*W2;
b1grad = (1/numData)*deltab1;
b2grad = (1/numData)*deltab2;

grad = [W1grad(:) ; W2grad(:) ; b1grad(:) ; b2grad(:)];
end

%% sigmoid����
function sig=Sigmoid(x)
sig=1 ./ (1 + exp(-x));
end
%% sigmoid�����ݶ�
function sigGrad=SigmoidGradient(x)
sigGrad=Sigmoid(x).*(1-Sigmoid(x));
end