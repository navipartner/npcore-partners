table 6014671 "NPR POS Salesperson St Buffer"
{
    Access = Internal;
    DataClassification = CustomerContent;
    TableType = Temporary;
    Caption = 'POS Salesperson Stats Buffer';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; "Sales (LCY)"; Decimal)
        {
            Caption = 'Sales (LCY)';
            DataClassification = CustomerContent;
        }
        field(4; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
        }
        field(5; "Profit (LCY)"; Decimal)
        {
            Caption = 'Profit (LCY)';
            DataClassification = CustomerContent;
        }
        field(6; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            DataClassification = CustomerContent;
            AutoFormatExpression = '<precision,0:2><Standard Format,0>%';
            AutoFormatType = 10;
        }
        field(7; "Profit %"; Decimal)
        {
            Caption = 'Profit %';
            DataClassification = CustomerContent;
            AutoFormatExpression = '<precision,0:2><Standard Format,0>%';
            AutoFormatType = 10;
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