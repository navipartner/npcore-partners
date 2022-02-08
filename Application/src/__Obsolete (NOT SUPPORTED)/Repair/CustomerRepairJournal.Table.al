table 6014505 "NPR Customer Repair Journal"
{
    Access = Internal;
    // NPR70.00.01.00/MH/20150113  CASE 199932 Removed Web references (WEB1.00).
    // NPR70.00.01.01/BHR/20150130 CASE 204899 Added field 6 "Part Item No.",7 Quantity
    // NPR70.00.02.00/MH/20150216  CASE 204110 Removed NaviShop References (WS).
    // NPR5.26/TS/20160913  CASE 251086 Added Field Qty Posted
    // NPR5.30/BHR /20170213  CASE 262923 ReWork Repair Funtionality
    // NPR5.51/MHA /20190722 CASE 358985 Added hook OnGetVATPostingSetup() and removed redundant VAT calculation

    Caption = 'Customer Repair Journal';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Repairs are not supported in core anymore.';

    fields
    {
        field(1; "Customer Repair No."; Code[10])
        {
            Caption = 'Customer Repair No.';
            DataClassification = CustomerContent;
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Error Description,Repair Description';
            OptionMembers = Fejlbeskrivelse,Reparationsbeskrivelse;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(5; "Text"; Text[90])
        {
            Caption = 'Text';
            DataClassification = CustomerContent;
        }
        field(6; "Item Part No."; Code[20])
        {
            Caption = 'Item Part No.';
            DataClassification = CustomerContent;
            Description = 'NPR70.00.01.01';
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            Description = 'NPR70.00.01.01';
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Description = 'NPR70.00.01.01';
        }
        field(15; "Qty Posted"; Decimal)
        {
            CalcFormula = - Sum("Item Ledger Entry".Quantity WHERE("Document No." = FIELD("Customer Repair No."),
                                                                   "Item No." = FIELD("Item Part No.")));
            Caption = 'Qty Posted';
            Description = 'NPR5.26';
            FieldClass = FlowField;
        }
        field(16; "Expenses to be charged"; Boolean)
        {
            Caption = 'Expenses to be charged';
            DataClassification = CustomerContent;
        }
        field(20; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.26';
        }
        field(21; "Unit Price Excl. VAT"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price Excl. VAT';
            DataClassification = CustomerContent;

        }
        field(25; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(29; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(30; "Amount Including VAT"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(40; "VAT Calculation Type"; Enum "Tax Calculation Type")
        {
            Caption = 'VAT Calculation Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(41; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
        }
        field(42; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
        }
        field(43; "VAT Identifier"; Code[20])
        {
            Caption = 'VAT Identifier';
            DataClassification = CustomerContent;
        }
        field(44; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Customer Repair No.", Type, "Line No.")
        {
        }
    }
}

