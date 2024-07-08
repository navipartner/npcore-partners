table 6150724 "NPR CRO Payment Method Mapping"
{
    Access = Internal;
    Caption = 'CRO Payment Method Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR CRO Payment Method Mapping";
    LookupPageId = "NPR CRO Payment Method Mapping";

    fields
    {
        field(1; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";
        }
        field(2; "CRO Payment Method"; Enum "NPR CRO Payment Method")
        {
            Caption = 'CRO Payment Method';
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