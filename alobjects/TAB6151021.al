table 6151021 "NpRv Voucher Buffer"
{
    // NPR5.42/MHA /20180525  CASE 307022 Object created - Global Retail Voucher
    // NPR5.49/MHA /20190228  CASE 342811 Renamed table from "NpRv Global Voucher Buffer" and added partner fields

    Caption = 'Voucher Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Reference No."; Text[30])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
        }
        field(5; "Voucher Type"; Code[20])
        {
            Caption = 'Voucher Type';
            DataClassification = CustomerContent;
            TableRelation = "NpRv Voucher Type";
        }
        field(7; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.49';
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "Starting Date"; DateTime)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(35; "Ending Date"; DateTime)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(55; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                 "Direct Posting" = CONST(true));
        }
        field(75; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(110; "Validate Voucher Module"; Code[20])
        {
            Caption = 'Validate Voucher Module';
            DataClassification = CustomerContent;
            Description = 'NPR5.49';
            TableRelation = "NpRv Voucher Module".Code WHERE(Type = CONST("Validate Voucher"));
        }
        field(210; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            ValidateTableRelation = false;
        }
        field(215; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
            DataClassification = CustomerContent;
        }
        field(220; Address; Text[50])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(225; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(230; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code"
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code" WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(235; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code".City
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code".City WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(240; County; Text[30])
        {
            Caption = 'County';
            DataClassification = CustomerContent;
        }
        field(245; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(255; "E-mail"; Text[80])
        {
            Caption = 'E-mail';
            DataClassification = CustomerContent;
        }
        field(260; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(300; "Voucher Message"; Text[250])
        {
            Caption = 'Voucher Message';
            DataClassification = CustomerContent;
        }
        field(1000; "Issue Date"; Date)
        {
            Caption = 'Issue Date';
            DataClassification = CustomerContent;
        }
        field(1005; "Issue Register No."; Code[10])
        {
            Caption = 'Issue Register No.';
            DataClassification = CustomerContent;
        }
        field(1010; "Issue Sales Ticket No."; Code[20])
        {
            Caption = 'Issue Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(1015; "Issue User ID"; Code[50])
        {
            Caption = 'Issue User ID';
            DataClassification = CustomerContent;
        }
        field(1020; "Issue Partner Code"; Code[20])
        {
            Caption = 'Issue Partner Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.49';
        }
        field(2000; "Redeem Date"; Date)
        {
            Caption = 'Redeem Date';
            DataClassification = CustomerContent;
        }
        field(2005; "Redeem Register No."; Code[10])
        {
            Caption = 'Redeem Register No.';
            DataClassification = CustomerContent;
        }
        field(2010; "Redeem Sales Ticket No."; Code[20])
        {
            Caption = 'Redeem Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(2015; "Redeem User ID"; Code[50])
        {
            Caption = 'Redeem User ID';
            DataClassification = CustomerContent;
        }
        field(2020; "Redeem Partner Code"; Code[20])
        {
            Caption = 'Redeem Partner Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.49';
        }
    }

    keys
    {
        key(Key1; "Reference No.")
        {
        }
    }

    fieldgroups
    {
    }
}

