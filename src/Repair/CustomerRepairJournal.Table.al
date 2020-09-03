table 6014505 "NPR Customer Repair Journal"
{
    // NPR70.00.01.00/MH/20150113  CASE 199932 Removed Web references (WEB1.00).
    // NPR70.00.01.01/BHR/20150130 CASE 204899 Added field 6 "Part Item No.",7 Quantity
    // NPR70.00.02.00/MH/20150216  CASE 204110 Removed NaviShop References (WS).
    // NPR5.26/TS/20160913  CASE 251086 Added Field Qty Posted
    // NPR5.30/BHR /20170213  CASE 262923 ReWork Repair Funtionality
    // NPR5.51/MHA /20190722 CASE 358985 Added hook OnGetVATPostingSetup() and removed redundant VAT calculation

    Caption = 'Customer Repair Journal';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Customer Repair No."; Code[10])
        {
            Caption = 'Customer Repair No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Customer Repair";
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
            TableRelation = Item;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                //-NPR70.00.01.01
                Item.Get("Item Part No.");
                Description := Item.Description;
                Quantity := 1;
                if Date = 0D then
                    Date := Today;
                //+NPR70.00.01.01
                //-NPR5.30 [262923]
                "Unit Price Excl. VAT" := Item."Unit Price";
                CustomerRepair.Get("Customer Repair No.");
                Customer.Get(CustomerRepair."Customer No.");
                "VAT Bus. Posting Group" := Customer."VAT Bus. Posting Group";
                Validate("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
                //+NPR5.30 [262923]
            end;
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            Description = 'NPR70.00.01.01';
        }
        field(8; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Description = 'NPR70.00.01.01';
        }
        field(15; "Qty Posted"; Decimal)
        {
            CalcFormula = - Sum ("Item Ledger Entry".Quantity WHERE("Document No." = FIELD("Customer Repair No."),
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
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item Part No."));
        }
        field(21; "Unit Price Excl. VAT"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price Excl. VAT';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-NPR5.30 [262923]
                CalcAmounts;
                //+NPR5.30 [262923]
            end;
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

            trigger OnValidate()
            begin
                /*"Amount Including VAT" := ROUND("Amount Including VAT",Currency."Amount Rounding Precision");
                CASE "VAT Calculation Type" OF
                  "VAT Calculation Type"::"Normal VAT",
                  "VAT Calculation Type"::"Reverse Charge VAT":
                    BEGIN
                      Amount :=
                        ROUND(
                          "Amount Including VAT" /
                          (1 + (1 - SalesHeader."VAT Base Discount %" / 100) * "VAT %" / 100),
                          Currency."Amount Rounding Precision");
                      "VAT Base Amount" :=
                        ROUND(Amount * (1 - SalesHeader."VAT Base Discount %" / 100),Currency."Amount Rounding Precision");
                    END;
                  "VAT Calculation Type"::"Full VAT":
                    BEGIN
                      Amount := 0;
                      "VAT Base Amount" := 0;
                    END;
                  "VAT Calculation Type"::"Sales Tax":
                    BEGIN
                      SalesHeader.TESTFIELD("VAT Base Discount %",0);
                      Amount :=
                        SalesTaxCalculate.ReverseCalculateTax(
                          "Tax Area Code","Tax Group Code","Tax Liable",SalesHeader."Posting Date",
                          "Amount Including VAT","Quantity (Base)",SalesHeader."Currency Factor");
                      IF Amount <> 0 THEN
                        "VAT %" :=
                          ROUND(100 * ("Amount Including VAT" - Amount) / Amount,0.00001)
                      ELSE
                        "VAT %" := 0;
                      Amount := ROUND(Amount,Currency."Amount Rounding Precision");
                      "VAT Base Amount" := Amount;
                    END;
                END;
                
                InitOutstandingAmount;
                */

            end;
        }
        field(40; "VAT Calculation Type"; Option)
        {
            Caption = 'VAT Calculation Type';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = 'Normal VAT,Reverse Charge VAT,Full VAT,Sales Tax';
            OptionMembers = "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
        }
        field(41; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";

            trigger OnValidate()
            begin
                //-NPR5.30 [262923]
                Validate("VAT Prod. Posting Group");
                //+NPR5.30 [262923]
            end;
        }
        field(42; "VAT Prod. Posting Group"; Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";

            trigger OnValidate()
            var
                POSTaxCalculation: Codeunit "NPR POS Tax Calculation";
                Handled: Boolean;
            begin
                //-NPR5.30 [262923]
                VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group");
                //-NPR5.51 [358985]
                POSTaxCalculation.OnGetVATPostingSetup(VATPostingSetup, Handled);
                //+NPR5.51 [358985]
                "VAT %" := VATPostingSetup."VAT %";
                "VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                "VAT Identifier" := VATPostingSetup."VAT Identifier";

                CalcAmounts;
                //+NPR5.30 [262923]
            end;
        }
        field(43; "VAT Identifier"; Code[10])
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

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        //-NPR5.26
        //-NPR5.30 [262923]
        //IF CALCFIELDS("Qty Posted") THEN
        //    ERROR(NPRText001);

        if CalcFields("Qty Posted") then begin
            if "Qty Posted" > 0 then
                Error(NPRText001);
        end;
        //+NPR5.30 [262923]
        //+NPR5.26
    end;

    var
        NPRText001: Label 'Posted Entries Exist.';
        VATPostingSetup: Record "VAT Posting Setup";
        CustomerRepair: Record "NPR Customer Repair";
        Customer: Record Customer;

    local procedure CalcAmounts()
    begin

        //-NPR5.30 [262923]
        "VAT Amount" := "Unit Price Excl. VAT" * Quantity * ("VAT %" / 100);
        Amount := "Unit Price Excl. VAT" * Quantity;
        "Amount Including VAT" := Amount + "VAT Amount";
        //+NPR5.30 [262923]
    end;
}

