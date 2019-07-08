table 6150704 "POS Action Parameter"
{
    // NPR5.40/MMV /20180309 CASE 307453 Replaced .NET interop with standard NAV for option parsing performance

    Caption = 'POS Action Parameter';

    fields
    {
        field(1;"POS Action Code";Code[20])
        {
            Caption = 'POS Action Code';
        }
        field(2;Name;Text[30])
        {
            Caption = 'Name';
        }
        field(3;"Data Type";Option)
        {
            Caption = 'Data Type';
            OptionCaption = 'Text,Integer,Decimal,Date,Boolean,Option';
            OptionMembers = Text,"Integer",Decimal,Date,Boolean,Option;

            trigger OnValidate()
            begin
                ApplyDefaultValue();
            end;
        }
        field(4;"Default Value";Text[250])
        {
            Caption = 'Default Value';

            trigger OnValidate()
            begin
                ValidateDefaultValue();
            end;
        }
        field(5;Options;Text[250])
        {
            Caption = 'Options';

            trigger OnValidate()
            begin
                ValidateOptions(0);
            end;
        }
    }

    keys
    {
        key(Key1;"POS Action Code",Name)
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

    local procedure ApplyDefaultValue()
    begin
        if not ValidateDefaultValue() then
          case "Data Type" of
            "Data Type"::Boolean:
              "Default Value" := Format(false,0,9);
            "Data Type"::Integer, "Data Type"::Decimal:
              "Default Value" := Format(0,0,9);
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
                Evaluate(Boolean,"Default Value",9):
                  "Default Value" := Format(Boolean,0,9);
                Evaluate(Boolean,"Default Value"):
                  "Default Value" := Format(Boolean,0,9);
                UpperCase("Default Value") = UpperCase(BoolYes):
                  "Default Value" := Format(true,0,9);
                UpperCase("Default Value") = UpperCase(BoolNo):
                  "Default Value" := Format(false,0,9);
                else
                  FieldError("Default Value",StrSubstNo(FieldErrorBase,"Data Type"));
              end;
            end;
          "Data Type"::Date:
            case true of
              Evaluate(Date,"Default Value",9):
                "Default Value":= Format(Date,0,9);
              Evaluate(Date,"Default Value"):
                "Default Value" := Format(Date,0,9);
              else
                FieldError("Default Value",StrSubstNo(FieldErrorBase,"Data Type"));
            end;
          "Data Type"::Integer:
            case true of
              Evaluate(Integer,"Default Value",9):
                "Default Value":= Format(Integer,0,9);
              Evaluate(Integer,"Default Value"):
                "Default Value" := Format(Integer,0,9);
              else
                FieldError("Default Value",StrSubstNo(FieldErrorBase,"Data Type"));
            end;
          "Data Type"::Decimal:
            case true of
              Evaluate(Decimal,"Default Value",9):
                "Default Value":= Format(Decimal,0,9);
              Evaluate(Decimal,"Default Value"):
                "Default Value" := Format(Decimal,0,9);
              else
                FieldError("Default Value",StrSubstNo(FieldErrorBase,"Data Type"));
            end;
          "Data Type"::Option:
            case true of
              "Default Value" = '':
                "Default Value":= GetDefaultOptionString();
              Evaluate(Integer,"Default Value"):
                "Default Value" := GetOptionString(Integer);
              GetOptionInt("Default Value") >= 0:
                exit;
              else
                FieldError("Default Value",StrSubstNo(FieldErrorOption,"Default Value"));
            end;
        end;
    end;

    local procedure ValidateOptions(Ordinal: Integer)
    begin
        if GetOptionInt("Default Value") = -1 then
          "Default Value" := GetDefaultOptionString();
    end;

    procedure GetOptionInt(Value: Text) Result: Integer
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        //-NPR5.40 [307453]
        // POSActionParamMgt.SplitString(Options,Parts);
        // FOREACH Part IN Parts DO BEGIN
        //  IF (Part = Value) AND (Part <> '') THEN
        //    EXIT;
        //  Result += 1;
        // END;
        // EXIT(-1);
        exit(TypeHelper.GetOptionNo(Value,Options));
        //+NPR5.40 [307453]
    end;

    procedure GetOptionString(Ordinal: Integer): Text
    var
        OptionOut: Text;
    begin
        //-NPR5.40 [307453]
        // POSActionParamMgt.SplitString(Options,Parts);
        // IF (Ordinal >= 0) AND (Ordinal < Parts.Length) THEN
        //  EXIT(Parts.GetValue(Ordinal))
        // ELSE
        //  EXIT(FORMAT(Ordinal));

        if TrySelectStr(Ordinal, OptionOut) then
          exit(OptionOut)
        else
          exit(Format(Ordinal));
        //+NPR5.40 [307453]
    end;

    local procedure GetDefaultOptionString(): Text
    var
        OptionOut: Text;
    begin
        //-NPR5.40 [307453]
        // POSActionParamMgt.SplitString(Options,Parts);
        // FOREACH Part IN Parts DO
        //  IF Part <> '' THEN
        //    EXIT(Part);

        if TrySelectStr(1, OptionOut) then
          exit(OptionOut);
        //+NPR5.40 [307453]
    end;

    procedure GetOptionsDictionary(var OptionsDict: DotNet Dictionary_Of_T_U)
    var
        POSActionParamMgt: Codeunit "POS Action Parameter Mgt.";
        Parts: DotNet Array;
        "Part": Text;
        Ordinal: Integer;
    begin
        OptionsDict := OptionsDict.Dictionary();
        POSActionParamMgt.SplitString(Options,Parts);
        foreach Part in Parts do begin
          if (Part <> '') then
            OptionsDict.Add(Part,Ordinal);
          Ordinal += 1;
        end;
    end;

    [TryFunction]
    local procedure TrySelectStr(Ordinal: Integer;var OptionOut: Text)
    begin
        //-NPR5.40 [307453]
        OptionOut := SelectStr(Ordinal + 1, Options);
        //+NPR5.40 [307453]
    end;
}

