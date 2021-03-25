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
        field(6014414; "NPR Bill-to E-mail"; Text[80])
        {
            Caption = 'Bill-to E-mail';
            Description = 'PN1.00';
            DataClassification = CustomerContent;
        }
        field(6014415; "NPR Document Processing"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Document Sending Profile from Customer is used.';
            Caption = 'Document Processing';
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,OIO,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
            DataClassification = CustomerContent;
        }
        field(6014420; "NPR Delivery Location"; Code[10])
        {
            Caption = 'Delivery Location';
            Description = 'PS1.01';
            DataClassification = CustomerContent;
        }
        field(6014425; "NPR Order Type"; Option)
        {
            Caption = 'Order Type';
            OptionCaption = ',Order,Lending';
            OptionMembers = ,"Order",Lending;
            DataClassification = CustomerContent;
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

