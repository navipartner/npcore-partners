table 6060039 "NPR CRO POS Paym. Method Mapp."
{
    Access = Internal;
    Caption = 'CRO POS Payment Method Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR CRO POS Paym. Method Mapp.";
    LookupPageId = "NPR CRO POS Paym. Method Mapp.";

    fields
    {
        field(1; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(2; "CRO Payment Method"; Enum "NPR CRO POS Payment Method")
        {
            Caption = 'CRO Payment Method';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR28.0';
            ObsoleteReason = 'Replaced by Payment Method field.';
        }
        field(3; "Payment Method"; Enum "NPR CRO Payment Method")
        {
            Caption = 'Payment Method';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Payment Method Code")
        {
            Clustered = true;
        }
    }
}