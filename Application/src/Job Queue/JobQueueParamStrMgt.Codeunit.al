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
        ClearParamDict();

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

    procedure ContainsParam(ParamKey: Text): Boolean
    begin
        exit(ParamDict.ContainsKey(ParamKey));
    end;

    procedure GetText(ParamKey: Text) ParamValue: Text
    begin
        ParamValue := '';
        if ParamDict.ContainsKey(ParamKey) then
            exit(ParamDict.Get(ParamKey));
    end;

    procedure GetBoolean(ParamKey: Text) ParamValue: Boolean
    var
        R: Text;
    begin
        ParamValue := false;
        if ParamDict.ContainsKey(ParamKey) then begin
            R := ParamDict.Get(ParamKey);
            if R = '' then // if only parameter name is present
                ParamValue := true
            else
                evaluate(ParamValue, ParamDict.Get(ParamKey));
        end;
    end;

    procedure GetInteger(ParamKey: Text) ParamValue: Integer
    begin
        ParamValue := 0;
        if ParamDict.ContainsKey(ParamKey) then
            evaluate(ParamValue, ParamDict.Get(ParamKey));
    end;

    procedure ClearParamDict()
    begin
        Clear(ParamDict);
    end;

    procedure AddToParamDict(KeyValuePair: Text)
    begin
        AddToParamDict(KeyValuePair, ParamDict);
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

    procedure GetParamListAsCSString(): Text
    var
        KeyList: List of [Text];
        ParamKey: Text;
        ParamValue: Text;
        ResultString: Text;
    begin
        KeyList := ParamDict.Keys;
        foreach ParamKey in KeyList do
            if ParamKey <> '' then begin
                if ResultString <> '' then
                    ResultString := ResultString + ',';
                ResultString := ResultString + ParamKey;
                if ParamDict.Get(ParamKey, ParamValue) then
                    if ParamValue <> '' then
                        ResultString := ResultString + '=' + ParamValue;
            end;

        exit(ResultString);
    end;
}