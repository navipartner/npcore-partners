table 6184515 "NPR EFT Verifone Unit Param."
{
    Access = Internal;
    // NPR5.53/MMV /20191204 CASE 349520 Added object

    Caption = 'EFT Verifone Unit Parameter';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Unit"; Code[10])
        {
            Caption = 'POS Unit';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(10; "Terminal Serial Number"; Text[50])
        {
            Caption = 'Terminal Serial Number';
            DataClassification = CustomerContent;
        }
        field(20; "Terminal LAN Address"; Text[30])
        {
            Caption = 'Terminal LAN Address';
            DataClassification = CustomerContent;
        }
        field(30; "Terminal LAN Port"; Integer)
        {
            Caption = 'Terminal LAN Port';
            DataClassification = CustomerContent;
        }
        field(40; "Terminal Connection Mode"; Option)
        {
            Caption = 'Terminal Connection Mode';
            DataClassification = CustomerContent;
            OptionCaption = 'Terminal Connect,ECR Connect';
            OptionMembers = TERMINAL_CONNECT,ECR_CONNECT;
        }
        field(50; "Terminal Log Location"; Text[250])
        {
            Caption = 'Terminal Log Location';
            DataClassification = CustomerContent;
            InitValue = 'C:\Verifone\';
        }
        field(60; "Terminal Log Level"; Option)
        {
            Caption = 'Terminal Log Level';
            DataClassification = CustomerContent;
            OptionCaption = 'All,Debug,Error,Info,Trace,Warn';
            OptionMembers = ALL,DEBUG,ERROR,INFO,TRACE,WARN;
        }
        field(70; "Terminal Listening Port"; Integer)
        {
            Caption = 'Terminal Listening Port';
            DataClassification = CustomerContent;
            InitValue = 9600;
        }
        field(80; "Terminal Connection Type"; Option)
        {
            Caption = 'Terminal Connection Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Ethernet,USB';
            OptionMembers = Ethernet,USB;
        }
        field(90; "Terminal Default Language"; Option)
        {
            Caption = 'Terminal Default Language';
            DataClassification = CustomerContent;
            OptionCaption = 'English,Danish,Swedish,Finnish,Norwegian';
            OptionMembers = ENGLISH,DANISH,SWEDISH,FINNISH,NORWEGIAN;
        }
        field(100; "Auto Close Terminal on EOD"; Boolean)
        {
            Caption = 'Auto Close Terminal on EOD';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(110; "Auto Open on Transaction"; Boolean)
        {
            Caption = 'Auto Open on Transaction';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(120; "Auto Login After Reconnect"; Boolean)
        {
            Caption = 'Auto Login After Reconnect';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(130; "Auto Reconcile on Close"; Boolean)
        {
            Caption = 'Auto Reconcile on Close';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Unit")
        {
        }
    }

    fieldgroups
    {
    }
}

