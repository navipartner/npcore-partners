table 6150836 "NPR RS EI Doc. Tax Exemption"
{
    Access = Internal;
    Caption = 'RS EI Document Tax Exemption';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RS EI Doc. Tax Exemption";
    LookupPageId = "NPR RS EI Doc. Tax Exemption";

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(2; "Tax Category"; Enum "NPR RS EI Allowed Tax Categ.")
        {
            Caption = 'Tax Category';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(3; "Tax Exemption Reason Code"; Code[20])
        {
            Caption = 'Tax Exemption Reason Code';
            TableRelation = "NPR RS EI Tax Exemption Reason"."Tax Exemption Reason Code";
            DataClassification = CustomerContent;
        }
        field(4; "Tax Exemption Reason Text"; Text[400])
        {
            Caption = 'Tax Exemption Reason Text';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Document No.", "Tax Category") { }
    }
}