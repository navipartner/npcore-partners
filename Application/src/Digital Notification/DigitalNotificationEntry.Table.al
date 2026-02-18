#if not (BC17 or BC18 or BC19 or BC20 or BC21)
table 6248181 "NPR Digital Notification Entry"
{
    Access = Internal;
    Caption = 'Digital Notification Entry';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Digital Notif. Entries";
    LookupPageId = "NPR Digital Notif. Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(10; "External Order No."; Code[20])
        {
            Caption = 'External Order No.';
            DataClassification = CustomerContent;
        }
        field(12; "Document Type"; Enum "NPR Digital Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(14; "Posted Document No."; Code[20])
        {
            Caption = 'Posted Document No.';
            DataClassification = CustomerContent;
        }
        field(20; "Recipient E-mail"; Text[80])
        {
            Caption = 'Recipient E-mail';
            DataClassification = CustomerContent;
        }
        field(30; "Recipient Name"; Text[100])
        {
            Caption = 'Recipient Name';
            DataClassification = CustomerContent;
        }
        field(40; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
            TableRelation = Language;
        }
        field(50; "Manifest ID"; Guid)
        {
            Caption = 'Manifest ID';
            DataClassification = CustomerContent;
        }
        field(60; "Email Template Id"; Code[20])
        {
            Caption = 'Email Template Id';
            DataClassification = CustomerContent;
        }
        field(70; Sent; Boolean)
        {
            Caption = 'Sent';
            DataClassification = CustomerContent;
        }
        field(80; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(90; "Attempt Count"; Integer)
        {
            Caption = 'Attempt Count';
            DataClassification = CustomerContent;
        }
        field(100; "Sent Date-Time"; DateTime)
        {
            Caption = 'Sent Date-Time';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SendingStatus; Sent, "Attempt Count")
        {
        }
        key(Manifest; "Manifest ID")
        {
        }
    }
}
#endif