table 6151423 "NPR Magento Custom Optn. Value"
{
    Caption = 'Magento Custom Option Value';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Custom Option No."; Code[20])
        {
            Caption = 'Custom Option No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Custom Option";
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(60; Price; Decimal)
        {
            Caption = 'Price';
            DataClassification = CustomerContent;
        }
        field(70; "Price Type"; Enum "NPR Mag. Cust. Opt. Price Type")
        {
            Caption = 'Price Type';
            DataClassification = CustomerContent;
        }
        field(80; "Sales Type"; Enum "Sales Line Type")
        {
            Caption = 'Sales Type';
            DataClassification = CustomerContent;
        }
        field(90; "Sales No."; Code[20])
        {
            Caption = 'Sales No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Sales Type" = CONST(" ")) "Standard Text"
            ELSE
            IF ("Sales Type" = CONST("G/L Account")) "G/L Account"
            ELSE
            IF ("Sales Type" = CONST(Item)) Item
            ELSE
            IF ("Sales Type" = CONST(Resource)) Resource
            ELSE
            IF ("Sales Type" = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF ("Sales Type" = CONST("Charge (Item)")) "Item Charge";
        }
        field(100; "Price Includes VAT"; Boolean)
        {
            Caption = 'Price Includes VAT';
            DataClassification = CustomerContent;
            InitValue = true;
        }
    }

    keys
    {
        key(Key1; "Custom Option No.", "Line No.")
        {
        }
    }

    trigger OnDelete()
    var
        ItemCustomOptValue: Record "NPR Magento Itm Cstm Opt.Value";
    begin
        ItemCustomOptValue.SetRange("Custom Option No.", "Custom Option No.");
        ItemCustomOptValue.SetRange("Custom Option Value Line No.", "Line No.");
        ItemCustomOptValue.DeleteAll();
    end;
}
