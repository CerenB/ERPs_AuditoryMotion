function table_header = blip(a, b, varargin)

table_header = {};

  for K = 1 : nargin
      
    fprintf('input #%d came from variable "%s"\n', K, inputname(K) );
    table_header{end+1} = inputname(K);

  end