function [L,R]=makeIndices(n,p,T)

% A function that sets the offdiagonals of a block matrix
% https://www.mathworks.com/matlabcentral/answers/1932505-populating-off-diagonal-blocks-of-diagonal-matrix-and-making-it-sparse

% n = size of small, sub-matrix
% T = number of sub matrices
% p = degree of off diagonals used

  
Icell=mat2cell(reshape(1:n^2*p,n,[]), n,n*ones(1,p) );
Icell=[zeros(n), Icell, zeros(n)];
idx=toeplitz(min(p+2,1:T), [1,repelem(p+2,T-1)]  );
 Q = cell2mat(Icell(idx));
 L=logical(Q);
 R=nonzeros(Q);
end