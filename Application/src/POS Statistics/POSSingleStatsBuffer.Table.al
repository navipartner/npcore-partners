table 6014663 "NPR POS Single Stats Buffer"
{
    Access = Internal;
    DataClassification = CustomerContent;
    TableType = Temporary;
    Caption = 'POS Single Stats Buffer';
    DataCaptionFields = "Document No.";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(3; "Cost Amount"; Decimal)
        {
            Caption = 'Cost Amount';
            DataClassification = CustomerContent;
        }
        field(4; "Sales Amount"; Decimal)
        {
            Caption = 'Sales Amount';
            DataClassification = CustomerContent;
        }
        field(5; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(6; "Profit %"; Decimal)
        {
            Caption = 'Profit %';
            DataClassification = CustomerContent;
            AutoFormatExpression = '<precision,0:2><Standard Format,0>%';
            AutoFormatType = 10;
        }
        field(7; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
        }
        field(8; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
            DataClassification = CustomerContent;
        }
        field(9; "Amount Incl. Tax"; Decimal)
        {
            Caption = 'Amount Incl. Tax';
            DataClassification = CustomerContent;
        }
        field(10; "Sales Quantity"; Decimal)
        {
            Caption = 'Sales Quantity';
            DataClassification = CustomerContent;
        }
        field(11; "Return Sales Quantity"; Decimal)
        {
            Caption = 'Return Sales Quantity';
            DataClassification = CustomerContent;
        }
        field(12; "Profit Amount"; Decimal)
        {
            Caption = 'Profit Amount';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }
}