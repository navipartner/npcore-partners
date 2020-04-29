table 6151423 "Magento Custom Option Value"
{
    // MAG1.22/TR/20160414  CASE 238563 Magento Custom Options
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.21/BHR/20190508 CASE 338087 Field 100 Price Excl. VAT

    Caption = 'Magento Custom Option Value';

    fields
    {
        field(1;"Custom Option No.";Code[20])
        {
            Caption = 'Custom Option No.';
            TableRelation = "Magento Custom Option";
        }
        field(5;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(60;Price;Decimal)
        {
            Caption = 'Price';
        }
        field(70;"Price Type";Option)
        {
            Caption = 'Price Type';
            OptionCaption = 'Fixed,Percent';
            OptionMembers = "Fixed",Percent;
        }
        field(80;"Sales Type";Option)
        {
            Caption = 'Sales Type';
            OptionCaption = ' ,G/L Account,Item,Resource,Fixed Asset,Charge (Item)';
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
        }
        field(90;"Sales No.";Code[20])
        {
            Caption = 'Sales No.';
            TableRelation = IF ("Sales Type"=CONST(" ")) "Standard Text"
                            ELSE IF ("Sales Type"=CONST("G/L Account")) "G/L Account"
                            ELSE IF ("Sales Type"=CONST(Item)) Item
                            ELSE IF ("Sales Type"=CONST(Resource)) Resource
                            ELSE IF ("Sales Type"=CONST("Fixed Asset")) "Fixed Asset"
                            ELSE IF ("Sales Type"=CONST("Charge (Item)")) "Item Charge";
        }
        field(100;"Price Includes VAT";Boolean)
        {
            Caption = 'Price Includes VAT';
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
        key(Key1;"Custom Option No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ItemCustomOptValue: Record "Magento Item Custom Opt. Value";
    begin
        ItemCustomOptValue.SetRange("Custom Option No.","Custom Option No.");
        ItemCustomOptValue.SetRange("Custom Option Value Line No.","Line No.");
        ItemCustomOptValue.DeleteAll;
    end;
}

