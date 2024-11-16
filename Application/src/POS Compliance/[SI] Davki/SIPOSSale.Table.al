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
        field(4; "SI Return Receipt No."; Code[20])
        {
            Caption = 'SI Return Receipt No.';
            DataClassification = CustomerContent;
        }
        field(5; "SI Return Bus. Premise ID"; Code[20])
        {
            Caption = 'SI Return Business Premise ID';
            DataClassification = CustomerContent;
        }
        field(6; "SI Return Cash Register ID"; Code[20])
        {
            Caption = 'SI Return Cash Register ID';
            DataClassification = CustomerContent;
        }
        field(7; "SI Return Receipt DateTime"; Text[33])
        {
            Caption = 'SI Return Receipt Date/Time';
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