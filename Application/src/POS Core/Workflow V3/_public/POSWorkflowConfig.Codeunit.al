codeunit 6059786 "NPR POS Workflow Config"
{
    Access = Public;

    var
        _ActionCode: Text;
        _Javascript: Text;
        _Labels: Dictionary of [Text, Text];
        _ParameterNameCaption: Dictionary of [Text, Text];
        _ParameterDescriptionCaption: Dictionary of [Text, Text];
        _ParameterOptionCaption: Dictionary of [Text, Text];
        _Unattended: Boolean;
        _BoundToDataSource: Boolean;
        _DataSourceName: Text;
        _CustomJSMethod: Text;
        _CustomJSCode: Text;
        _BlockingUI: Boolean;
        _DescriptionCaption: Text;
        TempParameter: Record "NPR POS Action Parameter" temporary;


    /// <summary>
    /// Calculates a hash based on all the config an action codeunit can set. If any config changes, hash changes, which triggers an update of action and parameter records.
    /// </summary>
    /// <returns></returns>
    procedure CalculateHash(): Text[32]
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
        ValueToHash: TextBuilder;
    begin
        ValueToHash.Append('<actioncode>' + _ActionCode + '</actioncode>');

        if TempParameter.FindSet() then
            ValueToHash.Append('<parameter>' + TempParameter.Name + '||' + Format(TempParameter."Data Type") + '||' + TempParameter.Options + '</parameter>');
        repeat until TempParameter.Next() = 0;

        ValueToHash.Append('<js>' + _Javascript + '</js>');
        ValueToHash.Append('<unattended>' + format(_Unattended) + '</unattended>');
        ValueToHash.Append('<boundtodatasource>' + format(_BoundToDataSource) + '</boundtodatasource>');
        ValueToHash.Append('<datasourcename>' + _DataSourceName + '</datasourcename>');
        ValueToHash.Append('<customJSmethod>' + _CustomJSMethod + '</customJSmethod>');
        ValueToHash.Append('<customJScode>' + _CustomJSCode + '</customJScode>');
        ValueToHash.Append('<blockingui>' + Format(_BlockingUI) + '</blockingui>');

        Exit(CryptographyManagement.GenerateHash(ValueToHash.ToText(), HashAlgorithmType::MD5));
    end;

    procedure AddJavascript(Javascript: Text)
    begin
        _Javascript := Javascript;
    end;

    procedure AddActionDescription(Description: Text)
    begin
        _DescriptionCaption := Description;
    end;

    procedure AddTextParameter(Name: Text[30]; DefaultValue: Text; CaptionName: Text; CaptionDescription: Text)
    begin
        AddParameter(Name, TempParameter."Data Type"::Text, DefaultValue, '', CaptionName, CaptionDescription, '');
    end;

    procedure AddIntegerParameter(Name: Text[30]; DefaultValue: Integer; CaptionName: Text; CaptionDescription: Text)
    begin
        AddParameter(Name, TempParameter."Data Type"::Integer, Format(DefaultValue, 0, 9), '', CaptionName, CaptionDescription, '');
    end;

    procedure AddDateParameter(Name: Text[30]; DefaultValue: Date; CaptionName: Text; CaptionDescription: Text)
    begin
        AddParameter(Name, TempParameter."Data Type"::Date, Format(DefaultValue, 0, 9), '', CaptionName, CaptionDescription, '');
    end;

    procedure AddBooleanParameter(Name: Text[30]; DefaultValue: Boolean; CaptionName: Text; CaptionDescription: Text)
    begin
        AddParameter(Name, TempParameter."Data Type"::Boolean, Format(DefaultValue, 0, 9), '', CaptionName, CaptionDescription, '');
    end;

    procedure AddDecimalParameter(Name: Text[30]; DefaultValue: Decimal; CaptionName: Text; CaptionDescription: Text)
    begin
        AddParameter(Name, TempParameter."Data Type"::Decimal, Format(DefaultValue, 0, 9), '', CaptionName, CaptionDescription, '');
    end;

    procedure AddOptionParameter(Name: Text[30]; Options: Text[250]; DefaultValue: Text[250]; CaptionName: Text; CaptionDescription: Text; CaptionOptions: Text)
    begin
        AddParameter(Name, TempParameter."Data Type"::Option, DefaultValue, Options, CaptionName, CaptionDescription, CaptionOptions);
    end;

    procedure AddLabel(Name: Text; Value: Text)
    begin
        _Labels.Add(Name, Value);
    end;

    local procedure AddParameter(Name: Text[30]; DataType: Option; DefaultValue: Text[250]; Options: Text[250]; CaptionName: Text; CaptionDescription: Text; CaptionOptions: Text)
    begin
        if CaptionName = '' then
            Error('Action %1, Workflow parameter %2 is missing a name caption', _ActionCode, Name);
        if CaptionDescription = '' then
            Error('Action %1, Workflow parameter %2 is missing a description caption', _ActionCode, Name);

        _ParameterNameCaption.Add(Name, CaptionName);
        _ParameterDescriptionCaption.Add(Name, CaptionDescription);

        TempParameter.Init();
        TempParameter."POS Action Code" := '';
        TempParameter.Name := Name;
        TempParameter."Data Type" := DataType;
        TempParameter."Default Value" := DefaultValue;
        if DataType = TempParameter."Data Type"::Option then begin
            TempParameter.Options := Options;
            if CaptionOptions = '' then
                Error('Action %1, Workflow parameter %2 is missing an options caption', _ActionCode, Name);
            _ParameterOptionCaption.Add(Name, CaptionOptions);
        end;

        TempParameter.Validate("Default Value");
        TempParameter.Insert();
    end;

    procedure SetWorkflowTypeUnattended()
    begin
        _Unattended := true;
    end;

    procedure SetDataBinding()
    begin
        _BoundToDataSource := true;
    end;

    procedure SetDataSourceBinding(DataSource: Code[50])
    begin
        _BoundToDataSource := true;
        _DataSourceName := DataSource;
    end;

    procedure SetCustomJavaScriptLogic(Method: Text; JavaScriptCode: Text)
    begin
        _CustomJSMethod := Method;
        _CustomJSCode := JavaScriptCode;
    end;

    procedure SetBlockingUI()
    begin
        _BlockingUI := true;
    end;

    procedure SetActionCode(ActionCode: Text)
    begin
        _ActionCode := ActionCode;
    end;

    procedure Clear()
    begin
        ClearAll();
    end;

    procedure GetConfigValues(var ParametersOut: Record "NPR POS Action Parameter" temporary; var JavascriptOut: Text; var UnattendedOut: Boolean; var BoundToDataSourceOut: Boolean; var DataSourceOut: Text; var CustomJSMethod: Text; var CustomJSCode: Text; var BlockingUI: Boolean; var DescriptionOut: Text)
    begin
        ParametersOut.Copy(TempParameter, true);
        JavascriptOut := _Javascript;
        UnattendedOut := _Unattended;
        BoundToDataSourceOut := _BoundToDataSource;
        DataSourceOut := _DataSourceName;
        CustomJSMethod := _CustomJSMethod;
        CustomJSCode := _CustomJSCode;
        BlockingUI := _BlockingUI;
        DescriptionOut := _DescriptionCaption;
    end;

    procedure GetCaptions(var LabelsOut: Dictionary of [Text, Text]; var ParameterNamesOut: Dictionary of [Text, Text]; var ParameterDescOut: Dictionary of [Text, Text]; var ParameterOptionCaptionOut: Dictionary of [Text, Text])
    begin
        LabelsOut := _Labels;
        ParameterNamesOut := _ParameterNameCaption;
        ParameterDescOut := _ParameterDescriptionCaption;
        ParameterOptionCaptionOut := _ParameterOptionCaption;
    end;

    procedure GetDescription(): Text
    begin
        exit(_DescriptionCaption);
    end;
}