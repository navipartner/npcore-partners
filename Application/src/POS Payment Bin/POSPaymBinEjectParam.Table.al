table 6150633 "NPR POS Paym. Bin Eject Param."
{
    Caption = 'POS Payment Bin Eject Param.';
    DataClassification = CustomerContent;
    LookupPageID = "NPR POS Paym. Bin Eject Params";

    fields
    {
        field(1; "Bin No."; Code[10])
        {
            Caption = 'Bin No.';
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
    }

    keys
    {
        key(Key1; "Bin No.", Name)
        {
        }
    }

    var
        BoolYesLbl: Label 'Yes';
        BoolNoLbl: Label 'No';
        FieldBaseErr: Label 'is not a valid %1';
        FieldOptionErr: Label 'does not contain a valid option (%1)';

    procedure FindOrCreateRecord(BinNoIn: Code[10]; NameIn: Text; DataType: Integer; DefaultValue: Variant; OptionStringIn: Text)
    begin
        if not Get(BinNoIn, NameIn) then begin
            Init();
            "Bin No." := BinNoIn;
            Name := NameIn;
            "Data Type" := DataType;
            OptionString := OptionStringIn;
            Validate(Value, DefaultValue);
            Insert();
            Commit();
        end;
    end;

    procedure LookupValue()
    var
        tmpRetailList: Record "NPR Retail List" temporary;
        Parts: List of [Text];
        "Part": Text;
        OptionStringCaption: Text;
    begin
        OnLookupParameter(Rec);

        if "Data Type" <> "Data Type"::Option then
            exit;

        OnGetParameterOptionStringCaption(Rec, OptionStringCaption);
        if OptionStringCaption <> '' then
            SplitString(OptionStringCaption, Parts)
        else
            SplitString(OptionString, Parts);

        foreach Part in Parts do begin
            tmpRetailList.Number += 1;
            tmpRetailList.Choice := Part;
            tmpRetailList.Insert();
        end;

        if tmpRetailList.IsEmpty then
            exit;

        if PAGE.RunModal(0, tmpRetailList) = ACTION::LookupOK then
            Validate(Value, tmpRetailList.Choice);
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
                        UpperCase(Value) = UpperCase(BoolYesLbl):
                            Value := Format(true, 0, 9);
                        UpperCase(Value) = UpperCase(BoolNoLbl):
                            Value := Format(false, 0, 9);
                        else
                            FieldError(Value, StrSubstNo(FieldBaseErr, "Data Type"));
                    end;
                end;
            "Data Type"::Date:
                case true of
                    Evaluate(Date, Value, 9):
                        Value := Format(Date, 0, 9);
                    Evaluate(Date, Value):
                        Value := Format(Date, 0, 9);
                    else
                        FieldError(Value, StrSubstNo(FieldBaseErr, "Data Type"));
                end;
            "Data Type"::Integer:
                case true of
                    Evaluate(Integer, Value, 9):
                        Value := Format(Integer, 0, 9);
                    Evaluate(Integer, Value):
                        Value := Format(Integer, 0, 9);
                    else
                        FieldError(Value, StrSubstNo(FieldBaseErr, "Data Type"));
                end;
            "Data Type"::Decimal:
                case true of
                    Evaluate(Decimal, Value, 9):
                        Value := Format(Decimal, 0, 9);
                    Evaluate(Decimal, Value):
                        Value := Format(Decimal, 0, 9);
                    else
                        FieldError(Value, StrSubstNo(FieldBaseErr, "Data Type"));
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
                                    FieldError(Value, StrSubstNo(FieldOptionErr, Value));
                                Value := Format(Integer);
                            end;
                        GetOptionInt(Value, OptionString) >= 0:
                            Value := Format(GetOptionInt(Value, OptionString));
                        else
                            FieldError(Value, StrSubstNo(FieldOptionErr, Value));
                    end;
                end;
        end;
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

    local procedure SplitString(Text: Text; var Parts: List of [Text])
    var
        String: Text;
        CharTxt: Text;
    begin
        String := Text;
        CharTxt := ',';
        Parts := String.Split(CharTxt);
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterNameCaption(PaymentBinInvokeParameter: Record "NPR POS Paym. Bin Eject Param."; var Caption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterDescriptionCaption(PaymentBinInvokeParameter: Record "NPR POS Paym. Bin Eject Param."; var Caption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterOptionStringCaption(PaymentBinInvokeParameter: Record "NPR POS Paym. Bin Eject Param."; var Caption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupParameter(var POSPaymentBinEjectParam: Record "NPR POS Paym. Bin Eject Param.")
    begin
    end;
}

