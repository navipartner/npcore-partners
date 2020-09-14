tableextension 6014680 "NPR Application Area Setup Ext" extends "Application Area Setup"
{
    fields
    {
        field(6060100; "NPR Ticket Essential"; Boolean)
        {
            Caption = 'NPR Ticket Essential';
            DataClassification = CustomerContent;
        }
        field(6060101; "NPR Ticket Advanced"; Boolean)
        {
            Caption = 'NPR Ticket Advanced';
            DataClassification = CustomerContent;
        }
        field(6060102; "NPR Ticket Wallet"; Boolean)
        {
            Caption = 'NPR Ticket Wallet';
            DataClassification = CustomerContent;
        }
        field(6060103; "NPR Ticket Dynamic Price"; Boolean)
        {
            Caption = 'NPR Ticket Dynamic Price';
            DataClassification = CustomerContent;
        }
    }
}