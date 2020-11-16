table 6184493 "NPR Pepper Terminal Type"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.25/BR/20160509  CASE 231481 Added field Force Fixed Currency Check.

    Caption = 'Pepper Terminal Type';
    DataClassification = CustomerContent;
    DataCaptionFields = ID, Description;
    DrillDownPageID = "NPR Pepper Terminal Types";
    LookupPageID = "NPR Pepper Terminal Types";

    fields
    {
        field(10; ID; Integer)
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Active then
                    TestField(Deprecated, false);
            end;
        }
        field(40; Deprecated; Boolean)
        {
            Caption = 'Deprecated';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Deprecated then
                    TestField(Active, false);
            end;
        }
        field(200; Overtender; Boolean)
        {
            Caption = 'Overtender';
            DataClassification = CustomerContent;
        }
        field(250; "Force Fixed Currency Check"; Boolean)
        {
            Caption = 'Force Fixed Currency Check';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; ID)
        {
        }
    }

    fieldgroups
    {
    }
}

