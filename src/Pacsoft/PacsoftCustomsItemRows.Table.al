table 6014472 "NPR Pacsoft Customs Item Rows"
{
    // PS1.00/LS/20141201  CASE 200150 Pacsoft Module

    Caption = 'Pacsoft Customs Item Rows';
    DrillDownPageID = "NPR Pacsoft Customs Item Rows";
    LookupPageID = "NPR Pacsoft Customs Item Rows";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shipment Document Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            MinValue = 1;
            DataClassification = CustomerContent;
        }
        field(2; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "Item Code"; Text[8])
        {
            Caption = 'Item Code (Stat No.)';
            DataClassification = CustomerContent;
        }
        field(4; "Line Information"; Option)
        {
            Caption = 'Line Information';
            OptionCaption = 'Specified Per Row,Specified Per Piece';
            OptionMembers = "Specified Per Row","Specified Per Piece";
            DataClassification = CustomerContent;
        }
        field(5; Copies; Integer)
        {
            Caption = 'Copies';
            DataClassification = CustomerContent;
        }
        field(6; "Customs Value"; Decimal)
        {
            Caption = 'Customs Value';
            DataClassification = CustomerContent;
        }
        field(7; Content; Text[30])
        {
            Caption = 'Content';
            DataClassification = CustomerContent;
        }
        field(8; "Country of Origin"; Code[10])
        {
            Caption = 'Country of Origin';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Shipment Document Entry No.", "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

