table 6014553 "NPR Attribute Translation"
{
    // NPRx.xx/TSA/22-04-15 CASE209946 - Entity and Shortcut Attributes

    Caption = 'Attribute Translation';
    DrillDownPageID = "NPR Attribute Translations";
    LookupPageID = "NPR Attribute Translations";

    fields
    {
        field(1; "Attribute Code"; Code[20])
        {
            Caption = 'Attribute Code';
            TableRelation = "NPR Attribute".Code;
        }
        field(2; "Language ID"; Integer)
        {
            Caption = 'Language ID';
            TableRelation = "Windows Language";
        }
        field(10; Name; Text[30])
        {
            Caption = 'Name';
        }
        field(11; "Code Caption"; Text[30])
        {
            Caption = 'Code Caption';
        }
        field(12; "Filter Caption"; Text[30])
        {
            Caption = 'Filter Caption';
        }
    }

    keys
    {
        key(Key1; "Attribute Code", "Language ID")
        {
        }
    }

    fieldgroups
    {
    }
}

