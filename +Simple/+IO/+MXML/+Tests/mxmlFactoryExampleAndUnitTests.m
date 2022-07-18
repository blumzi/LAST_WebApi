import Simple.IO.MXML;

obj1_struct = [];
obj1_struct.abc = {'abc', 'xyz', '123'};
obj1_struct.xyz = 1:10;
obj1_struct.inner = obj1_struct;
obj1_struct.mixedCell = {'kmn', 1:10, struct('a', 'a', 'b', 1:3)};

obj1_class1 = MXML.Tests.Class1('x', 1:10);
obj1_class1.list.set(1:10, 1:10);
obj1_struct_forclass = rmfield(obj1_struct, 'mixedCell');
obj1_class2 = MXML.Tests.Class2('a', 1:10, obj1_struct_forclass);
obj1_class3 = MXML.Tests.Class3();
obj1_class3.k = 1:10;
obj1_class3.l = '1:10';
obj1_class3.m.a = 1:3;
obj1_class3.m.b = '^_^';

%----------------------------------------------
% Use class name as string as class identifier
%----------------------------------------------
MXML.Factory.instance.addConstructor('MXML.Tests.Class1', @(data) MXML.Tests.Class1(data.x,data.y));

%----------------------------------------------
% Use class(instance) as class identifier
%----------------------------------------------
MXML.Factory.instance.addConstructor(class(obj1_class2), @(data) MXML.Tests.Class2(data.a,data.b,data.c));

obj2_class1 = MXML.Factory.instance.construct('MXML.Tests.Class1', struct('x', 'string', 'y', 1:10));
obj2_class2 = MXML.Factory.instance.construct('MXML.Tests.Class2', struct('a', 'string', 'b', 1:10, 'c', []));
obj2_class3 = MXML.Factory.instance.construct('MXML.Tests.Class3', struct('k', 1:10, 'l', '1:10', 'm', struct('a', 1:3, 'b', '^_^')));


test = UnitTests.UnitTesting('MXML.Factory.addConstructor');

test.checkExpectation('string', obj2_class1.x, 'MXML.Tests.Class1().x');
test.checkExpectation(1:10, obj2_class1.y, 'MXML.Tests.Class1().y');
test.checkExpectation('string', obj2_class2.a, 'MXML.Tests.Class2().a');
test.checkExpectation(1:10, obj2_class2.b, 'MXML.Tests.Class2().b');
test.checkEmptyExpectation(obj2_class2.c, 'MXML.Tests.Class2().c');
test.checkExpectation('blah blah blha', obj2_class2.d, 'MXML.Tests.Class2().d');
test.checkExpectation(1:10, obj2_class3.k, 'MXML.Tests.Class3().k');
test.checkExpectation('1:10', obj2_class3.l, 'MXML.Tests.Class3().l');
test.checkExpectation(1:3, obj2_class3.m.a, 'MXML.Tests.Class3().m.a');
test.checkExpectation('^_^', obj2_class3.m.b, 'MXML.Tests.Class3().m.b');

test.evaluateAllExpectations();

%----------------------------------------------
% Use factory builer to register all Ctors
%----------------------------------------------
MXML.Factory.init(MXML.Tests.FactoryBuilderTest());

obj3_class1 = MXML.Factory.instance.construct('MXML.Tests.Class1', struct('x', 'string', 'y', 1:10, 'list', MXML.Tests.IterableImplForTest()));
obj3_class2 = MXML.Factory.instance.construct('MXML.Tests.Class2', struct('a', 'string', 'b', 1:10, 'c', struct('a', 1:3)));

test = UnitTests.UnitTesting('MXML.Factory.init');

test.checkExpectation('string', obj3_class1.x, 'MXML.Tests.Class1().x');
test.checkExpectation(1:10, obj3_class1.y, 'MXML.Tests.Class1().y');
test.checkExpectation('MXML.Tests.IterableImplForTest', class(obj3_class1.list), 'MXML.Tests.Class1().list');
test.checkEmptyExpectation(obj3_class1.list.arr, 'MXML.Tests.Class1().list.arr');
test.checkExpectation('string', obj3_class2.a, 'MXML.Tests.Class2().a');
test.checkExpectation(1:10, obj3_class2.b, 'MXML.Tests.Class2().b');
test.checkExpectation(1:3, obj3_class2.c.a, 'MXML.Tests.Class2().c.a');
test.checkExpectation('blah blah blha', obj3_class2.d, 'MXML.Tests.Class2().d');

test.evaluateAllExpectations();

thisFolder = which('MXML.Tests.mxmlFactoryExampleAndUnitTests');
thisFolder = thisFolder(1:find(thisFolder == '\', 1, 'last'));

%----------------------------------------------
% Save to MXML file
%----------------------------------------------
tic
MXML.save([thisFolder 'string.xml'], thisFolder);
MXML.save([thisFolder 'obj1_struct.xml'], obj1_struct);
MXML.save([thisFolder 'obj1_class1.xml'], obj1_class1);
MXML.save([thisFolder 'obj1_class2.xml'], obj1_class2);
MXML.save([thisFolder 'obj2_class2.xml'], obj2_class2);
toc

%----------------------------------------------
% Load from MXML file
%----------------------------------------------
tic
str4 = MXML.load([thisFolder 'string.xml']);
obj4_struct = MXML.load([thisFolder 'obj1_struct.xml']);
obj4_class1 = MXML.load([thisFolder 'obj1_class1.xml']);
obj4_class2 = MXML.load([thisFolder 'obj1_class2.xml']);
obj5_class2 = MXML.load([thisFolder 'obj2_class2.xml']);
toc

test = UnitTests.UnitTesting('MXML.save, MXML.load');

test.checkExpectation(thisFolder, str4, 'MXML.load(string)');

test.checkExpectation({'abc', 'xyz', '123'}, obj4_struct.abc, 'MXML.load(struct).abc');
test.checkExpectation(3, length(obj4_struct.mixedCell), 'MXML.load(struct).mixedCell.length');
test.checkExpectation('kmn', obj4_struct.mixedCell{1}, 'MXML.load(struct).mixedCell{1}');
test.checkExpectation(1:10, obj4_struct.mixedCell{2}, 'MXML.load(struct).mixedCell{2}');
test.checkExpectation('a', obj4_struct.mixedCell{3}.a, 'MXML.load(struct).mixedCell{3}.a');
test.checkExpectation(1:3, obj4_struct.mixedCell{3}.b, 'MXML.load(struct).mixedCell{3}.b');
test.checkExpectation(1:10, obj4_struct.xyz, 'MXML.load(struct).xyz');
test.checkExpectation({'abc', 'xyz', '123'}, obj4_struct.inner.abc, 'MXML.load(struct).inner.abc');
test.checkExpectation(1:10, obj4_struct.inner.xyz, 'MXML.load(struct).inner.xyz');

test.checkExpectation('x', obj4_class1.x, 'MXML.load(MXML.Tests.Class1()).x');
test.checkExpectation(1:10, obj4_class1.y, 'MXML.load(MXML.Tests.Class1()).y');
test.checkExpectation('MXML.Tests.IterableImplForTest', class(obj4_class1.list), 'MXML.load(MXML.Tests.Class1()).list.type');
test.checkExpectation(1:10, obj4_class1.list.arr, 'MXML.load(MXML.Tests.Class1()).list.arr');

test.checkExpectation('a', obj4_class2.a, 'MXML.load(MXML.Tests.Class2()).a');
test.checkExpectation(1:10, obj4_class2.b, 'MXML.load(MXML.Tests.Class2()).b');
test.checkExpectation({'abc', 'xyz', '123'}, obj4_class2.c.abc, 'MXML.load(MXML.Tests.Class2()).c.abc');
test.checkExpectation(1:10, obj4_class2.c.xyz, 'MXML.load(MXML.Tests.Class2()).c.xyz');
test.checkExpectation({'abc', 'xyz', '123'}, obj4_class2.c.inner.abc, 'MXML.load(MXML.Tests.Class2()).c.inner.abc');
test.checkExpectation(1:10, obj4_class2.c.inner.xyz, 'MXML.load(MXML.Tests.Class2()).c.inner.xyz');
test.checkExpectation('blah blah blha', obj4_class2.d, 'MXML.load(MXML.Tests.Class2()).d');

test.checkExpectation('string', obj5_class2.a, 'MXML.load(MXML.Tests.Class2()_2).a');
test.checkExpectation(1:10, obj5_class2.b, 'MXML.load(MXML.Tests.Class2()_2).b');
test.checkEmptyExpectation(obj5_class2.c, 'MXML.load(MXML.Tests.Class2()_2).c');
test.checkExpectation('blah blah blha', obj5_class2.d, 'MXML.load(MXML.Tests.Class2()_2).d');

test.evaluateAllExpectations();


%% --------------------------------------------
% Load from xml string
%----------------------------------------------
filename = [thisFolder 'string.xml'];
fid = fopen(filename);
str6_content = fread(fid, '*char')';
fclose(fid);

filename = [thisFolder 'obj1_struct.xml'];
fid = fopen(filename);
obj6_struct_content = fread(fid, '*char')';
fclose(fid);

filename = [thisFolder 'obj1_class1.xml'];
fid = fopen(filename);
obj6_class1_content = fread(fid, '*char')';
fclose(fid);

filename = [thisFolder 'obj1_class2.xml'];
fid = fopen(filename);
obj6_class2_content = fread(fid, '*char')';
fclose(fid);

filename = [thisFolder 'obj2_class2.xml'];
fid = fopen(filename);
obj7_class2_content = fread(fid, '*char')';
fclose(fid);

tic
str6 = MXML.load(str6_content);
obj6_struct = MXML.load(obj6_struct_content);
obj6_class1 = MXML.load(obj6_class1_content);
obj6_class2 = MXML.load(obj6_class2_content);
obj7_class2 = MXML.load(obj7_class2_content);

toc

test = UnitTests.UnitTesting('MXML.load(xml)');

test.checkExpectation(thisFolder, str6, 'MXML.load(string)');

test.checkExpectation({'abc', 'xyz', '123'}, obj6_struct.abc, 'MXML.load(struct).abc');
test.checkExpectation(1:10, obj6_struct.xyz, 'MXML.load(struct).xyz');
test.checkExpectation({'abc', 'xyz', '123'}, obj6_struct.inner.abc, 'MXML.load(struct).inner.abc');
test.checkExpectation(1:10, obj6_struct.inner.xyz, 'MXML.load(struct).inner.xyz');
test.checkExpectation(3, length(obj6_struct.mixedCell), 'MXML.load(struct).mixedCell.length');
test.checkExpectation('kmn', obj6_struct.mixedCell{1}, 'MXML.load(struct).mixedCell{1}');
test.checkExpectation(1:10, obj6_struct.mixedCell{2}, 'MXML.load(struct).mixedCell{2}');
test.checkExpectation('a', obj6_struct.mixedCell{3}.a, 'MXML.load(struct).mixedCell{3}.a');
test.checkExpectation(1:3, obj6_struct.mixedCell{3}.b, 'MXML.load(struct).mixedCell{3}.b');

test.checkExpectation('x', obj6_class1.x, 'MXML.load(MXML.Tests.Class1()).x');
test.checkExpectation(1:10, obj6_class1.y, 'MXML.load(MXML.Tests.Class1()).y');
test.checkExpectation('MXML.Tests.IterableImplForTest', class(obj6_class1.list), 'MXML.load(MXML.Tests.Class1()).list.type');
test.checkExpectation(1:10, obj6_class1.list.arr, 'MXML.load(MXML.Tests.Class1()).list.arr');

test.checkExpectation('a', obj6_class2.a, 'MXML.load(MXML.Tests.Class2()).a');
test.checkExpectation(1:10, obj6_class2.b, 'MXML.load(MXML.Tests.Class2()).b');
test.checkExpectation({'abc', 'xyz', '123'}, obj6_class2.c.abc, 'MXML.load(MXML.Tests.Class2()).c.abc');
test.checkExpectation(1:10, obj6_class2.c.xyz, 'MXML.load(MXML.Tests.Class2()).c.xyz');
test.checkExpectation({'abc', 'xyz', '123'}, obj6_class2.c.inner.abc, 'MXML.load(MXML.Tests.Class2()).c.inner.abc');
test.checkExpectation(1:10, obj6_class2.c.inner.xyz, 'MXML.load(MXML.Tests.Class2()).c.inner.xyz');
test.checkExpectation('blah blah blha', obj6_class2.d, 'MXML.load(MXML.Tests.Class2()).d');

test.checkExpectation('string', obj7_class2.a, 'MXML.load(MXML.Tests.Class2()_2).a');
test.checkExpectation(1:10, obj7_class2.b, 'MXML.load(MXML.Tests.Class2()_2).b');
test.checkEmptyExpectation(obj7_class2.c, 'MXML.load(MXML.Tests.Class2()_2).c');
test.checkExpectation('blah blah blha', obj7_class2.d, 'MXML.load(MXML.Tests.Class2()_2).d');

test.evaluateAllExpectations();


%% --------------------------------------------
% toxml tests
%----------------------------------------------

tic
str6_content2 = MXML.toxml(str6);
obj6_struct_content2 = MXML.toxml(obj6_struct);
obj6_class1_content2 = MXML.toxml(obj6_class1);
obj6_class2_content2 = MXML.toxml(obj6_class2);
obj7_class2_content2 = MXML.toxml(obj7_class2);
toc

test = UnitTests.UnitTesting('toxml');
test.checkExpectation(char(str6_content), str6_content2, 'toxml(string)');
test.checkExpectation(char(obj6_struct_content), obj6_struct_content2, 'toxml(struct)');
test.checkExpectation(char(obj6_class1_content), obj6_class1_content2, 'toxml(class1)');
test.checkExpectation(char(obj6_class2_content), obj6_class2_content2, 'toxml(class2)');
test.checkExpectation(char(obj7_class2_content), obj7_class2_content2, 'toxml(class2 alternative)');

test.evaluateAllExpectations();


%% --------------------------------------------
% Save\Load big vector
%----------------------------------------------

test = UnitTests.UnitTesting('Big Vector');

x = 1:99999;
tic
MXML.save([thisFolder 'bigVector.xml'], x);
toc 

tic
x1 = MXML.load([thisFolder 'bigVector.xml']);
toc 

test.checkExpectation(1:99999, x1);
test.evaluateAllExpectations();

%% --------------------------------------------
% Get json from object
%---------------------------------------------- 
obj1_struct_json = MXML.tojson(obj1_struct);
obj1_class1_json = MXML.tojson(obj1_class1);
obj1_class2_json = MXML.tojson(obj1_class2);
obj1_class3_json = MXML.tojson(obj1_class3);

test = UnitTests.UnitTesting('MXML.tojson');

json1 = ['{"type":"struct","value":{"data":{"type":"struct","value":{"abc":["abc","xyz","123"],' ...
                                   '"xyz":[1,2,3,4,5,6,7,8,9,10],'...
                                   '"inner":{"type":"struct","value":{"abc":["abc","xyz","123"],'...
                                                                     '"xyz":[1,2,3,4,5,6,7,8,9,10]}},'...
                                   '"mixedCell":{"type":"cell","isList":true,'...
                                                '"value":["kmn",[1,2,3,4,5,6,7,8,9,10],{"type":"struct","value":{"a":"a","b":[1,2,3]}}]}}}}}'];
test.checkExpectation(json1, regexprep(obj1_struct_json, '\s+', ' '), 'MXML.tojson(obj1_struct)');
json2 = ['{"type":"struct","value":{"data":{"type":"MXML.Tests.Class1","value":{"x":"x","y":[1,2,3,4,5,6,7,8,9,10],"list":{"type":"MXML.Tests.IterableImplForTest","isList":true,"value":[1,2,3,4,5,6,7,8,9,10]}}}}}'];
test.checkExpectation(json2, regexprep(obj1_class1_json, '\s+', ' '), 'MXML.tojson(obj1_class1)');
json3 = ['{"type":"struct","value":{"data":{"type":"MXML.Tests.Class2",'...
    '"value":{"a":"a","b":[1,2,3,4,5,6,7,8,9,10],"c":{"type":"struct","value":{"abc":["abc","xyz","123"],' ...
                                  '"xyz":[1,2,3,4,5,6,7,8,9,10],'...
        '"inner":{"type":"struct","value":{"abc":["abc","xyz","123"],'...
                                          '"xyz":[1,2,3,4,5,6,7,8,9,10]}}}},'...
    '"d":"blah blah blha"}}}}'];
test.checkExpectation(json3, regexprep(obj1_class2_json, '\s+', ' '), 'MXML.tojson(obj1_class2)');
json4 = '{"type":"struct","value":{"data":{"type":"MXML.Tests.Class3","value":{"k":[1,2,3,4,5,6,7,8,9,10],"l":"1:10","m":{"type":"struct","value":{"a":[1,2,3],"b":"^_^"}}}}}}';
test.checkExpectation(json4, regexprep(obj1_class3_json, '\s+', ' '), 'MXML.tojson(obj1_class3)');

test.evaluateAllExpectations();

%% --------------------------------------------
% parse json
%---------------------------------------------- 
obj1_struct_fromJson = MXML.load(json1, 'json');
obj1_class1_fromJson = MXML.load(json2, 'json');
obj1_class2_fromJson = MXML.load(json3, 'json');
obj1_class3_fromJson = MXML.load(json4, 'json');

test = UnitTests.UnitTesting('MXML.load(''json'')');

test.checkExpectation({'abc', 'xyz', '123'}, obj1_struct_fromJson.abc, 'MXML.load(struct).abc');
test.checkExpectation(1:10, obj1_struct_fromJson.xyz, 'MXML.load(struct).xyz');
test.checkExpectation({'abc', 'xyz', '123'}, obj1_struct_fromJson.inner.abc, 'MXML.load(struct).inner.abc');
test.checkExpectation(1:10, obj1_struct_fromJson.inner.xyz, 'MXML.load(struct).inner.xyz');
test.checkExpectation(3, length(obj1_struct_fromJson.mixedCell), 'MXML.load(struct).mixedCell.length');
test.checkExpectation('kmn', obj1_struct_fromJson.mixedCell{1}, 'MXML.load(struct).mixedCell{1}');
test.checkExpectation(1:10, obj1_struct_fromJson.mixedCell{2}, 'MXML.load(struct).mixedCell{2}');
test.checkExpectation('a', obj1_struct_fromJson.mixedCell{3}.a, 'MXML.load(struct).mixedCell{3}.a');
test.checkExpectation(1:3, obj1_struct_fromJson.mixedCell{3}.b, 'MXML.load(struct).mixedCell{3}.b');

test.checkExpectation('x', obj1_class1_fromJson.x, 'MXML.load(MXML.Tests.Class1()).x');
test.checkExpectation(1:10, obj1_class1_fromJson.y, 'MXML.load(MXML.Tests.Class1()).y');
test.checkExpectation('MXML.Tests.IterableImplForTest', class(obj1_class1_fromJson.list), 'MXML.load(MXML.Tests.Class1()).list.type');
test.checkExpectation(1:10, obj1_class1_fromJson.list.arr, 'MXML.load(MXML.Tests.Class1()).list.arr');

test.checkExpectation('a', obj1_class2_fromJson.a, 'MXML.load(MXML.Tests.Class2()).a');
test.checkExpectation(1:10, obj1_class2_fromJson.b, 'MXML.load(MXML.Tests.Class2()).b');
test.checkExpectation({'abc', 'xyz', '123'}, obj1_class2_fromJson.c.abc, 'MXML.load(MXML.Tests.Class2()).c.abc');
test.checkExpectation(1:10, obj1_class2_fromJson.c.xyz, 'MXML.load(MXML.Tests.Class2()).c.xyz');
test.checkExpectation({'abc', 'xyz', '123'}, obj1_class2_fromJson.c.inner.abc, 'MXML.load(MXML.Tests.Class2()).c.inner.abc');
test.checkExpectation(1:10, obj1_class2_fromJson.c.inner.xyz, 'MXML.load(MXML.Tests.Class2()).c.inner.xyz');
test.checkExpectation('blah blah blha', obj1_class2_fromJson.d, 'MXML.load(MXML.Tests.Class2()).d');

test.checkExpectation('string', obj7_class2.a, 'MXML.load(MXML.Tests.Class2()_2).a');
test.checkExpectation(1:10, obj7_class2.b, 'MXML.load(MXML.Tests.Class2()_2).b');
test.checkEmptyExpectation(obj7_class2.c, 'MXML.load(MXML.Tests.Class2()_2).c');
test.checkExpectation('blah blah blha', obj7_class2.d, 'MXML.load(MXML.Tests.Class2()_2).d');

test.checkExpectation(1:10, obj1_class3_fromJson.k, 'MXML.Tests.Class3().k');
test.checkExpectation('1:10', obj1_class3_fromJson.l, 'MXML.Tests.Class3().l');
test.checkExpectation(1:3, obj1_class3_fromJson.m.a, 'MXML.Tests.Class3().m.a');
test.checkExpectation('^_^', obj1_class3_fromJson.m.b, 'MXML.Tests.Class3().m.b');

test.evaluateAllExpectations();

%% --------------------------------------------
% Save to MXML file
%----------------------------------------------
test = UnitTests.UnitTesting('MXML.save/load json file');

tic
MXML.save([thisFolder 'string.json'], thisFolder);
MXML.save([thisFolder 'obj1_struct.json'], obj1_struct);
MXML.save([thisFolder 'obj1_class1.json'], obj1_class1);
MXML.save([thisFolder 'obj1_class2.json'], obj1_class2);
MXML.save([thisFolder 'obj1_class3.json'], obj1_class3);
toc

%----------------------------------------------
% Validate file contents
%----------------------------------------------
fid = fopen([thisFolder 'string.json']);
content = fread(fid, '*char')';
fclose(fid);
test.checkExpectation(['{"type":"struct","value":{"data":"' strrep(thisFolder, '\', '\\') '"}}'], content, 'MXML.Tests.save(string)');

fid = fopen([thisFolder 'obj1_struct.json']);
content = fread(fid, '*char')';
fclose(fid);
test.checkExpectation(json1, content, 'MXML.Tests.save(string)');

fid = fopen([thisFolder 'obj1_class1.json']);
content = fread(fid, '*char')';
fclose(fid);
test.checkExpectation(json2, content, 'MXML.Tests.save(string)');

fid = fopen([thisFolder 'obj1_class2.json']);
content = fread(fid, '*char')';
fclose(fid);
test.checkExpectation(json3, content, 'MXML.Tests.save(string)');

fid = fopen([thisFolder 'obj1_class3.json']);
content = fread(fid, '*char')';
fclose(fid);
test.checkExpectation(json4, content, 'MXML.Tests.save(string)');

%----------------------------------------------
% Load from MXML file
%----------------------------------------------
tic
str_fromjson = MXML.load([thisFolder 'string.json']);
obj1_struct_fromJson = MXML.load([thisFolder 'obj1_struct.json']);
obj1_class1_fromJson = MXML.load([thisFolder 'obj1_class1.json']);
obj1_class2_fromJson = MXML.load([thisFolder 'obj1_class2.json']);
obj1_class3_fromJson = MXML.load([thisFolder 'obj1_class3.json']);
toc



test.checkExpectation(thisFolder, str_fromjson, 'MXML.load(string)');

test.checkExpectation({'abc', 'xyz', '123'}, obj1_struct_fromJson.abc, 'MXML.load(struct).abc');
test.checkExpectation(1:10, obj1_struct_fromJson.xyz, 'MXML.load(struct).xyz');
test.checkExpectation({'abc', 'xyz', '123'}, obj1_struct_fromJson.inner.abc, 'MXML.load(struct).inner.abc');
test.checkExpectation(1:10, obj1_struct_fromJson.inner.xyz, 'MXML.load(struct).inner.xyz');
test.checkExpectation(3, length(obj1_struct_fromJson.mixedCell), 'MXML.load(struct).mixedCell.length');
test.checkExpectation('kmn', obj1_struct_fromJson.mixedCell{1}, 'MXML.load(struct).mixedCell{1}');
test.checkExpectation(1:10, obj1_struct_fromJson.mixedCell{2}, 'MXML.load(struct).mixedCell{2}');
test.checkExpectation('a', obj1_struct_fromJson.mixedCell{3}.a, 'MXML.load(struct).mixedCell{3}.a');
test.checkExpectation(1:3, obj1_struct_fromJson.mixedCell{3}.b, 'MXML.load(struct).mixedCell{3}.b');

test.checkExpectation('x', obj1_class1_fromJson.x, 'MXML.load(MXML.Tests.Class1()).x');
test.checkExpectation(1:10, obj1_class1_fromJson.y, 'MXML.load(MXML.Tests.Class1()).y');
test.checkExpectation('MXML.Tests.IterableImplForTest', class(obj1_class1_fromJson.list), 'MXML.load(MXML.Tests.Class1()).list.type');
test.checkExpectation(1:10, obj1_class1_fromJson.list.arr, 'MXML.load(MXML.Tests.Class1()).list.arr');

test.checkExpectation('a', obj1_class2_fromJson.a, 'MXML.load(MXML.Tests.Class2()).a');
test.checkExpectation(1:10, obj1_class2_fromJson.b, 'MXML.load(MXML.Tests.Class2()).b');
test.checkExpectation({'abc', 'xyz', '123'}, obj1_class2_fromJson.c.abc, 'MXML.load(MXML.Tests.Class2()).c.abc');
test.checkExpectation(1:10, obj1_class2_fromJson.c.xyz, 'MXML.load(MXML.Tests.Class2()).c.xyz');
test.checkExpectation({'abc', 'xyz', '123'}, obj1_class2_fromJson.c.inner.abc, 'MXML.load(MXML.Tests.Class2()).c.inner.abc');
test.checkExpectation(1:10, obj1_class2_fromJson.c.inner.xyz, 'MXML.load(MXML.Tests.Class2()).c.inner.xyz');
test.checkExpectation('blah blah blha', obj1_class2_fromJson.d, 'MXML.load(MXML.Tests.Class2()).d');

test.checkExpectation('string', obj7_class2.a, 'MXML.load(MXML.Tests.Class2()_2).a');
test.checkExpectation(1:10, obj7_class2.b, 'MXML.load(MXML.Tests.Class2()_2).b');
test.checkEmptyExpectation(obj7_class2.c, 'MXML.load(MXML.Tests.Class2()_2).c');
test.checkExpectation('blah blah blha', obj7_class2.d, 'MXML.load(MXML.Tests.Class2()_2).d');

test.checkExpectation(1:10, obj1_class3_fromJson.k, 'MXML.Tests.Class3().k');
test.checkExpectation('1:10', obj1_class3_fromJson.l, 'MXML.Tests.Class3().l');
test.checkExpectation(1:3, obj1_class3_fromJson.m.a, 'MXML.Tests.Class3().m.a');
test.checkExpectation('^_^', obj1_class3_fromJson.m.b, 'MXML.Tests.Class3().m.b');

test.evaluateAllExpectations();