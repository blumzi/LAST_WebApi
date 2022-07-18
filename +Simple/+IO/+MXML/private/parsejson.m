function obj = parsejson(json)
    if any(regexp(json, '^[a-zA-Z]:\\'))
        fname = json;
        fid = fopen(fname);
        json = fread(fid, '*char')';
        fclose(fid);
    end
    element = jsondecode(json);
    obj = parsejsonElement(element);
end
function obj = parsejsonElement(element)
    if iscellstr(element)
        if size(element, 1) > 1 && size(element, 2) == 1
            obj = element';
        else
            obj = element;
        end
    elseif isstruct(element) && isfield(element, 'isList') && element.isList
        n = length(element.value);
        obj = createList(element.type, n);
        for i = 1:n
            inner = parsejsonElement(accessArray(element.value, i));
            if iscell(obj)
                obj{i} = inner;
            elseif isa(obj, 'Simple.IO.MXML.IIterable')
                obj.set(i, inner);
            else
                obj(i) = inner;
            end
        end
    elseif isstruct(element)
        copyto = struct;
        
        if isfield(element, 'type')
            copyfrom = element.value;
            type = element.type;
        else
            type = 'struct';
            copyfrom = element;
        end
        
        % Parse child fields recursively
        jsonFields = fieldnames(copyfrom);
        for fieldIdx = 1:length(jsonFields)
            copyto.(jsonFields{fieldIdx}) = parsejsonElement(copyfrom.(jsonFields{fieldIdx}));
        end
        
        % generate instance if necessary
        if strcmp(type, 'struct')
            obj = copyto;
        else
            obj = Simple.IO.MXML.Factory.instance.construct(type, copyto);
        end
    elseif isPrimitiveValueType(element)
        % primitive types
        if size(element, 1) > 1 && size(element, 2) == 1
            obj = element';
        else
            obj = element;
        end
    else
        obj = element;
    end
end
function list = createList(type, n)
    if strcmp(type, 'cell')
        list = cell(1, n);
    elseif any(strcmp(superclasses(type), 'Simple.IO.MXML.IIterable'))
        list = Simple.IO.MXML.Factory.instance.construct(type);
    else
        list = repmat(Simple.IO.MXML.Factory.instance.cunstructEmpty(type), 1, n);
    end
end
