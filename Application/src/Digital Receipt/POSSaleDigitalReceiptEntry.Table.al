table 6059852 "NPR POSSaleDigitalReceiptEntry"
{
    Access = Internal;
    Caption = 'POS Sale Digital Receipt Entry';
    DataClassification = CustomerContent;
    LookupPageID = "NPR POSSaleDigitalRcptEntries";
    DrillDownPageId = "NPR POSSaleDigitalRcptEntries";

    fields
    {
        field(1; Id; Code[50])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; PDFLink; Text[2048])
        {
            Caption = 'PDF Link';
            DataClassification = CustomerContent;
        }
        field(20; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(30; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(40; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
        }
        field(50; "QR Code Link"; Text[2048])
        {
            Caption = 'QR Code Link';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; Id, PDFLink)
        {
            Clustered = true;
        }
        key(key2; "POS Entry No.")
        {
        }
        key(key3; "Sales Ticket No.")
        {
        }
    }
}
