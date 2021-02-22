table 6184518 "NPR EFT NETS BAXI Paym. Setup"
{
    // NPR5.54/JAKUBV/20200408  CASE 364340 Transport NPR5.54 - 8 April 2020

    Caption = 'EFT NETS BAXI Payment Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Payment Type POS"; Code[10])
        {
            Caption = 'Payment Type POS';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method".Code;
        }
        field(20; "Log File Path"; Text[250])
        {
            Caption = 'Log File Path';
            DataClassification = CustomerContent;
            InitValue = 'C:\NETS_BAXI\';
        }
        field(30; "Trace Level"; Option)
        {
            Caption = 'Trace Level';
            DataClassification = CustomerContent;
            InitValue = "ERROR+TRACE+DEBUG";
            OptionCaption = 'Off,Error,Error+Trace,Error+Trace+Debug';
            OptionMembers = OFF,ERROR,"ERROR+TRACE","ERROR+TRACE+DEBUG";
        }
        field(40; "Baud Rate"; Integer)
        {
            Caption = 'Baud Rate';
            DataClassification = CustomerContent;
            InitValue = 57600;
        }
        field(50; "COM Port"; Integer)
        {
            Caption = 'COM Port';
            DataClassification = CustomerContent;
            InitValue = 9;
        }
        field(60; "Host Environment"; Option)
        {
            Caption = 'Host Environment';
            DataClassification = CustomerContent;
            OptionCaption = 'Production,Test';
            OptionMembers = Production,Test;
        }
        field(70; "Cutter Support"; Boolean)
        {
            Caption = 'Cutter Support';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(80; "Printer Width"; Integer)
        {
            Caption = 'Printer Width';
            DataClassification = CustomerContent;
            InitValue = 24;
        }
        field(90; "Display Width"; Integer)
        {
            Caption = 'Display Width';
            DataClassification = CustomerContent;
            InitValue = 20;
        }
        field(100; "Log Auto Delete Days"; Integer)
        {
            Caption = 'Log Auto Delete Days';
            DataClassification = CustomerContent;
            InitValue = 30;
        }
        field(110; "Socket Listener"; Boolean)
        {
            Caption = 'Socket Listener';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(120; "Socket Listener Port"; Integer)
        {
            Caption = 'Socket Listener Port';
            DataClassification = CustomerContent;
            InitValue = 6001;
        }
        field(130; "Bluetooth Tunnel"; Integer)
        {
            Caption = 'Bluetooth Tunnel';
            DataClassification = CustomerContent;
        }
        field(140; "Link Control Timeout Seconds"; Integer)
        {
            Caption = 'Link Control Timeout Seconds';
            DataClassification = CustomerContent;
            InitValue = 7;
        }
        field(150; DCC; Boolean)
        {
            Caption = 'DCC';
            DataClassification = CustomerContent;
        }
        field(160; "Force Offline"; Boolean)
        {
            Caption = 'Force Offline';
            DataClassification = CustomerContent;
        }
        field(200; "Auto Reconcile On EOD"; Boolean)
        {
            Caption = 'Auto Reconcile On EOD';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(300; "Force Abort Minimum Seconds"; Integer)
        {
            Caption = 'Force Abort Minimum Seconds';
            DataClassification = CustomerContent;
            InitValue = 5;
        }
        field(310; "Administration Timeout Seconds"; Integer)
        {
            Caption = 'Administration Timeout Seconds';
            DataClassification = CustomerContent;
            InitValue = 60;
        }
        field(320; "Lookup Timeout Seconds"; Integer)
        {
            Caption = 'Lookup Timeout Seconds';
            DataClassification = CustomerContent;
            InitValue = 20;
        }
        field(330; "Open Timeout Seconds"; Integer)
        {
            Caption = 'Open Timeout Seconds';
            DataClassification = CustomerContent;
            InitValue = 20;
        }
        field(340; "Close Timeout Seconds"; Integer)
        {
            Caption = 'Close Timeout Seconds';
            DataClassification = CustomerContent;
            InitValue = 20;
        }
    }

    keys
    {
        key(Key1; "Payment Type POS")
        {
        }
    }

    fieldgroups
    {
    }
}

