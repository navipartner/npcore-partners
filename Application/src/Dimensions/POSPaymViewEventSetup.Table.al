table 6151054 "NPR POS Paym. View Event Setup"
{
    Access = Internal;
    Caption = 'POS Payment View Event Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Dimension Popup Enabled"; Boolean)
        {
            Caption = 'Dimension Popup Enabled';
            DataClassification = CustomerContent;
        }
        field(15; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code';
            DataClassification = CustomerContent;
            TableRelation = Dimension;
        }
        field(20; "Popup per"; Option)
        {
            Caption = 'Popup per';
            DataClassification = CustomerContent;
            OptionCaption = 'All,POS Store,POS Unit';
            OptionMembers = All,"POS Store","POS Unit";
        }
        field(30; "Popup every"; Integer)
        {
            BlankZero = true;
            Caption = 'Popup every';
            DataClassification = CustomerContent;
            MinValue = 1;
            InitValue = 1;
        }
        field(40; "Popup Start Time"; Time)
        {
            Caption = 'Popup Start Time';
            DataClassification = CustomerContent;
        }
        field(50; "Popup End Time"; Time)
        {
            Caption = 'Popup End Time';
            DataClassification = CustomerContent;
        }
        field(60; "Popup Mode"; Option)
        {
            Caption = 'Dimension Popup Mode';
            DataClassification = CustomerContent;
            OptionCaption = 'List,Numpad,Input';
            OptionMembers = List,Numpad,Input;
        }
        field(70; "Create New Dimension Values"; Boolean)
        {
            Caption = 'Create New Dimension Values';
            DataClassification = CustomerContent;
        }
        field(80; "Skip Popup on Dimension Value"; Boolean)
        {
            Caption = 'Skip Popup on Dimension Value';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
        }
        field(90; "Enable Selected POS Units"; Boolean)
        {
            Caption = 'Show Only for Selected POS Units';
            DataClassification = CustomerContent;
        }
        field(100; "Dimension Mandatory on POS"; Boolean)
        {
            Caption = 'Dimension Mandatory on POS';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}

