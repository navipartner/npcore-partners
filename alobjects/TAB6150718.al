table 6150718 "POS Unit Identity Wizard"
{
    // #Transcendence/TSA/20170221 CASE Trancendence Login

    Caption = 'POS Unit Identity';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10;"Device ID";Text[50])
        {
            Caption = 'Device ID';
        }
        field(15;"User ID";Code[50])
        {
            Caption = 'User ID';
        }
        field(20;"Default POS Unit No.";Code[10])
        {
            Caption = 'Default POS Unit No.';
            TableRelation = "POS Unit";
        }
        field(25;Description;Text[80])
        {
            Caption = 'Description';
        }
        field(30;"Host Name";Text[100])
        {
            Caption = 'Host Name';
        }
        field(35;"Session Type";Option)
        {
            Caption = 'Session Type';
            OptionCaption = 'Local,Remote Desktop,Citrix';
            OptionMembers = "Local",RemoteDesktop,Citrix;
        }
        field(40;"Select POS Using";Option)
        {
            Caption = 'Select POS Using';
            OptionCaption = 'Device ID,User ID';
            OptionMembers = DeviceID,UserID;
        }
        field(100;"Created At";DateTime)
        {
            Caption = 'Created At';
        }
        field(110;"Last Session At";DateTime)
        {
            Caption = 'Last Session At';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Device ID")
        {
        }
    }

    fieldgroups
    {
    }
}

