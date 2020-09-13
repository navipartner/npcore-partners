table 6014557 "NPR Attribute Lookup Value"
{
    // NPRx.xx/TSA/22-04-15 CASE209946 - Entity and Shortcut Attributes

    Caption = 'Attribute Code Lookup Value';
    DrillDownPageID = "NPR Attribute Value Lookup";
    LookupPageID = "NPR Attribute Value Lookup";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Attribute Code"; Code[20])
        {
            Caption = 'Attribute Code';
            TableRelation = "NPR Attribute".Code;
            DataClassification = CustomerContent;
        }
        field(2; "Attribute Value Code"; Code[20])
        {
            Caption = 'Attribute Value Code';
            DataClassification = CustomerContent;
        }
        field(10; "Attribute Value Name"; Text[100])
        {
            Caption = 'Attribute Value Name';
            DataClassification = CustomerContent;
        }
        field(12; "Attribute Value Description"; Text[100])
        {
            Caption = 'Attribute Value Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Attribute Code", "Attribute Value Code")
        {
        }
    }

    fieldgroups
    {
    }
}

