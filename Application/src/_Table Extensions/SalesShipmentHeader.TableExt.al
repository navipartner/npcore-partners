tableextension 6014403 "NPR Sales Shipment Header" extends "Sales Shipment Header"
{
    fields
    {
        field(6014400; "NPR Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            Description = 'NPR7.100.000';
            DataClassification = CustomerContent;
        }
        field(6014420; "NPR Delivery Location"; Code[10])
        {
            Caption = 'Delivery Location';
            Description = 'PS1.01';
            DataClassification = CustomerContent;
        }

        field(6014421; "NPR Package Code"; Code[20])
        {
            Caption = 'Package Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Package Code".Code;
        }
        field(6014450; "NPR Kolli"; Integer)
        {
            Caption = 'Number of packages';
            Description = 'NPR7.100.000';
            InitValue = 1;
            DataClassification = CustomerContent;
        }
        field(6014452; "NPR Delivery Instructions"; Text[50])
        {
            Caption = 'Delivery Instructions';
            DataClassification = CustomerContent;
        }
        field(6151405; "NPR External Order No."; Code[20])
        {
            Caption = 'External Order No.';
            Description = 'MAG2.00';
            DataClassification = CustomerContent;
        }
    }
}

