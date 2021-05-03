table 6151425 "NPR Magento Itm Cstm Opt.Value"
{
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
            TableRelation = "NPR Magento Custom Option";
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
            CalcFormula = Lookup("NPR Magento Custom Optn. Value".Description WHERE("Custom Option No." = FIELD("Custom Option No."),
                                                                                  "Line No." = FIELD("Custom Option Value Line No.")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1060; Price; Decimal)
        {
            CalcFormula = Lookup("NPR Magento Custom Optn. Value".Price WHERE("Custom Option No." = FIELD("Custom Option No."),
                                                                            "Line No." = FIELD("Custom Option Value Line No.")));
            Caption = 'Price';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1070; "Price Type"; Enum "NPR Mag. Cust. Opt. Price Type")
        {
            CalcFormula = Lookup("NPR Magento Custom Optn. Value"."Price Type" WHERE("Custom Option No." = FIELD("Custom Option No."),
                                                                                   "Line No." = FIELD("Custom Option Value Line No.")));
            Caption = 'Price Type';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1110; "Price Includes VAT"; Boolean)
        {
            CalcFormula = Lookup("NPR Magento Custom Option"."Price Includes VAT" WHERE("No." = FIELD("Custom Option No.")));
            Caption = 'Price Includes VAT';
            FieldClass = FlowField;
            InitValue = true;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Custom Option No.", "Custom Option Value Line No.")
        {
        }
    }
}
