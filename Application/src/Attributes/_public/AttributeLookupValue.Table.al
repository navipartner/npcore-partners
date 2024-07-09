table 6014557 "NPR Attribute Lookup Value"
{
    Access = Public;
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
        field(800; "HeyLoyalty Value"; Text[50])
        {
            Caption = 'HeyLoyalty Value';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'HeyLoyalty values are now stored in a dedicated mapping table 6059839 "NPR HL Mapped Value".';
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
