table 6150774 "NPR IT POS Sale"
{
    Access = Internal;
    Caption = 'IT POS Sale';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Sale SystemId"; Guid)
        {
            Caption = 'POS Sale SystemId';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Sale".SystemId;
        }
        field(10; "IT Customer Lottery Code"; Text[15])
        {
            Caption = 'Customer Lottery Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "POS Sale SystemId")
        {
            Clustered = true;
        }
    }
}