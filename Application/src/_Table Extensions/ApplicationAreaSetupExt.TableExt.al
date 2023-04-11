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
        field(6060104; "NPR Retail"; Boolean)
        {
            Caption = 'NPR Retail';
            DataClassification = CustomerContent;
        }
        field(6060105; "NPR NaviConnect"; Boolean)
        {
            Caption = 'NPR NaviConnect';
            DataClassification = CustomerContent;
        }
        field(6060106; "NPR Membership Essential"; Boolean)
        {
            Caption = 'NPR Membership Essential';
            DataClassification = CustomerContent;
        }
        field(6060107; "NPR Membership Advanced"; Boolean)
        {
            Caption = 'NPR Membership Advanced';
            DataClassification = CustomerContent;
        }
        field(6060108; "NPR HeyLoyalty"; Boolean)
        {
            Caption = 'NPR HeyLoyalty Integration';
            DataClassification = CustomerContent;
        }
        field(6060110; "NPR RS R Local"; Boolean)
        {
            Caption = 'NPR RS Retail Localization';
            DataClassification = CustomerContent;
        }
    }
}