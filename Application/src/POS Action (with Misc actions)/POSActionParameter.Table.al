table 6150704 "NPR POS Action Parameter"
{
    Caption = 'POS Action Parameter';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Action Code"; Code[20])
        {
            Caption = 'POS Action Code';
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

            trigger OnValidate()
            begin
                ApplyDefaultValue();
            end;
        }
        field(4; "Default Value"; Text[250])
        {
            Caption = 'Default Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateDefaultValue();
            end;
        }
        field(5; Options; Text[250])
        {
            Caption = 'Options';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateOptions();
            end;
        }
    }

    keys
    {
        key(Key1; "POS Action Code", Name)
        {
        }
    }


    var
        BoolYes: Label 'Yes';
        BoolNo: Label 'No';
        FieldErrorBase: Label 'is not a valid %1';
        FieldErrorOption: Label 'does not contain a valid option (%1)';

    local procedure ApplyDefaultValue()
    begin
        if not ValidateDefaultValue() then
            case "Data Type" of
                "Data Type"::Boolean:
                    "Default Value" := Format(false, 0, 9);
                "Data Type"::Integer, "Data Type"::Decimal:
                    "Default Value" := Format(0, 0, 9);
                else
                    "Default Value" := '';
            end;
    end;

    [TryFunction]
    local procedure ValidateDefaultValue()
    var
        Boolean: Boolean;
        Date: Date;
        Decimal: Decimal;
        "Integer": Integer;
    begin
        case "Data Type" of
            "Data Type"::Boolean:
                begin
                    case true of
                        Evaluate(Boolean, "Default Value", 9):
                            "Default Value" := Format(Boolean, 0, 9);
                        Evaluate(Boolean, "Default Value"):
                            "Default Value" := Format(Boolean, 0, 9);
                        UpperCase("Default Value") = UpperCase(BoolYes):
                            "Default Value" := Format(true, 0, 9);
                        UpperCase("Default Value") = UpperCase(BoolNo):
                            "Default Value" := Format(false, 0, 9);
                        else
                            FieldError("Default Value", StrSubstNo(FieldErrorBase, "Data Type"));
                    end;
                end;
            "Data Type"::Date:
                case true of
                    Evaluate(Date, "Default Value", 9):
                        "Default Value" := Format(Date, 0, 9);
                    Evaluate(Date, "Default Value"):
                        "Default Value" := Format(Date, 0, 9);
                    else
                        FieldError("Default Value", StrSubstNo(FieldErrorBase, "Data Type"));
                end;
            "Data Type"::Integer:
                case true of
                    Evaluate(Integer, "Default Value", 9):
                        "Default Value" := Format(Integer, 0, 9);
                    Evaluate(Integer, "Default Value"):
                        "Default Value" := Format(Integer, 0, 9);
                    else
                        FieldError("Default Value", StrSubstNo(FieldErrorBase, "Data Type"));
                end;
            "Data Type"::Decimal:
                case true of
                    Evaluate(Decimal, "Default Value", 9):
                        "Default Value" := Format(Decimal, 0, 9);
                    Evaluate(Decimal, "Default Value"):
                        "Default Value" := Format(Decimal, 0, 9);
                    else
                        FieldError("Default Value", StrSubstNo(FieldErrorBase, "Data Type"));
                end;
            "Data Type"::Option:
                case true of
                    "Default Value" = '':
                        "Default Value" := GetDefaultOptionString();
                    Evaluate(Integer, "Default Value"):
                        "Default Value" := GetOptionString(Integer);
                    GetOptionInt("Default Value") >= 0:
                        exit;
                    else
                        FieldError("Default Value", StrSubstNo(FieldErrorOption, "Default Value"));
                end;
        end;
    end;

    local procedure ValidateOptions()
    begin
        if GetOptionInt("Default Value") = -1 then
            "Default Value" := GetDefaultOptionString();
    end;

    procedure GetOptionInt(Value: Text) Result: Integer
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.GetOptionNo(Value, Options));
    end;

    procedure GetOptionString(Ordinal: Integer): Text
    var
        OptionOut: Text;
    begin
        if TrySelectStr(Ordinal, OptionOut) then
            exit(OptionOut)
        else
            exit(Format(Ordinal));
    end;

    local procedure GetDefaultOptionString(): Text
    var
        OptionOut: Text;
    begin
        if TrySelectStr(1, OptionOut) then
            exit(OptionOut);
    end;

    procedure GetOptionsDictionary(var OptionsJson: JsonObject)
    var
        POSActionParamMgt: Codeunit "NPR POS Action Param. Mgt.";
        Parts: List of [Text];
        "Part": Text;
        Ordinal: Integer;
    begin
        Clear(OptionsJson);
        POSActionParamMgt.SplitString(Options, Parts);
        foreach Part in Parts do begin
            if (Part <> '') then
                OptionsJson.Add(Part, Ordinal);
            Ordinal += 1;
        end;
    end;

    [TryFunction]
    local procedure TrySelectStr(Ordinal: Integer; var OptionOut: Text)
    begin
        OptionOut := SelectStr(Ordinal + 1, Options);
    end;
}
