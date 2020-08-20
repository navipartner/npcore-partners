table 6151425 "Magento Item Custom Opt. Value"
{
    // MAG1.22/TR/20160414  CASE 238563 Magento Custom Options
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.21/BHR/20190508 CASE 338087 Field 100 Price Excl. VAT

    Caption = 'Item Custom Option Value';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(5; "Custom Option No."; Code[20])
        {
            Caption = 'Custom Option No.';
            DataClassification = CustomerContent;
            TableRelation = "Magento Custom Option";
        }
        field(10; "Custom Option Value Line No."; Integer)
        {
            Caption = 'Custom Option Value Line No.';
            DataClassification = CustomerContent;
        }
        field(100; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(1010; Description; Text[50])
        {
            CalcFormula = Lookup ("Magento Custom Option Value".Description WHERE("Custom Option No." = FIELD("Custom Option No."),
                                                                                  "Line No." = FIELD("Custom Option Value Line No.")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1060; Price; Decimal)
        {
            CalcFormula = Lookup ("Magento Custom Option Value".Price WHERE("Custom Option No." = FIELD("Custom Option No."),
                                                                            "Line No." = FIELD("Custom Option Value Line No.")));
            Caption = 'Price';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1070; "Price Type"; Option)
        {
            CalcFormula = Lookup ("Magento Custom Option Value"."Price Type" WHERE("Custom Option No." = FIELD("Custom Option No."),
                                                                                   "Line No." = FIELD("Custom Option Value Line No.")));
            Caption = 'Price Type';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Fixed,Percent';
            OptionMembers = "Fixed",Percent;
        }
        field(1110; "Price Includes VAT"; Boolean)
        {
            CalcFormula = Lookup ("Magento Custom Option"."Price Includes VAT" WHERE("No." = FIELD("Custom Option No.")));
            Caption = 'Price Includes VAT';
            FieldClass = FlowField;
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
        key(Key1; "Item No.", "Custom Option No.", "Custom Option Value Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

