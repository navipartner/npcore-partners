table 6060117 "NPR TM Ticket Reserv. Resp."
{
    Access = Internal;
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.04/TSA/20160115  CASE 231834 General Issues
    // TM1.08/TSA/20160222  CASE 235208 Added new Admission Code to identify ticket specifics
    // TM80.1.09/TSA/20160301  CASE 235860 Sell event tickets in POS
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.17/TSA/20161025  CASE 256152 Conform to OMA Guidelines
    // NPR5.31/JLK/20170331  CASE 268274 Changed ENU Caption
    // TM1.21/TSA/20170523  CASE 276898 Added keys on session and request entry no

    Caption = 'Ticket Reservation Response';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Request Entry No."; Integer)
        {
            Caption = 'Request Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Ticket Reservation Req.";
        }
        field(10; "Session Token ID"; Text[100])
        {
            Caption = 'Session Token ID';
            DataClassification = CustomerContent;
        }
        field(11; "Exires (Seconds)"; Integer)
        {
            Caption = 'Expires (Seconds)';
            DataClassification = CustomerContent;
        }
        field(12; Status; Boolean)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(13; Confirmed; Boolean)
        {
            Caption = 'Confirmed';
            DataClassification = CustomerContent;
        }
        field(14; Canceled; Boolean)
        {
            Caption = 'Canceled';
            DataClassification = CustomerContent;
        }
        field(20; "Response Message"; Text[250])
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
        }
        field(25; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Request Entry No.")
        {
        }
        key(Key3; "Session Token ID")
        {
        }
    }

    fieldgroups
    {
    }
}

