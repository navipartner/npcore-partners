table 6184871 "NPR DropBox Overview"
{
    Access = Internal;
    Caption = 'DropBox Overview';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "Account Code"; Code[10])
        {
            Caption = 'DropBox Account Code';
            DataClassification = CustomerContent;
        }
        field(10; "File Name"; Text[250])
        {
            Caption = 'File Name';
            DataClassification = CustomerContent;
        }
        field(20; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Account Code", "File Name", Name)
        {
        }
    }

    fieldgroups
    {
    }
}

