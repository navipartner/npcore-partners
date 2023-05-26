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
        _DescriptionCaption: Text;
        _NonBlockingUI: Boolean;
        TempParameter: Record "NPR POS Action Parameter" temporary;

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

    procedure SetNonBlockingUI()
    begin
        _NonBlockingUI := true;
    end;

    procedure SetActionCode(ActionCode: Text)
    begin
        _ActionCode := ActionCode;
    end;

    procedure Clear()
    begin
        ClearAll();
    end;

    local procedure AddParameter(Name: Text[30]; DataType: Option; DefaultValue: Text; Options: Text[250]; CaptionName: Text; CaptionDescription: Text; CaptionOptions: Text)
    var
        MissingNameLbl: Label 'Action %1, Workflow parameter %2 is missing a name caption';
        MissingDescriptionLbl: Label 'Action %1, Workflow parameter %2 is missing a description caption';
        MissingOptionsLbl: Label 'Action %1, Workflow parameter %2 is missing an options caption';
    begin
        if CaptionName = '' then
            Error(MissingNameLbl, _ActionCode, Name);
        if CaptionDescription = '' then
            Error(MissingDescriptionLbl, _ActionCode, Name);

        _ParameterNameCaption.Add(Name, CaptionName);
        _ParameterDescriptionCaption.Add(Name, CaptionDescription);

        TempParameter.Init();
        TempParameter."POS Action Code" := '';
        TempParameter.Name := Name;
        TempParameter."Data Type" := DataType;
        TempParameter."Default Value" := CopyStr(DefaultValue, 1, MaxStrLen(TempParameter."Default Value"));
        if DataType = TempParameter."Data Type"::Option then begin
            TempParameter.Options := Options;
            if CaptionOptions = '' then
                Error(MissingOptionsLbl, _ActionCode, Name);
            _ParameterOptionCaption.Add(Name, CaptionOptions);
        end;

        TempParameter.Validate("Default Value");
        TempParameter.Insert();
    end;

    /// <summary>
    /// Calculates a hash based on all the config an action codeunit can set. If any config changes, hash changes, which triggers an update of action and parameter records.
    /// </summary>
    /// <returns></returns>
    internal procedure CalculateWorkflowHash(): Text[32]
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
        ValueToHash: TextBuilder;
    begin
        ValueToHash.Append('<actioncode>' + _ActionCode + '</actioncode>');

        if TempParameter.FindSet() then begin
            repeat
                ValueToHash.Append('<parameter>' + TempParameter.Name + '||' + Format(TempParameter."Data Type") + '||' + TempParameter.Options + '</parameter>');
            until TempParameter.Next() = 0;
        end;

        ValueToHash.Append('<js>' + _Javascript + '</js>');
        ValueToHash.Append('<unattended>' + format(_Unattended, 0, 9) + '</unattended>');
        ValueToHash.Append('<boundtodatasource>' + format(_BoundToDataSource, 0, 9) + '</boundtodatasource>');
        ValueToHash.Append('<datasourcename>' + _DataSourceName + '</datasourcename>');
        ValueToHash.Append('<customJSmethod>' + _CustomJSMethod + '</customJSmethod>');
        ValueToHash.Append('<customJScode>' + _CustomJSCode + '</customJScode>');
        ValueToHash.Append('<nonblockingui>' + Format(_NonBlockingUI, 0, 9) + '</nonblockingui>');

# pragma warning disable AA0139
        Exit(CryptographyManagement.GenerateHash(ValueToHash.ToText(), HashAlgorithmType::MD5));
# pragma warning restore
    end;

    internal procedure GetWorkflowParameters(var ParametersOut: Record "NPR POS Action Parameter" temporary; var JavascriptOut: Text; var UnattendedOut: Boolean; var BoundToDataSourceOut: Boolean; var DataSourceOut: Text; var CustomJSMethod: Text; var CustomJSCode: Text; var NonBlockingUIOut: Boolean; var DescriptionOut: Text)
    begin
        ParametersOut.Copy(TempParameter, true);
        JavascriptOut := _Javascript;
        UnattendedOut := _Unattended;
        BoundToDataSourceOut := _BoundToDataSource;
        DataSourceOut := _DataSourceName;
        CustomJSMethod := _CustomJSMethod;
        CustomJSCode := _CustomJSCode;
        NonBlockingUIOut := _NonBlockingUI;
        DescriptionOut := _DescriptionCaption;
    end;

    internal procedure GetWorkflowActionParameters(var ParametersOut: Record "NPR POS Action Parameter" temporary)
    begin
        ParametersOut.Copy(TempParameter, true);
    end;

    internal procedure GetWorkflowCaptions(var LabelsOut: Dictionary of [Text, Text]; var ParameterNamesOut: Dictionary of [Text, Text]; var ParameterDescOut: Dictionary of [Text, Text]; var ParameterOptionCaptionOut: Dictionary of [Text, Text])
    begin
        LabelsOut := _Labels;
        ParameterNamesOut := _ParameterNameCaption;
        ParameterDescOut := _ParameterDescriptionCaption;
        ParameterOptionCaptionOut := _ParameterOptionCaption;
    end;

    internal procedure GetWorkflowDescription(): Text
    begin
        exit(_DescriptionCaption);
    end;

}