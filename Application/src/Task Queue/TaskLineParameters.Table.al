table 6059909 "NPR Task Line Parameters"
{
    Access = Internal;
    // TQ1.24/JDH/20150320 CASE 208247 Added Captions
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue

    Caption = 'Task Line Parameters';
    DrillDownPageID = "NPR Task Line Parameters";
    LookupPageID = "NPR Task Line Parameters";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "NPR Task Line"."Journal Template Name";
            DataClassification = CustomerContent;
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "NPR Task Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
            DataClassification = CustomerContent;
        }
        field(3; "Journal Line No."; Integer)
        {
            Caption = 'Journal Line No.';
            TableRelation = "NPR Task Line"."Line No." WHERE("Journal Template Name" = FIELD("Journal Template Name"),
                                                          "Journal Batch Name" = FIELD("Journal Batch Name"));
            DataClassification = CustomerContent;
        }
        field(4; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(9; "Field Code"; Code[20])
        {
            Caption = 'Field Code';
            DataClassification = CustomerContent;
        }
        field(10; "Field Type"; Option)
        {
            Caption = 'Field Type';
            OptionCaption = 'Text,Date,Time,DateTime,Integer,Decimal,Boolean,DateFormula';
            OptionMembers = Text,Date,Time,DateTime,"Integer",Decimal,Boolean,DateFormula;
            DataClassification = CustomerContent;
        }
        field(11; "Text Sub Type"; Option)
        {
            Caption = 'Text Sub Type';
            OptionCaption = ' ,E-mail Address,Password';
            OptionMembers = " ",EmailAddress,Password;
            DataClassification = CustomerContent;
        }
        field(20; Value; Text[250])
        {
            Caption = 'Text Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                case "Field Type" of
                    "Field Type"::Text:
                        begin
                            case "Text Sub Type" of
                                "Text Sub Type"::EmailAddress:
                                    begin
                                        CheckValidEmailAddress(Value);
                                    end;
                            end;
                        end;
                    "Field Type"::Date:
                        begin
                            Evaluate("Date Value", Value);
                            Value := Format("Date Value");
                        end;
                    "Field Type"::Time:
                        begin
                            Evaluate("Time Value", Value);
                            Value := Format("Time Value");
                        end;
                    "Field Type"::Integer:
                        begin
                            Evaluate("Integer Value", Value);
                            Value := Format("Integer Value");
                        end;
                    "Field Type"::Decimal:
                        begin
                            Evaluate("Decimal Value", Value);
                            Value := Format("Decimal Value");
                        end;
                    "Field Type"::Boolean:
                        begin
                            Evaluate("Boolean Value", Value);
                            Value := Format("Boolean Value");
                        end;
                    "Field Type"::DateFormula:
                        begin
                            Evaluate("Date Formula", Value);
                            Value := Format("Date Formula");
                        end;
                end;
            end;
        }
        field(21; "Date Value"; Date)
        {
            Caption = 'Date Value';
            DataClassification = CustomerContent;
        }
        field(22; "Time Value"; Time)
        {
            Caption = 'Time Value';
            DataClassification = CustomerContent;
        }
        field(23; "DateTime Value"; DateTime)
        {
            Caption = 'DateTime Value';
            DataClassification = CustomerContent;
        }
        field(24; "Integer Value"; Integer)
        {
            Caption = 'Integer Value';
            DataClassification = CustomerContent;
        }
        field(25; "Decimal Value"; Decimal)
        {
            Caption = 'Decimal Value';
            DataClassification = CustomerContent;
        }
        field(26; "Boolean Value"; Boolean)
        {
            Caption = 'Boolean Value';
            DataClassification = CustomerContent;
        }
        field(27; "Date Formula"; DateFormula)
        {
            Caption = 'Date Formula';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Journal Line No.", "Field No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'The email address "%1" is invalid.';

    procedure LookupValue(TaskLine: Record "NPR Task Line"; "FieldNo.": Integer)
    begin
        SetRange("Journal Template Name", TaskLine."Journal Template Name");
        SetRange("Journal Batch Name", TaskLine."Journal Batch Name");
        SetRange("Journal Line No.", TaskLine."Line No.");
        SetRange("Field No.", "FieldNo.");
        PAGE.RunModal(0, Rec);
    end;

    procedure InitLine()
    begin
        case "Field No." of
            171:
                begin
                    "Field Code" := 'E-Mail On Start';
                    "Text Sub Type" := "Text Sub Type"::EmailAddress;
                end;
            176:
                begin
                    "Field Code" := 'E-Mail On Error';
                    "Text Sub Type" := "Text Sub Type"::EmailAddress;
                end;
            181:
                begin
                    "Field Code" := 'E-Mail On Succes';
                    "Text Sub Type" := "Text Sub Type"::EmailAddress;
                end;
            185:
                begin
                    "Field Code" := 'E-Mail On Run';
                    "Text Sub Type" := "Text Sub Type"::EmailAddress;
                end;
            186:
                begin
                    "Field Code" := 'E-Mail On Run CC';
                    "Text Sub Type" := "Text Sub Type"::EmailAddress;
                end;
            187:
                begin
                    "Field Code" := 'E-Mail On Run BCC';
                    "Text Sub Type" := "Text Sub Type"::EmailAddress;
                end;
        end;
    end;

    procedure LineIsEditable(): Boolean
    var
        TaskLine: Record "NPR Task Line";
    begin
        if not TaskLine.Get("Journal Template Name", "Journal Batch Name", "Journal Line No.") then
            exit(true);

        case "Field No." of
            171:
                exit(TaskLine."Send E-Mail (On Start)");
            176:
                exit(TaskLine."Send E-Mail (On Error)");
            181:
                exit(TaskLine."Send E-Mail (On Success)");
            185, 186, 187:
                exit(TaskLine."Call Object With Task Record");
        end;

        exit(TaskLine."Call Object With Task Record");
    end;

    local procedure CheckValidEmailAddress(EmailAddress: Text[250])
    var
        i: Integer;
        NoOfAtSigns: Integer;
    begin
        if EmailAddress = '' then
            Error(Text001, EmailAddress);

        if (EmailAddress[1] = '@') or (EmailAddress[StrLen(EmailAddress)] = '@') then
            Error(Text001, EmailAddress);

        for i := 1 to StrLen(EmailAddress) do begin
            if EmailAddress[i] = '@' then
                NoOfAtSigns := NoOfAtSigns + 1;
            if not (
              ((EmailAddress[i] >= 'a') and (EmailAddress[i] <= 'z')) or
              ((EmailAddress[i] >= 'A') and (EmailAddress[i] <= 'Z')) or
              ((EmailAddress[i] >= '0') and (EmailAddress[i] <= '9')) or
              (EmailAddress[i] in ['@', '.', '-', '_']))
            then
                Error(Text001, EmailAddress);
        end;

        if NoOfAtSigns <> 1 then
            Error(Text001, EmailAddress);
    end;

    procedure FormatValueField()
    begin
        //-TQ1.17
        case "Field Type" of
            "Field Type"::Date:
                Value := Format("Date Value");
            "Field Type"::Time:
                Value := Format("Time Value");
            "Field Type"::DateTime:
                Value := Format("DateTime Value");
            "Field Type"::Integer:
                Value := Format("Integer Value");
            "Field Type"::Decimal:
                Value := Format("Decimal Value");
            "Field Type"::Boolean:
                Value := Format("Boolean Value");
            "Field Type"::DateFormula:
                Value := Format("Date Formula");
        end;
        //+TQ1.17
    end;
}

