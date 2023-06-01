table 88001 "NPR BCPT Voucher"
{
    Caption = 'BCPT Voucher';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Reference No."; Code[50])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
        }
        field(20; "In Use"; Boolean)
        {
            Caption = 'In Use';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Reference No.")
        {
            Clustered = true;
        }
        key(InUse; "In Use")
        {
        }
    }
}
