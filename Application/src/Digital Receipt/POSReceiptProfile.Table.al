table 6150742 "NPR POS Receipt Profile"
{
    Access = Internal;
    Caption = 'POS Receipt Profile';
    DataClassification = CustomerContent;
    LookupPageID = "NPR POS Receipt Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Enable Digital Receipt"; Boolean)
        {
            Caption = 'Issue Digital Receipt After Sale';
            DataClassification = CustomerContent;
        }
        field(30; "Receipt Discount Information"; Option)
        {
            Caption = 'Receipt Discount Information';
            DataClassification = CustomerContent;
            OptionCaption = 'Per Line,Summary,No Information';
            OptionMembers = "Per Line","Summary","No Information";
        }
        field(40; "QRCode Time Interval Enabled"; Boolean)
        {
            Caption = 'QRCode Timeout Interval Enabled';
            DataClassification = CustomerContent;
        }
        field(50; "QRCode Timeout Interval(sec.)"; Integer)
        {
            Caption = 'QRCode Timeout Interval(sec.)';
            DataClassification = CustomerContent;
            BlankZero = true;
        }
        field(60; "E-mail Receipt On Sale"; Boolean)
        {
            Caption = 'Send E-mail Receipt On Sale';
            DataClassification = CustomerContent;
        }
        field(70; "Show Barcode as QR Code"; Boolean)
        {
            Caption = 'Show Barcode as QR Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1;
        "Code")
        {
        }
    }

    trigger OnInsert()
    begin
        TestField(Code);
    end;

    trigger OnModify()
    begin
        TestField(Code);
    end;

    trigger OnRename()
    begin
        TestField(Code);
    end;
}
