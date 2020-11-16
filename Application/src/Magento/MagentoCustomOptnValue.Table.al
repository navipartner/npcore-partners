table 6151423 "NPR Magento Custom Optn. Value"
{
    // MAG1.22/TR/20160414  CASE 238563 Magento Custom Options
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.21/BHR/20190508 CASE 338087 Field 100 Price Excl. VAT

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
        field(70; "Price Type"; Option)
        {
            Caption = 'Price Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Fixed,Percent';
            OptionMembers = "Fixed",Percent;
        }
        field(80; "Sales Type"; Option)
        {
            Caption = 'Sales Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,G/L Account,Item,Resource,Fixed Asset,Charge (Item)';
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
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

            trigger OnValidate()
            var
                VATPostingSetup: Record "VAT Posting Setup";
                SalesSetup: Record "Sales & Receivables Setup";
            begin
            end;
        }
    }

    keys
    {
        key(Key1; "Custom Option No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ItemCustomOptValue: Record "NPR Magento Itm Cstm Opt.Value";
    begin
        ItemCustomOptValue.SetRange("Custom Option No.", "Custom Option No.");
        ItemCustomOptValue.SetRange("Custom Option Value Line No.", "Line No.");
        ItemCustomOptValue.DeleteAll;
    end;
}

