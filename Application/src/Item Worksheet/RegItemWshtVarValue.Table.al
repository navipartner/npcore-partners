﻿table 6060048 "NPR Reg. Item Wsht Var. Value"
{
    Access = Internal;
    Caption = 'Reg. Item Wsht Variety Value';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Registered Worksheet No."; Integer)
        {
            Caption = 'Registered Worksheet No.';
            DataClassification = CustomerContent;
        }
        field(3; "Registered Worksheet Line No."; Integer)
        {
            Caption = 'Registered Worksheet Line No.';
            DataClassification = CustomerContent;
        }
        field(4; Type; Code[10])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Variety";
        }
        field(5; "Table"; Code[20])
        {
            Caption = 'Table';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(6; Value; Code[50])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnValidate()
            begin
                if Description = '' then begin
                    if StrLen(Value) = 1 then
                        Description := CopyStr(Value, 1, MaxStrLen(Description))
                    else
                        Description := CopyStr(CopyStr(Value, 1, 1) + LowerCase(CopyStr(Value, 2)), 1, MaxStrLen(Description));
                end;
            end;
        }
        field(10; "Sort Order"; Integer)
        {
            Caption = 'Sort Order';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Registered Worksheet No.", "Registered Worksheet Line No.", Type, "Table", Value)
        {
        }
        key(Key2; "Registered Worksheet Line No.", Type, "Sort Order")
        {
        }
        key(Key3; "Registered Worksheet No.", "Registered Worksheet Line No.", Type, "Table", "Sort Order")
        {
        }
    }



    procedure GetDecimalSeperator(): Text[1]
    var
        Dec: Decimal;
    begin
        Dec := 1.2;
        if StrPos(Format(Dec), '.') <> 0 then
            exit('.')
        else
            exit(',');
    end;
}

