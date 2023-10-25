table 6060100 "NPR CRO POS Sale"
{
    Access = Internal;
    Caption = 'CRO POS Sale';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Sale SystemId"; Guid)
        {
            Caption = 'POS Sale SystemId';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Sale".SystemId;
        }
        field(2; "CRO Paragon Number"; Text[40])
        {
            Caption = 'Paragon Number';
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