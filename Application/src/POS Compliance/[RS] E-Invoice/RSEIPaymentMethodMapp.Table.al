table 6150824 "NPR RS EI Payment Method Mapp."
{
    Access = Internal;
    Caption = 'RS E-Invoice Payment Method Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RS EI Payment Method Mapp.";
    LookupPageId = "NPR RS EI Payment Method Mapp.";

    fields
    {
        field(1; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
            DataClassification = CustomerContent;
        }
        field(2; "RS EI Payment Means"; Enum "NPR RS EI Payment Means")
        {
            Caption = 'RS EI Payment Means';
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