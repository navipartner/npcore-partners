table 6184484 "NPR EFTType POSUnit Gen.Param."
{
    Access = Internal;
    // NPR5.46/MMV /20181008 CASE 290734 Created object

    Caption = 'EFT Type POS Unit Gen. Param.';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Integration Type"; Code[20])
        {
            Caption = 'Integration Type';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[30])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; "Data Type"; Option)
        {
            Caption = 'Data Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Text,Integer,Decimal,Date,Boolean,Option';
            OptionMembers = Text,"Integer",Decimal,Date,Boolean,Option;
        }
        field(4; Value; Text[250])
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
        field(5; OptionString; Text[250])
        {
            Caption = 'OptionString';
            DataClassification = CustomerContent;
        }
        field(6; "User Configurable"; Boolean)
        {
            Caption = 'User Configurable';
            DataClassification = CustomerContent;
        }
        field(7; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
        }
    }

    keys
    {
        key(Key1; "Integration Type", "POS Unit No.", Name)
        {
        }
    }

    fieldgroups
    {
    }

    var
        BoolYes: Label 'Yes';
        BoolNo: Label 'No';
        FieldErrorBase: Label 'is not a valid %1';
        FieldErrorOption: Label 'does not contain a valid option (%1)';

    procedure GetTextParameterValue(IntegrationType: Text; POSUnitNo: Text; NameIn: Text; DefaultValue: Text; UserConfigurable: Boolean): Text
    begin
        FindOrCreateRecord(IntegrationType, POSUnitNo, NameIn, "Data Type"::Text, DefaultValue, '', UserConfigurable);
        exit(Value);
    end;

    procedure GetIntegerParameterValue(IntegrationType: Text; POSUnitNo: Text; NameIn: Text; DefaultValue: Integer; UserConfigurable: Boolean): Integer
    var
        "Integer": Integer;
    begin
        FindOrCreateRecord(IntegrationType, POSUnitNo, NameIn, "Data Type"::Integer, DefaultValue, '', UserConfigurable);
        Evaluate(Integer, Value, 9);
        exit(Integer);
    end;

    procedure GetBooleanParameterValue(IntegrationType: Text; POSUnitNo: Text; NameIn: Text; DefaultValue: Boolean; UserConfigurable: Boolean): Boolean
    var
        Boolean: Boolean;
    begin
        FindOrCreateRecord(IntegrationType, POSUnitNo, NameIn, "Data Type"::Boolean, DefaultValue, '', UserConfigurable);
        Evaluate(Boolean, Value, 9);
        exit(Boolean);
    end;

    procedure GetOptionParameterValue(IntegrationType: Text; POSUnitNo: Text; NameIn: Text; DefaultValue: Integer; OptionStringIn: Text; UserConfigurable: Boolean): Integer
    var
        "Integer": Integer;
    begin
        FindOrCreateRecord(IntegrationType, POSUnitNo, NameIn, "Data Type"::Option, DefaultValue, OptionStringIn, UserConfigurable);
        Evaluate(Integer, Value, 9);
        exit(Integer);
    end;

    procedure GetDecimalParameterValue(IntegrationType: Text; POSUnitNo: Text; NameIn: Text; DefaultValue: Decimal; UserConfigurable: Boolean): Decimal
    var
        Decimal: Decimal;
    begin
        FindOrCreateRecord(IntegrationType, POSUnitNo, NameIn, "Data Type"::Decimal, DefaultValue, '', UserConfigurable);
        Evaluate(Decimal, Value, 9);
        exit(Decimal);
    end;

    procedure GetDateParameterValue(IntegrationType: Text; POSUnitNo: Text; NameIn: Text; DefaultValue: Date; UserConfigurable: Boolean): Date
    var
        Date: Date;
    begin
        FindOrCreateRecord(IntegrationType, POSUnitNo, NameIn, "Data Type"::Date, DefaultValue, '', UserConfigurable);
        Evaluate(Date, Value, 9);
        exit(Date);
    end;

    procedure FindOrCreateRecord(IntegrationType: Text; POSUnitNo: Text; NameIn: Text; DataType: Integer; DefaultValue: Variant; OptionStringIn: Text; UserConfigurable: Boolean)
    begin
        if not Get(IntegrationType, POSUnitNo, NameIn) then begin
            Init();
            "Integration Type" := IntegrationType;
            "POS Unit No." := POSUnitNo;
            Name := NameIn;
            "Data Type" := DataType;
            OptionString := OptionStringIn;
            "User Configurable" := UserConfigurable;
            Validate(Value, DefaultValue);
            Insert();
        end;
    end;

    procedure UpdateParameterValue(IntegrationType: Text; POSUnitNo: Text; NameIn: Text; ValueIn: Variant)
    begin
        Get(IntegrationType, POSUnitNo, NameIn);
        Validate(Value, ValueIn);
        Modify();
    end;

    procedure LookupValue()
    var
        TempRetailList: Record "NPR Retail List" temporary;
#if not CLOUD
        Parts: DotNet NPRNetArray;
        "Part": DotNet NPRNetString;
#else
        Parts: List of [Text];
        "Part": Text;
#endif
        OptionStringCaption: Text;
        Handled: Boolean;
    begin
        OnLookupParameterValue(Rec, Handled);
        if Handled then
            exit;

        if not "User Configurable" then
            exit; //Only allow custom lookups on fields that should not be directly editable.

        if "Data Type" <> "Data Type"::Option then
            exit;

        OnGetParameterOptionStringCaption(Rec, OptionStringCaption);
        if OptionStringCaption <> '' then
            SplitString(OptionStringCaption, Parts)
        else
            SplitString(OptionString, Parts);

        foreach "Part" in Parts do begin
            TempRetailList.Number += 1;
            TempRetailList.Choice := Part;
            TempRetailList.Insert();
        end;

        if TempRetailList.IsEmpty then
            exit;

        if PAGE.RunModal(0, TempRetailList) = ACTION::LookupOK then
            Validate(Value, TempRetailList.Choice);
    end;

    procedure ValidateValue()
    var
        Boolean: Boolean;
        Date: Date;
        Decimal: Decimal;
        "Integer": Integer;
        OptionsCaption: Text;
        OptionOut: Text;
    begin
        case "Data Type" of
            "Data Type"::Boolean:
                begin
                    case true of
                        Evaluate(Boolean, Value, 9):
                            Value := Format(Boolean, 0, 9);
                        Evaluate(Boolean, Value):
                            Value := Format(Boolean, 0, 9);
                        UpperCase(Value) = UpperCase(BoolYes):
                            Value := Format(true, 0, 9);
                        UpperCase(Value) = UpperCase(BoolNo):
                            Value := Format(false, 0, 9);
                        else
                            FieldError(Value, StrSubstNo(FieldErrorBase, "Data Type"));
                    end;
                end;
            "Data Type"::Date:
                case true of
                    Evaluate(Date, Value, 9):
                        Value := Format(Date, 0, 9);
                    Evaluate(Date, Value):
                        Value := Format(Date, 0, 9);
                    else
                        FieldError(Value, StrSubstNo(FieldErrorBase, "Data Type"));
                end;
            "Data Type"::Integer:
                case true of
                    Evaluate(Integer, Value, 9):
                        Value := Format(Integer, 0, 9);
                    Evaluate(Integer, Value):
                        Value := Format(Integer, 0, 9);
                    else
                        FieldError(Value, StrSubstNo(FieldErrorBase, "Data Type"));
                end;
            "Data Type"::Decimal:
                case true of
                    Evaluate(Decimal, Value, 9):
                        Value := Format(Decimal, 0, 9);
                    Evaluate(Decimal, Value):
                        Value := Format(Decimal, 0, 9);
                    else
                        FieldError(Value, StrSubstNo(FieldErrorBase, "Data Type"));
                end;
            "Data Type"::Option:
                begin
                    OnGetParameterOptionStringCaption(Rec, OptionsCaption);
                    if OptionsCaption <> '' then
                        if TrySelectStr(GetOptionInt(Value, OptionsCaption), OptionString, OptionOut) then
                            Value := OptionOut;
                    case true of
                        Value = '':
                            Value := '0';
                        Evaluate(Integer, Value):
                            begin
                                if not TrySelectStr(Integer, OptionString, OptionOut) then
                                    FieldError(Value, StrSubstNo(FieldErrorOption, Value));
                                Value := Format(Integer);
                            end;
                        GetOptionInt(Value, OptionString) >= 0:
                            Value := Format(GetOptionInt(Value, OptionString));
                        else
                            FieldError(Value, StrSubstNo(FieldErrorOption, Value));
                    end;
                end;
        end;

        OnValidateParameterValue(Rec);
    end;

    procedure GetOptionInt(Value: Text; OptionStringIn: Text) Result: Integer
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.GetOptionNo(Value, OptionStringIn));
    end;

    procedure GetOptionString(Ordinal: Integer; OptionStringIn: Text): Text
    var
        OptionOut: Text;
    begin
        if TrySelectStr(Ordinal, OptionStringIn, OptionOut) then
            exit(OptionOut)
        else
            exit(Format(Ordinal));
    end;

    procedure GetDefaultOption(OptionStringIn: Text): Text
    var
        OptionOut: Text;
    begin
        if TrySelectStr(1, OptionStringIn, OptionOut) then
            exit(OptionOut);
    end;

    [TryFunction]
    procedure TrySelectStr(Ordinal: Integer; OptionStringIn: Text; var OptionOut: Text)
    begin
        OptionOut := SelectStr(Ordinal + 1, OptionStringIn);
    end;
#if not CLOUD
    local procedure SplitString(Text: Text; var Parts: DotNet NPRNetArray)
    var
        String: DotNet NPRNetString;
        Char: DotNet NPRNetString;
    begin
        String := Text;
        Char := ',';
        Parts := String.Split(Char.ToCharArray());
    end;
#else
    local procedure SplitString(Text: Text; var Parts: List of [Text])
    begin
        Parts := Text.Split(',');
    end;
#endif

    [IntegrationEvent(false, false)]
    procedure OnGetParameterNameCaption(Parameter: Record "NPR EFTType POSUnit Gen.Param."; var Caption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterDescriptionCaption(Parameter: Record "NPR EFTType POSUnit Gen.Param."; var Caption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterOptionStringCaption(Parameter: Record "NPR EFTType POSUnit Gen.Param."; var Caption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLookupParameterValue(var Parameter: Record "NPR EFTType POSUnit Gen.Param."; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnValidateParameterValue(var Parameter: Record "NPR EFTType POSUnit Gen.Param.")
    begin
    end;
}

