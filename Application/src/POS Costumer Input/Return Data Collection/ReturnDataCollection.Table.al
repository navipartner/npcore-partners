table 6059881 "NPR Return Data Collection"
{
    Access = Internal;
    Caption = 'Return Data Collection';
    DataClassification = CustomerContent;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-15';
    ObsoleteReason = 'Obsolete due to primary key changes. Use new Data Collection Buffer table instead.';

    fields
    {
        field(1; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(10; "Signature Data"; Blob)
        {
            Caption = 'Signature Data';
            DataClassification = CustomerContent;
        }
        field(20; "Phone No."; Text[50])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(30; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Sales Ticket No.")
        {
            Clustered = true;
        }
    }
}
