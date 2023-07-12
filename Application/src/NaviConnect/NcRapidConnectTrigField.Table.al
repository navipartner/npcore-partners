﻿table 6151093 "NPR Nc RapidConnect Trig.Field"
{
    Access = Internal;
    Caption = 'Nc RapidConnect Trigger Field';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Not used - Inter-company synchronizations will happen via the API replication module';

    fields
    {
        field(1; "Setup Code"; Code[20])
        {
            Caption = 'Setup Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; "Field No."; Integer)
        {
            BlankZero = true;
            Caption = 'Field No.';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                Field.SetRange(TableNo, "Table ID");
                if PAGE.RunModal(PAGE::"NPR Field Lookup", Field) = ACTION::LookupOK then
                    "Field No." := Field."No.";

                CalcFields("Field Name");
            end;

            trigger OnValidate()
            begin
                CalcFields("Field Name");
            end;
        }
        field(15; "Field Name"; Text[50])
        {
            CalcFormula = Lookup(Field.FieldName WHERE(TableNo = FIELD("Table ID"),
                                                        "No." = FIELD("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            begin
            end;
        }
    }

    keys
    {
        key(Key1; "Setup Code", "Table ID", "Field No.")
        {
        }
    }
}

