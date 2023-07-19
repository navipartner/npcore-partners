table 6151062 "NPR Retail Replenishment Setup"
{
    Access = Internal;
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Retail Replenishment Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR24.0';
    ObsoleteReason = 'Retail Replenishment will no longer be supported';
    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; "Item Demand Calc. Codeunit"; Integer)
        {
            Caption = 'Item Demand Calc. Codeunit';
            DataClassification = CustomerContent;
        }
        field(20; "Default Transit Location"; Code[10])
        {
            Caption = 'Default Transit Location';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

