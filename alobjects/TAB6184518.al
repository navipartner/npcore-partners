table 6184518 "EFT NETS BAXI Payment Setup"
{
    // NPR5.54/JAKUBV/20200408  CASE 364340 Transport NPR5.54 - 8 April 2020

    Caption = 'EFT NETS BAXI Payment Setup';

    fields
    {
        field(1;"Payment Type POS";Code[10])
        {
            Caption = 'Payment Type POS';
            TableRelation = "Payment Type POS"."No.";
        }
        field(20;"Log File Path";Text[250])
        {
            Caption = 'Log File Path';
            InitValue = 'C:\NETS_BAXI\';
        }
        field(30;"Trace Level";Option)
        {
            Caption = 'Trace Level';
            InitValue = "ERROR+TRACE+DEBUG";
            OptionCaption = 'Off,Error,Error+Trace,Error+Trace+Debug';
            OptionMembers = OFF,ERROR,"ERROR+TRACE","ERROR+TRACE+DEBUG";
        }
        field(40;"Baud Rate";Integer)
        {
            Caption = 'Baud Rate';
            InitValue = 57600;
        }
        field(50;"COM Port";Integer)
        {
            Caption = 'COM Port';
            InitValue = 9;
        }
        field(60;"Host Environment";Option)
        {
            Caption = 'Host Environment';
            OptionCaption = 'Production,Test';
            OptionMembers = Production,Test;
        }
        field(70;"Cutter Support";Boolean)
        {
            Caption = 'Cutter Support';
            InitValue = true;
        }
        field(80;"Printer Width";Integer)
        {
            Caption = 'Printer Width';
            InitValue = 24;
        }
        field(90;"Display Width";Integer)
        {
            Caption = 'Display Width';
            InitValue = 20;
        }
        field(100;"Log Auto Delete Days";Integer)
        {
            Caption = 'Log Auto Delete Days';
            InitValue = 30;
        }
        field(110;"Socket Listener";Boolean)
        {
            Caption = 'Socket Listener';
            InitValue = true;
        }
        field(120;"Socket Listener Port";Integer)
        {
            Caption = 'Socket Listener Port';
            InitValue = 6001;
        }
        field(130;"Bluetooth Tunnel";Integer)
        {
            Caption = 'Bluetooth Tunnel';
        }
        field(140;"Link Control Timeout Seconds";Integer)
        {
            Caption = 'Link Control Timeout Seconds';
            InitValue = 7;
        }
        field(150;DCC;Boolean)
        {
            Caption = 'DCC';
        }
        field(160;"Force Offline";Boolean)
        {
            Caption = 'Force Offline';
        }
        field(200;"Auto Reconcile On EOD";Boolean)
        {
            Caption = 'Auto Reconcile On EOD';
            InitValue = true;
        }
        field(300;"Force Abort Minimum Seconds";Integer)
        {
            Caption = 'Force Abort Minimum Seconds';
            InitValue = 5;
        }
        field(310;"Administration Timeout Seconds";Integer)
        {
            Caption = 'Administration Timeout Seconds';
            InitValue = 60;
        }
        field(320;"Lookup Timeout Seconds";Integer)
        {
            Caption = 'Lookup Timeout Seconds';
            InitValue = 20;
        }
        field(330;"Open Timeout Seconds";Integer)
        {
            Caption = 'Open Timeout Seconds';
            InitValue = 20;
        }
        field(340;"Close Timeout Seconds";Integer)
        {
            Caption = 'Close Timeout Seconds';
            InitValue = 20;
        }
    }

    keys
    {
        key(Key1;"Payment Type POS")
        {
        }
    }

    fieldgroups
    {
    }
}

