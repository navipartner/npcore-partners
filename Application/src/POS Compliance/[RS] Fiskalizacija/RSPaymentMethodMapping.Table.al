table 6059817 "NPR RS Payment Method Mapping"
{
    Access = Internal;
    Caption = 'RS Paymnet Method Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RS Payment Method Mapping";
    LookupPageId = "NPR RS Payment Method Mapping";

    fields
    {
        field(1; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";
        }
        field(5; "RS Payment Method"; Enum "NPR RS Payment Method")
        {
            Caption = 'RS Payment Method';
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