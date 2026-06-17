table 6059920 "NPR NPRE Rest. Print Header"
{
    Caption = 'Restaurant Print Header';
    TableType = Temporary;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Waiter Pad No."; Code[20])
        {
            Caption = 'Waiter Pad No.';
            DataClassification = CustomerContent;
        }
        field(20; "Restaurant Code"; Code[20])
        {
            Caption = 'Restaurant Code';
            DataClassification = CustomerContent;
        }
        field(30; "Seating Code"; Code[20])
        {
            Caption = 'Seating Code';
            DataClassification = CustomerContent;
        }
        field(40; "Seating Location"; Code[10])
        {
            Caption = 'Seating Location';
            DataClassification = CustomerContent;
        }
        field(50; "Seating Description"; Text[50])
        {
            Caption = 'Seating Description';
            DataClassification = CustomerContent;
        }
        field(60; "Number of Guests"; Integer)
        {
            Caption = 'Number of Guests';
            DataClassification = CustomerContent;
        }
        field(70; "Waiter Code"; Code[20])
        {
            Caption = 'Waiter Code';
            DataClassification = CustomerContent;
        }
        field(80; "Waiter Name"; Text[100])
        {
            Caption = 'Waiter Name';
            DataClassification = CustomerContent;
        }
        field(90; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(100; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(110; "Customer Phone No."; Text[30])
        {
            Caption = 'Customer Phone No.';
            DataClassification = CustomerContent;
        }
        field(120; "Print Date Time"; DateTime)
        {
            Caption = 'Print Date Time';
            DataClassification = CustomerContent;
        }
        field(130; "Seating No."; Text[20])
        {
            Caption = 'Seating No.';
            DataClassification = CustomerContent;
        }
        field(140; "Waiter Pad Description"; Text[100])
        {
            Caption = 'Waiter Pad Description';
            DataClassification = CustomerContent;
        }
        field(150; "Store Address"; Text[50])
        {
            Caption = 'Store Address';
            DataClassification = CustomerContent;
        }
        field(160; "Store Post Code"; Code[20])
        {
            Caption = 'Store Post Code';
            DataClassification = CustomerContent;
        }
        field(170; "Store City"; Text[30])
        {
            Caption = 'Store City';
            DataClassification = CustomerContent;
        }
        field(180; "Store Phone No."; Text[30])
        {
            Caption = 'Store Phone No.';
            DataClassification = CustomerContent;
        }
        field(190; "Store VAT Registration No."; Text[20])
        {
            Caption = 'Store VAT Registration No.';
            DataClassification = CustomerContent;
        }
        field(200; "Total Amount Excl. VAT"; Decimal)
        {
            Caption = 'Total Amount Excl. VAT';
            DataClassification = CustomerContent;
        }
        field(210; "Total Amount Incl. VAT"; Decimal)
        {
            Caption = 'Total Amount Incl. VAT';
            DataClassification = CustomerContent;
        }
        field(220; "Has Receipt Logo"; Boolean)
        {
            Caption = 'Has Receipt Logo';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Waiter Pad No.")
        {
            Clustered = true;
        }
    }
}
