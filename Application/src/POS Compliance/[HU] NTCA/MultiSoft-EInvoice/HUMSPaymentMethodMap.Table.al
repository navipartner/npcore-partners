table 6150761 "NPR HU MS Payment Method Map."
{
    Access = Internal;
    Caption = 'HU Payment Method Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR HU MS Payment Method Map.";
    LookupPageId = "NPR HU MS Payment Method Map.";

    fields
    {
        field(1; "Payment Method"; Code[10])
        {
            Caption = 'Payment Method';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";
        }
        field(5; Cash; Boolean)
        {
            Caption = 'Cash';
            DataClassification = CustomerContent;
        }
        field(6; Card; Boolean)
        {
            Caption = 'Card';
            DataClassification = CustomerContent;
        }
        field(7; Voucher; Boolean)
        {
            Caption = 'Voucher';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Payment Method")
        {
            Clustered = true;
        }
    }
}