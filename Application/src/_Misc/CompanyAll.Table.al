table 6014441 "NPR Company All"
{
    Caption = 'Company All';
    DataPerCompany = false;
    DataClassification = CustomerContent;
    ObsoleteState = Removed;

    fields
    {
        field(1; Company; Text[50])
        {
            Caption = 'Company';
            DataClassification = CustomerContent;
        }
        field(2; Afdeling; Code[10])
        {
            Caption = 'Department';
            DataClassification = CustomerContent;
        }
        field(3; "npc - Company No."; Code[20])
        {
            Caption = 'Company No.';
            DataClassification = CustomerContent;
        }
        field(4; "icomm - NAS Enabled"; Boolean)
        {
            Caption = 'iComm - NAS Enabled';
            DataClassification = CustomerContent;
        }
        field(5; "npc - Sales posting"; Boolean)
        {
            Caption = 'NPC - Sales Posting';
            DataClassification = CustomerContent;
        }
        field(6; "npc - Immediate postings"; Option)
        {
            Caption = 'Immediate posting';
            OptionCaption = ' ,Serial no.,Always';
            OptionMembers = " ","Serial no.",Always;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Company, Afdeling)
        {
        }
    }
}

