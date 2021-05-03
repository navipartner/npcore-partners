table 6150715 "NPR POS Unit Identity"
{
    // #Transcendence/TSA/20170221 CASE Trancendence Login

    Caption = 'POS Unit Identity';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Device ID"; Text[50])
        {
            Caption = 'Device ID';
            DataClassification = CustomerContent;
        }
        field(15; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(20; "Default POS Unit No."; Code[10])
        {
            Caption = 'Default POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(25; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "Host Name"; Text[100])
        {
            Caption = 'Host Name';
            DataClassification = CustomerContent;
        }
        field(35; "Session Type"; Option)
        {
            Caption = 'Session Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Local,Remote Desktop,Citrix';
            OptionMembers = "Local",RemoteDesktop,Citrix;
        }
        field(40; "Select POS Using"; Option)
        {
            Caption = 'Select POS Using';
            DataClassification = CustomerContent;
            OptionCaption = 'Device ID,User ID';
            OptionMembers = DeviceID,UserID;
        }
        field(100; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(110; "Last Session At"; DateTime)
        {
            Caption = 'Last Session At';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Device ID")
        {
        }
    }

    fieldgroups
    {
    }
}

