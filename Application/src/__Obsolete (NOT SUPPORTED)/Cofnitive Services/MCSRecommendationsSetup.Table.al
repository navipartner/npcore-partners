table 6060080 "NPR MCS Recommendations Setup"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'On February 15, 2018, “Recommendations API is no longer under active development”';
    Caption = 'MCS Recommendations Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Max. History Records per Call"; Integer)
        {
            Caption = 'Max. History Records per Call';
            DataClassification = CustomerContent;
            InitValue = 10000;
            MinValue = 500;
        }
        field(20; "Online Recommendations Model"; Code[10])
        {
            Caption = 'Online Recommendations Model';
            DataClassification = CustomerContent;
        }
        field(30; "Background Send POS Lines"; Boolean)
        {
            Caption = 'Background Send POS Lines';
            DataClassification = CustomerContent;
        }
        field(40; "Background Send Sales Lines"; Boolean)
        {
            Caption = 'Background Send Sales Lines';
            DataClassification = CustomerContent;
        }
        field(50; "Max. Rec. per Sales Document"; Integer)
        {
            Caption = 'Max. Rec. per Sales Document';
            DataClassification = CustomerContent;
            InitValue = 3;
            MinValue = 1;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}

