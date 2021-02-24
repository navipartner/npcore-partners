table 6014478 "NPR Retail Logo"
{
    // NPR5.27/MMV /20160927 CASE 253453 Added non-validated table relation to register table on field 2.
    // NPR5.29/MMV /20161207 CASE 252253 Changed field 1 type from Code to Integer. Data upgrade being handled by CU 6059990.
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.40/MMV /20180306 CASE 284505 Added fields for permanent storage of ESCPOS specific constants per logo.
    // NPR5.55/MITH/20200619 CASE 404276 Added fields to store a 1-bit version of the logo and its size (Boca Printer related)

    Caption = 'Retail Logo';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Sequence; Integer)
        {
            Caption = 'Sequence';
            DataClassification = CustomerContent;
        }
        field(2; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            TableRelation = "NPR POS Unit"."No.";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(3; Keyword; Code[20])
        {
            Caption = 'Keyword';
            DataClassification = CustomerContent;
        }
        field(4; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;
        }
        field(5; "End Date"; Date)
        {
            Caption = 'End Date';
            DataClassification = CustomerContent;
        }
        field(6; Logo; BLOB)
        {
            Caption = 'Logo';
            SubType = Bitmap;
            DataClassification = CustomerContent;
        }
        field(7; ESCPOSLogo; BLOB)
        {
            Caption = 'ESCPOS Logo';
            DataClassification = CustomerContent;
        }
        field(8; Height; Integer)
        {
            Caption = 'Height';
            DataClassification = CustomerContent;
        }
        field(9; Width; Integer)
        {
            Caption = 'Width';
            DataClassification = CustomerContent;
        }
        field(100; "ESCPOS Height Low Byte"; Integer)
        {
            Caption = 'ESCPOS Height Low Byte';
            DataClassification = CustomerContent;
        }
        field(101; "ESCPOS Height High Byte"; Integer)
        {
            Caption = 'ESCPOS Height High Byte';
            DataClassification = CustomerContent;
        }
        field(102; "ESCPOS Cmd Low Byte"; Integer)
        {
            Caption = 'ESCPOS Cmd Low Byte';
            DataClassification = CustomerContent;
        }
        field(103; "ESCPOS Cmd High Byte"; Integer)
        {
            Caption = 'ESCPOS Cmd High Byte';
            DataClassification = CustomerContent;
        }
        field(120; OneBitLogo; BLOB)
        {
            Caption = '1-bit Logo';
            DataClassification = CustomerContent;
        }
        field(121; OneBitLogoByteSize; Integer)
        {
            Caption = '1-bit Logo Size in Bytes';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Sequence)
        {
        }
    }

    fieldgroups
    {
    }

    procedure NewRecord()
    var
        RetailLogo2: Record "NPR Retail Logo";
    begin
        //-NPR5.29 [252253]
        if RetailLogo2.FindLast then;
        Sequence := RetailLogo2.Sequence + 1;
        // IF RetailLogo2.FINDLAST AND (RetailLogo2.Sequence <> '') THEN
        //  Sequence := INCSTR(RetailLogo2.Sequence)
        // ELSE
        //  Sequence := '1';
        //+NPR5.29 [252253]
    end;
}

