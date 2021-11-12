table 6014455 "NPR CleanCash Trans. Response"
{
    DataClassification = CustomerContent;
    Caption = 'CleanCash Trans. Response';

    fields
    {
        field(1; "Request Entry No."; Integer)
        {
            Caption = 'Request Entry No.';
            DataClassification = CustomerContent;
            Description = 'Links reponse to request';
        }

        field(2; "Response No."; Integer)
        {
            Caption = 'Response No.';
            DataClassification = CustomerContent;
            Description = 'Multiple transmissions attemps for request will get seperate response entries.';
        }

        field(10; "Response Datetime"; DateTime)
        {
            Caption = 'Response Datetime';
            DataClassification = CustomerContent;
            Description = 'When response was received.';
        }

        field(100; "CleanCash Firmware"; Text[50])
        {
            Caption = 'CleanCash Firmware';
            DataClassification = CustomerContent;
            Description = 'CleanCash firmware version number.';
        }

        field(110; "Installed Licenses"; Code[10])
        {
            Caption = 'Installed Licenses';
            DataClassification = CustomerContent;
            Description = 'Licenses installed in CleanCash. (maximum of four digits)';
        }

        field(120; "CleanCash Type"; Code[10])
        {
            Caption = 'CleanCash Type';
            DataClassification = CustomerContent;
            Description = 'CleanCash model';
        }

        field(200; "CleanCash Code"; Text[100])
        {
            Caption = 'CleanCash Code';
            DataClassification = CustomerContent;
            Description = 'A base-32 encoded string to be printed on the printer and stored in the POS terminal‟s journal. The total length of the control code is 59 characters. Note: This is only sent for receipts of type “normal” or “kopia”.';
        }

        field(210; "CleanCash Unit Id"; Text[20])
        {
            Caption = 'CleanCash Unit Id';
            DataClassification = CustomerContent;
            Description = 'The CleanCash manufacturing id code (“Tillverkningsnummer”). Maximum of 17 alphanumeric characters.';
        }

        field(220; "CleanCash Main Status"; Enum "NPR CleanCash Unit Main Status")
        {
            Caption = 'CleanCash Main Status';
            DataClassification = CustomerContent;
            Description = 'CleanCash unit main status.';
            InitValue = NO_VALUE;
        }

        field(230; "CleanCash Storage Status"; Enum "NPR CC Unit Stor. Stat.")
        {
            Caption = 'CleanCash Unit Storage Status';
            DataClassification = CustomerContent;
            Description = 'CleanCash unit storage status.';
            InitValue = NO_VALUE;
        }

        field(300; "Fault Code"; Enum "NPR CleanCash Fault Code")
        {
            Caption = 'Fault Code';
            DataClassification = CustomerContent;
            Description = 'A fault info structure is sent to an invalid request or a request that failed.';
        }

        field(310; "Fault Short Description"; Text[20])
        {
            Caption = 'Fault Short Description';
            DataClassification = CustomerContent;
            Description = 'Short error message';
        }

        field(320; "Fault Description"; Text[250])
        {
            Caption = 'Fault Description';
            DataClassification = CustomerContent;
            Description = 'Descriptive error message';
        }

    }

    keys
    {
        key(PK; "Request Entry No.", "Response No.")
        {
            Clustered = true;
        }
    }
}