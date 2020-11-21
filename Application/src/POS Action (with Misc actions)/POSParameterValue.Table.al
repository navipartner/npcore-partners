table 6150705 "NPR POS Parameter Value"
{
    Caption = 'POS Parameter Value';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(2; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Menu";
        }
        field(3; ID; Integer)
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Record ID"; RecordID)
        {
            Caption = 'Record ID';
            DataClassification = CustomerContent;
        }
        field(5; Name; Text[30])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(6; "Action Code"; Code[20])
        {
            Caption = 'Action Code';
            DataClassification = CustomerContent;
        }
        field(7; "Data Type"; Option)
        {
            Caption = 'Data Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Text,Integer,Decimal,Date,Boolean,Option';
            OptionMembers = Text,"Integer",Decimal,Date,Boolean,Option;
        }
        field(8; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupValue();
            end;

            trigger OnValidate()
            begin
                ValidateValue();
            end;
        }
    }

    keys
    {
        key(Key1; "Table No.", "Code", ID, "Record ID", Name)
        {
        }
    }

    var
        OptionStringCache: JsonObject;
        ParamFilterIndicator: Boolean;

    procedure InitForMenuButton(MenuButton: Record "NPR POS Menu Button")
    begin
        Init;
        "Table No." := DATABASE::"NPR POS Menu Button";
        Code := MenuButton."Menu Code";
        ID := MenuButton.ID;
        "Record ID" := MenuButton.RecordId;
    end;

    procedure InitForField(RecordID: RecordID; FieldID: Integer)
    var
        RecRef: RecordRef;
    begin
        RecRef.Get(RecordID);

        Init;
        "Table No." := RecRef.Number;
        Code := '';
        ID := FieldID;
        "Record ID" := RecordID;
    end;

    procedure FilterParameters(RecordID: RecordID; FieldID: Integer): Boolean
    var
        RecRef: RecordRef;
    begin
        RecRef.Get(RecordID);

        Reset();
        SetRange("Table No.", RecRef.Number);
        SetRange("Record ID", RecordID);
        SetRange(ID, FieldID);
    end;

    procedure FindSetMenuButtonParameters(MenuCode: Code[20]; ButtonID: Integer; ForModify: Boolean): Boolean
    begin
        Reset();
        SetRange("Table No.", DATABASE::"NPR POS Menu Button");
        SetRange(Code, MenuCode);
        SetRange(ID, ButtonID);
        exit(FindSet(ForModify));
    end;

    [TryFunction]
    local procedure ValidateValue()
    var
        Param: Record "NPR POS Action Parameter";
        OptionsCaption: Text;
        BaseOption: Text;
    begin
        OnValidateValue(Rec);
        Param."Data Type" := "Data Type";
        Param.Options := GetOptions();
        if Param."Data Type" = Param."Data Type"::Boolean then
            OptionsCaption := BoolOptionMLCaptions();
        OnGetParameterOptionStringCaption(Rec, OptionsCaption);
        if OptionsCaption <> '' then
            if TryGetBaseOptionStringValue(Param.Options, OptionsCaption, Value, BaseOption) then
                Value := BaseOption;
        Param.Validate("Default Value", Value);
        Value := Param."Default Value";
    end;

    procedure AddParameterToAction(Target: Interface "NPR IAction")
    var
        Param: Record "NPR POS Action Parameter";
        OptionsJson: JsonObject;
        Date: Date;
        Decimal: Decimal;
        "Integer": Integer;
        Boolean: Boolean;
        CacheKey: Text;
        JsonMgt: Codeunit "NPR POS JSON Management";
        OptionToken: JsonToken;
    begin
        case "Data Type" of
            "Data Type"::Boolean:
                begin
                    Evaluate(Boolean, Value, 9);
                    Target.Parameters.Add(Name, Boolean);
                end;
            "Data Type"::Date:
                begin
                    Evaluate(Date, Value, 9);
                    Target.Parameters.Add(Name, Date);
                end;
            "Data Type"::Decimal:
                begin
                    Evaluate(Decimal, Value, 9);
                    Target.Parameters.Add(Name, Decimal);
                end;
            "Data Type"::Integer:
                begin
                    Evaluate(Integer, Value, 9);
                    Target.Parameters.Add(Name, Integer);
                end;
            "Data Type"::Text:
                Target.Parameters.Add(Name, Value);
            "Data Type"::Option:
                begin
                    Param.Options := GetOptions();
                    CacheKey := StrSubstNo('Action_%1-Param_%2', "Action Code", Name);
                    if OptionStringCache.Contains(CacheKey) then begin
                        OptionStringCache.Get(CacheKey, OptionToken);
                        JsonMgt.AddVariantValueToJsonObject(Target.Parameters, '_option_' + Name, OptionToken.AsObject());
                    end else begin
                        Param.GetOptionsDictionary(OptionsJson);
                        JsonMgt.AddVariantValueToJsonObject(Target.Parameters, '_option_' + Name, OptionsJson);
                        OptionStringCache.Add(CacheKey, OptionsJson);
                    end;
                    Target.Parameters.Add(Name, Param.GetOptionInt(Value));
                    Target.Content.Add('param_option_' + Name + 'originalValue', Value);
                end;
        end;
    end;

    procedure AddParameterToJObject(Target: JsonObject)
    var
        Param: Record "NPR POS Action Parameter";
        Date: Date;
        Decimal: Decimal;
        "Integer": Integer;
        Boolean: Boolean;
    begin
        case "Data Type" of
            "Data Type"::Boolean:
                begin
                    Evaluate(Boolean, Value, 9);
                    Target.Add(Name, Boolean);
                end;
            "Data Type"::Date:
                begin
                    Evaluate(Date, Value, 9);
                    Target.Add(Name, Date);
                end;
            "Data Type"::Decimal:
                begin
                    Evaluate(Decimal, Value, 9);
                    Target.Add(Name, Decimal);
                end;
            "Data Type"::Integer:
                begin
                    Evaluate(Integer, Value, 9);
                    Target.Add(Name, Integer);
                end;
            "Data Type"::Text:
                Target.Add(Name, Value);
            "Data Type"::Option:
                begin
                    Param.Options := GetOptions();
                    Target.Add(Name, Param.GetOptionInt(Value));
                end;
        end;
    end;

    local procedure GetOptions(): Text
    var
        Param: Record "NPR POS Action Parameter";
    begin
        if Param.Get("Action Code", Name) then
            if Param."Data Type" = Param."Data Type"::Boolean then
                exit(BoolOptionNames())
            else
                exit(Param.Options);
    end;

    procedure LookupValue()
    var
        TempRetailList: Record "NPR Retail List" temporary;
        POSActionParamMgt: Codeunit "NPR POS Action Param. Mgt.";
        Parts: List of [Text];
        Options: Text;
        "Part": Text;
        OptionsCaption: Text;
        Handled: Boolean;
    begin
        OnLookupValue(Rec, Handled);
        if Handled then
            exit;
        case "Data Type" of
            "Data Type"::Option:
                begin
                    Options := GetOptions();
                    OnGetParameterOptionStringCaption(Rec, OptionsCaption);
                    if OptionsCaption <> '' then
                        POSActionParamMgt.SplitString(OptionsCaption, Parts)
                    else
                        POSActionParamMgt.SplitString(Options, Parts);
                    foreach Part in Parts do begin
                        TempRetailList.Number += 1;
                        TempRetailList.Choice := Part;
                        TempRetailList.Insert;
                    end;
                end;

            "Data Type"::Boolean:
                begin
                    POSActionParamMgt.SplitString(BoolOptionMLCaptions(), Parts);
                    foreach Part in Parts do begin
                        TempRetailList.Number += 1;
                        TempRetailList.Choice := Part;
                        TempRetailList.Insert;
                    end;
                end;
            else
                exit;
        end;

        if TempRetailList.IsEmpty then
            exit;
        if Value <> '' then
            case "Data Type" of
                "Data Type"::Boolean:
                    TempRetailList.SetRange(Choice, GetBooleanStringCaption());
                "Data Type"::Option:
                    TempRetailList.SetRange(Choice, GetOptionStringCaption(OptionsCaption));
            end;
        if TempRetailList.FindFirst then;
        TempRetailList.SetRange(Choice);

        if PAGE.RunModal(PAGE::"NPR Retail List", TempRetailList) = ACTION::LookupOK then
            Validate(Value, TempRetailList.Choice);
    end;

    procedure GetParameter(RecordID: RecordID; ID: Integer; Name: Text): Boolean
    var
        ParamValue: Record "NPR POS Parameter Value";
        RecRef: RecordRef;
    begin
        RecRef.Get(RecordID);

        ParamValue.SetRange("Table No.", RecRef.Number);
        ParamValue.SetRange("Record ID", RecordID);
        ParamValue.SetRange(ID, ID);
        ParamValue.SetRange(Name, Name);
        if ParamValue.FindFirst then begin
            Rec := ParamValue;
            exit(true);
        end;
    end;

    procedure GetTableViewString(TableID: Integer; ViewString: Text): Text
    var
        RecRef: RecordRef;
        PageBuilder: FilterPageBuilder;
    begin
        RecRef.Open(TableID);
        PageBuilder.AddTable(RecRef.Caption, RecRef.Number);
        if (ViewString <> '') and (TrySetView(RecRef, ViewString)) then
            PageBuilder.SetView(RecRef.Caption, ViewString);
        if PageBuilder.RunModal() then begin
            ViewString := PageBuilder.GetView(RecRef.Caption, false);
        end;
        exit(ViewString);
    end;

    [TryFunction]
    local procedure TryGetBaseOptionStringValue(OptionString: Text; OptionStringCaption: Text; CaptionValue: Text; var BaseOption: Text)
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        BaseOption := SelectStr(TypeHelper.GetOptionNo(CaptionValue, OptionStringCaption) + 1, OptionString);
    end;

    [TryFunction]
    local procedure TrySetView(RecRef: RecordRef; FilterString: Text)
    begin
        RecRef.SetView(FilterString);
    end;

    procedure SetParamFilterIndicator()
    begin
        ParamFilterIndicator := true;
    end;

    procedure GetParamFilterIndicator(): Boolean
    begin
        exit(ParamFilterIndicator);
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    begin
    end;

    local procedure BoolOptionNames(): Text
    begin
        exit('false,true');
    end;

    local procedure BoolOptionMLCaptions(): Text
    var
        BoolMLOptionList: Label 'false,true';
    begin
        exit(BoolMLOptionList);
    end;

    procedure GetOptionStringCaption(ParameterOptionStringCaption: Text): Text
    var
        POSActionParameter: Record "NPR POS Action Parameter";
        TypeHelper: Codeunit "Type Helper";
        OptionCaption: Text;
    begin
        POSActionParameter.Get("Action Code", Name);

        if TrySelectStr(TypeHelper.GetOptionNo(Value, POSActionParameter.Options), ParameterOptionStringCaption, OptionCaption) then
            exit(OptionCaption)
        else
            exit(Value);
    end;

    procedure GetBooleanStringCaption(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        OptionCaption: Text;
    begin
        if TrySelectStr(TypeHelper.GetOptionNo(Value, BoolOptionNames), BoolOptionMLCaptions, OptionCaption) then
            exit(OptionCaption)
        else
            exit(Value);
    end;

    [TryFunction]
    local procedure TrySelectStr(Ordinal: Integer; OptionString: Text; var OptionOut: Text)
    begin
        OptionOut := SelectStr(Ordinal + 1, OptionString);
    end;
}
