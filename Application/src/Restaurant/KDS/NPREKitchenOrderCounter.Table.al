table 6060073 "NPR NPRE Kitchen Order Counter"
{
    Access = Internal;
    Caption = 'Kitchen Order Counter';
    DataClassification = CustomerContent;
    Extensible = false;

    fields
    {
        field(1; "Restaurant Code"; Code[20])
        {
            Caption = 'Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Restaurant";
        }
        field(2; "Last Display Order No."; Integer)
        {
            Caption = 'Last Display Order No.';
            DataClassification = CustomerContent;
        }
        field(3; "Last Display Order Date"; Date)
        {
            Caption = 'Last Display Order Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Restaurant Code")
        {
            Clustered = true;
        }
    }
}
