table 6059818 "NPR RS POS Paym. Meth. Mapping"
{
    Access = Internal;
    Caption = 'RS POS Paymnet Method Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RS POS Paym. Meth. Mapping";
    LookupPageId = "NPR RS POS Paym. Meth. Mapping";

    fields
    {
        field(1; "POS Payment Method Code"; Code[10])
        {
            Caption = 'POS Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(5; "RS Payment Method"; Enum "NPR RS Payment Method")
        {
            Caption = 'RS Payment Method';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Payment Method Code")
        {
            Clustered = true;
        }
    }
}