table 6059849 "NPR HL MultiChoice Field"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
    Caption = 'HL Multi-Choice Field';
    DataClassification = CustomerContent;
    LookupPageId = "NPR HL MultiChoice Fields";
    DrillDownPageId = "NPR HL MultiChoice Fields";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Magento Field Name"; Text[100])
        {
            Caption = 'Magento Field Name';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
        key(Magento; "Magento Field Name") { }
    }
}
