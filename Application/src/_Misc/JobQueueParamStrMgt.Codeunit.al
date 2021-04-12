codeunit 6014501 "NPR Job Queue Param. Str. Mgt."
{
    var
        ParamString: Text;
        ParamDict: Dictionary of [Text, Text];

    procedure Parse(_ParamString: Text)
    var
        KeyValueList: List of [Text];
        KeyValuePair: Text;
    begin
        Clear(ParamDict);

        ParamString := _ParamString;

        KeyValueList := ParamString.Split(',');

        foreach KeyValuePair in KeyValueList do
            AddToParamDict(KeyValuePair, ParamDict);
    end;

    procedure ParamStringContains(SubString: Text): Boolean
    begin
        if ParamString = '' then
            exit(false);

        exit(ParamString.Contains(SubString));
    end;

    procedure HasParams(): Boolean
    begin
        exit(ParamDict.Count() > 0);
    end;

    procedure ContainsParam(Param: Text): Boolean
    begin
        exit(ParamDict.ContainsKey(Param));
    end;

    procedure GetText(Param: Text) V: Text
    begin
        V := '';
        if ParamDict.ContainsKey(Param) then
            exit(ParamDict.Get(Param));
    end;

    procedure GetBoolean(Param: Text) V: Boolean
    var
        R: Text;
    begin
        V := false;
        if ParamDict.ContainsKey(Param) then begin
            R := ParamDict.Get(Param);
            if R = '' then // if only parameter name is present
                V := true
            else
                evaluate(V, ParamDict.Get(Param));
        end;
    end;

    procedure GetInteger(Param: Text) V: Integer
    begin
        V := 0;
        if ParamDict.ContainsKey(Param) then
            evaluate(V, ParamDict.Get(Param));
    end;

    local procedure AddToParamDict(KeyValuePair: Text; ParamDict: Dictionary of [Text, Text])
    var
        KVList: List of [Text];
        K: Text;
        V: Text;
    begin
        KVList := KeyValuePair.Split('=');

        if not KVList.Get(1, K) then
            exit;

        if not KVList.Get(2, V) then
            V := '';

        if not ParamDict.ContainsKey(K) then
            ParamDict.Add(K, V);
    end;
}