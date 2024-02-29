table 6059809 "NPR POS HTML Disp. Prof."
{
    DataClassification = CustomerContent;
    Access = Internal;
    Extensible = False;
    LookupPageId = "NPR POS HTML Disp. Prof. List";
    DrillDownPageId = "NPR POS HTML Disp. Prof. List";

    fields
    {
        field(1; "Code"; Code[40])
        {
            DataClassification = CustomerContent;
        }
        field(2; "HTML Blob"; Blob)
        {
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Display Content Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR Display Content";
        }
        field(5; "Ex. VAT"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(6; "CIO: Money Back"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "None","Phone & Signature";
            Caption = 'Customer Input Option: Money Back';
        }
        field(7; "Receipt Item Description"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "Item Description 1","Item Description 2";
            Caption = 'Receipt Item Description';
        }
        field(8; "MobilePay QR"; Boolean)
        {
            DataClassification = CustomerContent;
            InitValue = False;
            Caption = 'Show Vipps Mobilepay QR';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }


}