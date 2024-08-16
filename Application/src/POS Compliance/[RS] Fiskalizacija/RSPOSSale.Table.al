table 6059824 "NPR RS POS Sale"
{
    Access = Internal;
    Caption = 'RS POS Sale';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Sale SystemId"; Guid)
        {
            Caption = 'POS Sale SystemId';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Sale".SystemId;
        }
        field(10; "RS Customer Identification"; Code[20])
        {
            Caption = 'Customer Identification';
            DataClassification = CustomerContent;
        }
        field(15; "RS Add. Customer Field"; Code[20])
        {
            Caption = 'Additional Customer Field';
            DataClassification = CustomerContent;
        }
        field(20; "Return Reference No."; Code[100])
        {
            Caption = 'Return Reference No.';
            DataClassification = CustomerContent;
        }
        field(21; "Return Reference Date/Time"; Text[33])
        {
            Caption = 'Return Reference Date/Time';
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