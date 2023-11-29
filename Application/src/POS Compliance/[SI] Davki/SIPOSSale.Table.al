table 6060164 "NPR SI POS Sale"
{
    Access = Internal;
    Caption = 'SI POS Sale';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Sale SystemId"; Guid)
        {
            Caption = 'POS Sale SystemId';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Sale".SystemId;
        }
        field(2; "SI Set Number"; Code[20])
        {
            Caption = 'Set Number';
            DataClassification = CustomerContent;
        }
        field(3; "SI Serial Number"; Text[40])
        {
            Caption = 'Serial Number';
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