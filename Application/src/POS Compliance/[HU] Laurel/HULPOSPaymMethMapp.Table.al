table 6151116 "NPR HU L POS Paym. Meth. Mapp."
{
    Access = Internal;
    Caption = 'HU Laurel POS Payment Method Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR HU L POS Paym. Meth. Mapp.";
    LookupPageId = "NPR HU L POS Paym. Meth. Mapp.";

    fields
    {
        field(1; "POS Payment Method Code"; Code[10])
        {
            Caption = 'POS Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(2; "Payment Fiscal Type"; Enum "NPR HU L Payment Fiscal Type")
        {
            Caption = 'Payment Fiscal Type';
            DataClassification = CustomerContent;
        }
        field(3; "Payment Fiscal Subtype"; Enum "NPR HU L Paym. Fiscal Subtype")
        {
            Caption = 'Payment Fiscal Subtype';
            DataClassification = CustomerContent;
        }
        field(4; "Payment Currency Type"; Enum "NPR HU L Paym. Currency Type")
        {
            Caption = 'Payment Currency Type';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "POS Payment Method Code")
        {
            Clustered = true;
        }
    }
}