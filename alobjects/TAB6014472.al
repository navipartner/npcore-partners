table 6014472 "Pacsoft Customs Item Rows"
{
    // PS1.00/LS/20141201  CASE 200150 Pacsoft Module

    Caption = 'Pacsoft Customs Item Rows';
    DrillDownPageID = "Pacsoft Customs Item Rows";
    LookupPageID = "Pacsoft Customs Item Rows";

    fields
    {
        field(1;"Shipment Document Entry No.";BigInteger)
        {
            Caption = 'Entry No.';
            MinValue = 1;
        }
        field(2;"Entry No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(3;"Item Code";Text[8])
        {
            Caption = 'Item Code (Stat No.)';
        }
        field(4;"Line Information";Option)
        {
            Caption = 'Line Information';
            OptionCaption = 'Specified Per Row,Specified Per Piece';
            OptionMembers = "Specified Per Row","Specified Per Piece";
        }
        field(5;Copies;Integer)
        {
            Caption = 'Copies';
        }
        field(6;"Customs Value";Decimal)
        {
            Caption = 'Customs Value';
        }
        field(7;Content;Text[30])
        {
            Caption = 'Content';
        }
        field(8;"Country of Origin";Code[10])
        {
            Caption = 'Country of Origin';
            TableRelation = "Country/Region";
        }
    }

    keys
    {
        key(Key1;"Shipment Document Entry No.","Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

