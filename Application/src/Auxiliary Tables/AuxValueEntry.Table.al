table 6014489 "NPR Aux. Value Entry"
{
    // Fields are populated via transferfield from "Item Ledger Entry", mind the field ids when adding new fields.

    Caption = 'Aux. Value Entry';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Aux. Value Entries";
    LookupPageId = "NPR Aux. Value Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(4; "Item Ledger Entry Type"; Enum "Item Ledger Entry Type")
        {
            Caption = 'Item Ledger Entry Type';
            DataClassification = CustomerContent;
        }
        field(5; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Source Type" = CONST(Customer)) Customer
            ELSE
            IF ("Source Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Source Type" = CONST(Item)) Item;
        }
        field(8; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(11; "Item Ledger Entry No."; Integer)
        {
            Caption = 'Item Ledger Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Item Ledger Entry";
        }
        field(12; "Valued Quantity"; Decimal)
        {
            Caption = 'Valued Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(14; "Invoiced Quantity"; Decimal)
        {
            Caption = 'Invoiced Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(15; "Cost per Unit"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Cost per Unit';
            DataClassification = CustomerContent;
        }
        field(17; "Sales Amount (Actual)"; Decimal)
        {
            AutoFormatType = 1;
            DataClassification = CustomerContent;
            Caption = 'Sales Amount (Actual)';
        }
        field(23; "Discount Amount"; Decimal)
        {
            AutoFormatType = 1;
            DataClassification = CustomerContent;
            Caption = 'Discount Amount';
        }

        field(33; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(34; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(41; "Source Type"; Option)
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Customer,Vendor,Item';
            OptionMembers = " ",Customer,Vendor,Item;
        }
        field(43; "Cost Amount (Actual)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Cost Amount (Actual)';
            DataClassification = CustomerContent;
        }
        field(79; "Document Type"; Enum "Item Ledger Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(99; "Item Charge No."; Code[20])
        {
            Caption = 'Item Charge No.';
            DataClassification = CustomerContent;
            TableRelation = "Item Charge";
        }
        field(105; "Entry Type"; Enum "Cost Entry Type")
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(106; "Variance Type"; Enum "Cost Variance Type")
        {
            Caption = 'Variance Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(104; "Valuation Date"; Date)
        {
            Caption = 'Valuation Date';
            DataClassification = CustomerContent;
        }

        field(148; "Purchase Amount (Actual)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Purchase Amount (Actual)';
            DataClassification = CustomerContent;
        }
        field(149; "Purchase Amount (Expected)"; Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            AutoFormatType = 1;
            Caption = 'Purchase Amount (Expected)';
            DataClassification = CustomerContent;
        }
        field(150; "Sales Amount (Expected)"; Decimal)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            AutoFormatType = 1;
            Caption = 'Sales Amount (Expected)';
            DataClassification = CustomerContent;
        }
        field(151; "Cost Amount (Expected)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Cost Amount (Expected)';
            DataClassification = CustomerContent;
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
            DataClassification = CustomerContent;
        }
        field(6014401; "Group Sale"; Boolean)
        {
            Caption = 'Group Sale';
            DataClassification = CustomerContent;
        }
        field(6014408; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(6014409; "Discount Type"; Option)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,Photo Work,Rounding,Combination,Customer';
            OptionMembers = " ",Period,Mixed,"Multiple Unit","Salesperson Discount",Inventory,"Photo Work",Rounding,Combination,Customer;
        }
        field(6014410; "Discount Code"; Code[30])
        {
            Caption = 'Discount Code';
            DataClassification = CustomerContent;
        }
        field(6014413; "POS Unit No."; Code[20])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(6014414; "Salespers./Purch. Code"; Code[20])
        {
            Caption = 'Salespers./Purch. Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(6014415; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = CustomerContent;
        }
        field(6014416; "Document Date and Time"; DateTime)
        {
            Caption = 'Document Date and Time';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Item Ledger Entry Type", "Item Category Code", "Posting Date", "Vendor No.", "Salespers./Purch. Code", "Global Dimension 1 Code", "Global Dimension 2 Code", "Location Code")
        {
            SumIndexFields = "Purchase Amount (Actual)", "Sales Amount (Actual)", "Cost Amount (Actual)";
        }
        key(Key3; "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code", "Item Category Code", "Salespers./Purch. Code", "Vendor No.")
        {
            SumIndexFields = "Cost per Unit", "Cost Amount (Actual)";
        }
        key(Key4; "Item No.", "Posting Date", "Item Ledger Entry Type", "Entry Type", "Variance Type", "Item Charge No.", "Location Code", "Variant Code")
        {
            SumIndexFields = "Invoiced Quantity", "Sales Amount (Expected)", "Sales Amount (Actual)", "Cost Amount (Expected)", "Cost Amount (Actual)", "Purchase Amount (Actual)";
        }
    }
}
