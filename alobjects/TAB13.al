tableextension 6014416 tableextension6014416 extends "Salesperson/Purchaser" 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                           Added fields 6014400..6014420
    // NPR5.20/TTH/20160303 CASE 235900 Removed extra blank space from the OptionCaption of field 6014401 Customer Creation.
    // NPR5.26/CLVA/20160816 CASE 248272 Added field Picture
    // NPR5.34/KENU/20170712 CASE 281419 Added Key: "Name"
    // NPR5.38/AE  /20180113 CASE 289390 Added filed Supervisor POS
    // NPR5.53/BHR /20191008 CASE 369354 deleted field 6014401
    // NPR5.55/BHR /20201902 CASE 361515 Delete key Name
    fields
    {
        field(6014400; "Register Password"; Code[20])
        {
            Caption = 'Register Password';
            Description = 'NPR7.100.000';
        }
        field(6014402; "Hide Register Imbalance"; Boolean)
        {
            Caption = 'Hide Register Imbalance';
            Description = 'NPR7.100.000';
        }
        field(6014403; "Sales (LCY)"; Decimal)
        {
            CalcFormula = Sum ("Value Entry"."Sales Amount (Actual)" WHERE ("Item Ledger Entry Type" = CONST (Sale),
                                                                           "Salespers./Purch. Code" = FIELD (Code),
                                                                           "Posting Date" = FIELD ("Date Filter"),
                                                                           "Item Group No." = FIELD ("Item Group Filter"),
                                                                           "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                                           "Item No." = FIELD ("Item Filter")));
            Caption = 'Sales (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014404; "Discount Amount"; Decimal)
        {
            CalcFormula = - Sum ("Value Entry"."Discount Amount" WHERE ("Item Ledger Entry Type" = CONST (Sale),
                                                                      "Salespers./Purch. Code" = FIELD (Code),
                                                                      "Posting Date" = FIELD ("Date Filter"),
                                                                      "Item Group No." = FIELD ("Item Group Filter"),
                                                                      "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter")));
            Caption = 'Discount Amount';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014405; "COGS (LCY)"; Decimal)
        {
            CalcFormula = - Sum ("Value Entry"."Cost Amount (Actual)" WHERE ("Item Ledger Entry Type" = CONST (Sale),
                                                                           "Salespers./Purch. Code" = FIELD (Code),
                                                                           "Posting Date" = FIELD ("Date Filter"),
                                                                           "Item Group No." = FIELD ("Item Group Filter"),
                                                                           "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter")));
            Caption = 'COGS (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014406; "Item Group Filter"; Code[10])
        {
            Caption = 'Item Group Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
        }
        field(6014407; "Sales (Qty.)"; Decimal)
        {
            CalcFormula = - Sum ("Value Entry"."Valued Quantity" WHERE ("Item Ledger Entry Type" = CONST (Sale),
                                                                      "Salespers./Purch. Code" = FIELD (Code),
                                                                      "Posting Date" = FIELD ("Date Filter"),
                                                                      "Item Group No." = FIELD ("Item Group Filter"),
                                                                      "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                                      "Item No." = FIELD ("Item Filter")));
            Caption = 'Sales (Qty.)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014408; "Reverse Sales Ticket"; Option)
        {
            Caption = 'Reverse Sales Ticket';
            Description = 'NPR7.100.000';
            OptionCaption = 'Yes,No';
            OptionMembers = Yes,No;
        }
        field(6014410; "Register Filter"; Code[10])
        {
            Caption = 'Register Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            TableRelation = Register."Register No.";
        }
        field(6014411; "Global Dimension 1 Filter"; Code[20])
        {
            Caption = 'Global Dimension 1 Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No." = CONST (1));
        }
        field(6014412; "Item Group Sales (LCY)"; Decimal)
        {
            CalcFormula = Sum ("Value Entry"."Sales Amount (Actual)" WHERE ("Item Ledger Entry Type" = CONST (Sale),
                                                                           "Salespers./Purch. Code" = FIELD (Code),
                                                                           "Posting Date" = FIELD ("Date Filter"),
                                                                           "Item Group No." = FIELD ("Item Group Filter"),
                                                                           "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                                           "Group Sale" = CONST (true)));
            Caption = 'Item Group Sales (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014413; "Item Filter"; Code[20])
        {
            Caption = 'Item Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
        }
        field(6014416; "Locked-to Register No."; Code[10])
        {
            Caption = 'Locked-to Register No.';
            Description = 'NPR7.100.000';
        }
        field(6014420; "Maximum Cash Returnsale"; Decimal)
        {
            Caption = 'Maximum Cash Returnsale';
            Description = 'NPR7.100.000';
        }
        field(6014421; Picture; BLOB)
        {
            Caption = 'Picture';
            Description = 'NPR5.26';
            SubType = Bitmap;
        }
        field(6014422; "Supervisor POS"; Boolean)
        {
            Caption = 'Supervisor POS';
            Description = 'NPR5.38';
        }
    }
}

