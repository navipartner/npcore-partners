table 6014533 "NPR Payment Method Mapper"
{
    Caption = 'Payment Method Mapper';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Payment Method"; Code[10])
        {
            Caption = 'POS Payment Method';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method".Code;
        }
        field(10; "Fiscal Name"; Code[50])
        {
            Caption = 'Fiscal Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "POS Payment Method")
        {
            Clustered = true;
        }
    }
}