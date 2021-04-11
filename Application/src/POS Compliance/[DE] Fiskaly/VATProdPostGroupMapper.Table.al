table 6014534 "NPR VAT Prod Post Group Mapper"
{
    Caption = 'VAT Product Posting Group Mapper';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "VAT Prod. Pos. Group"; Code[20])
        {
            Caption = 'VAT Product Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group".Code;
        }
        field(10; "Fiscal Name"; Code[50])
        {
            Caption = 'Fiscal Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "VAT Prod. Pos. Group")
        {
            Clustered = true;
        }
    }
}