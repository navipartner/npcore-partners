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
            Caption = 'SI Salesbook Set Number';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2024-12-29';
            ObsoleteReason = 'Field replaced by SI SB Set Number, field length decreased.';
        }
        field(3; "SI Serial Number"; Text[40])
        {
            Caption = 'SI Salesbook Serial Number';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2024-12-29';
            ObsoleteReason = 'Field replaced by SI SB Serial Number, field length decreased.';
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
        field(8; "SI SB Set Number"; Text[2])
        {
            Caption = 'SI Salesbook Set Number';
            DataClassification = CustomerContent;
        }
        field(9; "SI SB Serial Number"; Text[12])
        {
            Caption = 'SI Salesbook Serial Number';
            DataClassification = CustomerContent;
        }
        field(10; "SI SB Receipt No."; Code[20])
        {
            Caption = 'SI Salesbook Receipt No.';
            DataClassification = CustomerContent;
        }
        field(11; "SI SB Receipt Issue Date"; Date)
        {
            Caption = 'SI Salesbook Receipt Issue Date';
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