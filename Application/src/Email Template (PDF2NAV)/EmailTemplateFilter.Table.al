﻿table 6014464 "NPR E-mail Template Filter"
{
    Access = Internal;
    Caption = 'E-mail Template Filter';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "E-mail Template Code"; Code[20])
        {
            Caption = 'E-mail Template Code';
            TableRelation = "NPR E-mail Template Header";
            DataClassification = CustomerContent;
        }
        field(3; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(8; "Field No."; Integer)
        {
            Caption = 'Field No.';
            TableRelation = Field."No." where(TableNo = field("Table No."));
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                Field.FilterGroup(2);
                Field.SetRange(TableNo, "Table No.");
                Field.FilterGroup(0);
                if Page.RunModal(Page::"NPR Field Lookup", Field) = Action::LookupOK then
                    "Field No." := Field."No.";
            end;
        }
        field(9; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
        field(10; "Field Name"; Text[30])
        {
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Table No."),
                                                        "No." = field("Field No.")));
            Caption = 'Field Name';
            Description = 'PN1.07,PN1.08';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "E-mail Template Code", "Table No.", "Line No.")
        {
        }
    }
}

