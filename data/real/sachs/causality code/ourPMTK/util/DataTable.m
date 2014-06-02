classdef DataTable
  
  properties
    X;
    Y;
    Xnames;
    Ynames;
  end
  
  methods
    function obj = DataTable(X, Y, Xnames, Ynames)
      if nargin ==0; return;end
      if nargin < 1
        X = [];
      end
      if nargin < 2
        Y = [];
      end
      if nargin < 3
        [n d] = size(X);
        for j=1:d
          Xnames{j} = sprintf('X%d', j);
        end
      end
      if(nargin < 4)
        [n  T] = size(Y);
        for j=1:T
          Ynames{j} = sprintf('Y%d',j);
        end
      end
      obj.X = X;
      obj.Y = Y;
      obj.Xnames = Xnames;
      obj.Ynames = Ynames;
    end
    
    function n = ndimensions(D)
      n = size(D.X,2);
    end
    
    function n = noutputs(D)
      n = size(D.Y,2);
    end
    
    function n = ncases(D)
      n = size(D.X,1);
    end
    
    function C = horzcat(A,B)
      C = [A;B];
    end
    
    function C = vertcat(A,B)
      C = data([A.X;B.X],[A.Y;B.Y],A.Xnames,A.Ynames);
    end
    
    function obj = subsasgn(obj, S, value)
      if(numel(S) > 1)   % We have d(1:3,2).X = rand(3,1)  or d.X(1:3,2) = rand(3,1)
        colNDX = ':';
        if(strcmp(S(1).type,'.') && strcmp(S(2).type,'()')) %d.X(1:3,2) = rand(3,1)
          property = S(1).subs;
          rowNDX = S(2).subs{1};
          if(numel(S(2).subs) == 2)
            colNDX = S(2).subs{2};
          end
        elseif(strcmp(S(1).type,'()')&& strcmp(S(2).type,'.'))  %d(1:3,2).X = rand(3,1)
          property = S(2).subs;
          rowNDX = S(1).subs{1};
          if(numel(S(1).subs) == 2)
            colNDX = S(1).subs{2};
          end
        end
        switch property
          case 'X'
            obj.X(rowNDX,colNDX) = value;
          case 'Y'
            obj.Y(rowNDX,colNDX) = value;
          otherwise
            error([property, ' is not a property of this class']);
        end
      else
        switch S.type
          case {'()','{}'} %Parellel assignment to both X and y (value must be a cell array)
            obj.X(S.subs{:}) = value{1};
            obj.Y(S.subs{1},:) = value{2};
          case '.' %Still support full overwrite as in d.X = rand(10,10);
            obj = builtin('subsasgn', obj, S, value);
        end
      end
    end
    
    function B = subsref(A, S)
      if(numel(S) > 1)  % We have d(1:3,:).X for example or d.X(1:3,:)
        colNDX = ':';
        if(strcmp(S(1).type,'.') && strcmp(S(2).type,'()')) %d.X(1:3,:)
          property = S(1).subs;
          rowNDX = S(2).subs{1};
          if(numel(S(2).subs) == 2)
            colNDX = S(2).subs{2};
          end
        elseif(strcmp(S(1).type,'()')&& strcmp(S(2).type,'.'))  %d(1:3,:).X
          property = S(2).subs;
          rowNDX = S(1).subs{1};
          if(numel(S(1).subs) == 2)
            colNDX = S(1).subs{2};
          end
        end
        switch property
          case 'X'
            B = A.X(rowNDX,colNDX);
          case 'Y'
            B = A.Y(rowNDX,:);
          otherwise
            error([property, ' is not a property of this class']);
        end
        return;
      end
      % numel(S)=1
      switch S.type    %d(1:3,:)   for example
        case {'()'}
          y = [];
          Xnames = {};
          Ynames = A.Ynames;
          colNDX = ':';
          if(numel(S.subs) == 2)
            colNDX = S.subs{2};
          end
          if(~isempty(A.Y))
            Y = A.Y(S.subs{1},:);
          end
          if(~isempty(A.Xnames))
            Xnames = A.Xnames(colNDX);
          end
          B = DataTable(A.X(S.subs{1},colNDX),Y,Xnames,Ynames);
        case '.' %Still provide access of the form d.X and d.y
          B = builtin('subsref', A, S);
      end
    end

  end
  
 
  
end
  
