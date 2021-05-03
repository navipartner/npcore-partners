table 6151424 "NPR Magento Item Custom Option"
{
    Caption = 'Item Custom Option';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Item Cstm Options";
    LookupPageID = "NPR Magento Item Cstm Options";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(5; "Custom Option No."; Code[20])
        {
            Caption = 'Custom Option No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Custom Option";
        }
        field(100; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(1010; Description; Text[50])
        {
            CalcFormula = Lookup("NPR Magento Custom Option".Description WHERE("No." = FIELD("Custom Option No.")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020; Type; Enum "NPR Magento Item Custom Type")
        {
            CalcFormula = Lookup("NPR Magento Custom Option".Type WHERE("No." = FIELD("Custom Option No.")));
            Caption = 'Type';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1030; Required; Boolean)
        {
            CalcFormula = Lookup("NPR Magento Custom Option".Required WHERE("No." = FIELD("Custom Option No.")));
            Caption = 'Required';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1040; "Max Length"; Integer)
        {
            CalcFormula = Lookup("NPR Magento Custom Option"."Max Length" WHERE("No." = FIELD("Custom Option No.")));
            Caption = 'Max Length';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1050; Position; Integer)
        {
            CalcFormula = Lookup("NPR Magento Custom Option".Position WHERE("No." = FIELD("Custom Option No.")));
            Caption = 'Position';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1060; Price; Decimal)
        {
            CalcFormula = Lookup("NPR Magento Custom Option".Price WHERE("No." = FIELD("Custom Option No.")));
            Caption = 'Price';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1070; "Price Type"; Enum "NPR Mag. Cust. Opt. Price Type")
        {
            CalcFormula = Lookup("NPR Magento Custom Option"."Price Type" WHERE("No." = FIELD("Custom Option No.")));
            Caption = 'Price Type';
            FieldClass = FlowField;
        }
        field(1100; "Enabled Option Values"; Integer)
        {
            CalcFormula = Count("NPR Magento Itm Cstm Opt.Value" WHERE("Item No." = FIELD("Item No."),
                                                                        "Custom Option No." = FIELD("Custom Option No."),
                                                                        Enabled = CONST(true)));
            Caption = 'Enabled Option Values';
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
        key(Key1; "Item No.", "Custom Option No.")
        {
        }
    }

    trigger OnDelete()
    var
        ItemCustomOptValue: Record "NPR Magento Itm Cstm Opt.Value";
    begin
        ItemCustomOptValue.SetRange("Item No.", "Item No.");
        ItemCustomOptValue.SetRange("Custom Option No.", "Custom Option No.");
        ItemCustomOptValue.DeleteAll();
    end;
}
