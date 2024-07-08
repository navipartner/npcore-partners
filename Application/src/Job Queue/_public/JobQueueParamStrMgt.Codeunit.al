codeunit 6014501 "NPR Job Queue Param. Str. Mgt."
{
    Access = Public;

    var
        ParamString: Text;
        _ParamDict: Dictionary of [Text, Text];
        Initialized: Boolean;

    procedure Parse(_ParamString: Text)
    var
        KeyValueList: List of [Text];
        KeyValuePair: Text;
    begin
        ClearParamDict();

        ParamString := _ParamString;
        KeyValueList := ParamString.Split(',');
        foreach KeyValuePair in KeyValueList do
            AddToParamDict(KeyValuePair, _ParamDict);

        Initialized := true;
    end;

    procedure ParamStringContains(SubString: Text): Boolean
    begin
        MakeSureIsInitialized();
        if (ParamString = '') or (SubString = '') then
            exit(false);
        exit(ParamString.Contains(SubString));
    end;

    internal procedure HasParams(): Boolean
    begin
        MakeSureIsInitialized();
        exit(_ParamDict.Count() > 0);
    end;

    procedure ContainsParam(ParamKey: Text): Boolean
    begin
        MakeSureIsInitialized();
        if ParamKey = '' then
            exit(false);
        exit(_ParamDict.ContainsKey(ParamKey));
    end;

    procedure GetParamValueAsText(ParamKey: Text): Text
    begin
        MakeSureIsInitialized();
        if ParamKey <> '' then
            if _ParamDict.ContainsKey(ParamKey) then
                exit(_ParamDict.Get(ParamKey));
        exit('');
    end;

    procedure GetParamValueAsBoolean(ParamKey: Text) ParamValue: Boolean
    var
        R: Text;
    begin
        MakeSureIsInitialized();
        ParamValue := false;
        if ParamKey <> '' then
            if _ParamDict.ContainsKey(ParamKey) then begin
                R := _ParamDict.Get(ParamKey);
                if R = '' then // if only parameter name is present
                    ParamValue := true
                else
                    evaluate(ParamValue, _ParamDict.Get(ParamKey));
            end;
    end;

    procedure GetParamValueAsInteger(ParamKey: Text) ParamValue: Integer
    begin
        MakeSureIsInitialized();
        ParamValue := 0;
        if ParamKey <> '' then
            if _ParamDict.ContainsKey(ParamKey) then
                evaluate(ParamValue, _ParamDict.Get(ParamKey));
    end;

    procedure ClearParamDict()
    begin
        Clear(_ParamDict);
        ParamString := '';
        Initialized := false;
    end;

    procedure AddToParamDict(KeyValuePair: Text)
    begin
        AddToParamDict(KeyValuePair, _ParamDict);
    end;

    local procedure AddToParamDict(KeyValuePair: Text; ParamDict: Dictionary of [Text, Text])
    var
        KVList: List of [Text];
        K: Text;
        V: Text;
    begin
        Initialized := true;

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
        KeyList := _ParamDict.Keys;
        foreach ParamKey in KeyList do
            if ParamKey <> '' then begin
                if ResultString <> '' then
                    ResultString := ResultString + ',';
                ResultString := ResultString + ParamKey;
                if _ParamDict.Get(ParamKey, ParamValue) then
                    if ParamValue <> '' then
                        ResultString := ResultString + '=' + ParamValue;
            end;

        exit(ResultString);
    end;

    local procedure MakeSureIsInitialized()
    var
        NotInitializedErr: Label 'A method call was made on an uninitialized instance of the Job Queue Param. Str. Mgt. codeunit, that requires an active and initialized instance to succeed. This is a critical programming error. Please contact system vendor.';
    begin
        if not Initialized then
            Error(NotInitializedErr);
    end;
}
