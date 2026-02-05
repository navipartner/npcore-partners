table 6014469 "NPR SalesPost Pdf2Nav Setup"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
    Caption = 'Sales-Post and Pdf2Nav Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; "Post and Send"; Option)
        {
            Caption = 'Post and Send';
            OptionCaption = 'Both Std. NAV and Pdf2Nav,Std. NAV Only,Pdf2Nav Only';
            OptionMembers = "Both Std. NAV and Pdf2Nav","Std. NAV Only","Pdf2Nav Only";
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Pdf2Nav removed from standard email functions.';
        }
        field(20; "Always Print Ship"; Boolean)
        {
            Caption = 'Always Print Sales Shipment';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(21; "Always Print Receive"; Boolean)
        {
            Caption = 'Always Print Sales Return Receipt';
            InitValue = true;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}

