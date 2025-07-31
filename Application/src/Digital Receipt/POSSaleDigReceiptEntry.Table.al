table 6151216 "NPR POSSale Dig. Receipt Entry"
{
    Access = Internal;
    Caption = 'POS Sale Digital Receipt Entry';
    DataClassification = CustomerContent;
    LookupPageID = "NPR POSSaleDigitalRcptEntries";
    DrillDownPageId = "NPR POSSaleDigitalRcptEntries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; Id; Code[50])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(20; PDFLink; Text[2048])
        {
            Caption = 'PDF Link';
            DataClassification = CustomerContent;
        }
        field(30; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(40; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(50; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
        }
        field(60; "QR Code Link"; Text[2048])
        {
            Caption = 'QR Code Link';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(key1; Id, PDFLink)
        {
        }
        key(key2; "POS Entry No.")
        {
        }
        key(key3; "Sales Ticket No.")
        {
        }
    }
}
