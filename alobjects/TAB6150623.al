table 6150623 "POS Payment Line"
{
    // NPR5.29/AP/20170126 CASE 262628 Recreated ENU-captions
    // NPR5.30/AP/20170209 CASE 261728 Renamed field "Store Code" -> "POS Store Code"
    // NPR5.32/AP/20170220 CASE 262628 Renamed field "Receipt No." -> "Document No."
    // NPR5.36/AP/20170717 CASE 262628 Added "POS Ledg. Register No."
    // NPR5.36/BR/20170810 CASE 277096 Filled LookupPageID and DrillDownPageID
    // NPR5.38/BR/20171108 CASE 294747 Added function ShowDimensions
    // NPR5.38/BR/20171108 CASE 294718 Added fields Applies-to Doc. Type and Applies-to Doc. No.
    // NPR5.38/BR/20171108 CASE 294720 Added External Document No.
    // NPR5.38/BR/20171214 CASE 299888 Renamed from POS Ledg. Register No. to POS Period Register No. (incl. Captions)
    // NPR5.42/TSA /20180511 CASE 314834 Dimensions are editable when entry is unposted
    // NPR5.50/TSA /20190520 CASE 354832 Added VAT related fields 84-106 for reversing unrealized VAT when using a voucher with preliminary VAT
    // NPR5.53/SARA/20191024 CASE 373672 Added Field 600..620
    // NPR5.54/MMV /20200220 CASE 391871 Added field "Retail ID" for payment lines.
    // NPR5.54/ALPO/20200324 CASE 397063 Global dimensions were not updated on assigned dimension change through ShowDimensions() function ("Dimensions" button)

    Caption = 'POS Payment Line';
    DrillDownPageID = "POS Payment Line List";
    LookupPageID = "POS Payment Line List";

    fields
    {
        field(1; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            TableRelation = "POS Entry";
        }
        field(3; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            TableRelation = "POS Store";
        }
        field(4; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            TableRelation = "POS Unit";
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(7; "POS Period Register No."; Integer)
        {
            Caption = 'POS Period Register No.';
            Description = 'NPR5.36';
            TableRelation = "POS Period Register";
        }
        field(10; "POS Payment Method Code"; Code[10])
        {
            Caption = 'POS Payment Method Code';
            TableRelation = "POS Payment Method";
        }
        field(11; "POS Payment Bin Code"; Code[10])
        {
            Caption = 'POS Payment Bin Code';
            TableRelation = "POS Payment Bin";
        }
        field(14; Description; Text[80])
        {
            Caption = 'Description';
        }
        field(30; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(31; "Payment Fee %"; Decimal)
        {
            Caption = 'Payment Fee %';
        }
        field(32; "Payment Fee Amount"; Decimal)
        {
            Caption = 'Payment Fee Amount';
        }
        field(33; "Payment Amount"; Decimal)
        {
            Caption = 'Payment Amount';
        }
        field(34; "Payment Fee % (Non-invoiced)"; Decimal)
        {
            Caption = 'Payment Fee % (Non-invoiced)';
        }
        field(35; "Payment Fee Amount (Non-inv.)"; Decimal)
        {
            Caption = 'Payment Fee Amount (Non-inv.)';
        }
        field(39; "Currency Code"; Code[10])
        {
            Caption = 'Paid Currency Code';
            Description = 'NPR5.36';
            TableRelation = Currency;
        }
        field(40; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(41; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(50; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
        }
        field(51; "Amount (Sales Currency)"; Decimal)
        {
            Caption = 'Amount (Sales Currency)';
        }
        field(55; "Rounding Amount"; Decimal)
        {
            Caption = 'Rounding Amount';
            Description = 'NPR5.36';
        }
        field(56; "Rounding Amount (Sales Curr.)"; Decimal)
        {
            Caption = 'Rounding Amount (Sales Curr.)';
            Description = 'NPR5.36';
        }
        field(57; "Rounding Amount (LCY)"; Decimal)
        {
            Caption = 'Rounding Amount (LCY)';
            Description = 'NPR5.36';
        }
        field(77; "VAT Calculation Type"; Option)
        {
            Caption = 'VAT Calculation Type';
            Description = 'NPR5.36';
            Editable = false;
            OptionCaption = 'Normal VAT,Reverse Charge VAT,Full VAT,Sales Tax';
            OptionMembers = "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
        }
        field(84; "Gen. Posting Type"; Option)
        {
            Caption = 'Gen. Posting Type';
            OptionCaption = ' ,Purchase,Sale';
            OptionMembers = " ",Purchase,Sale;
        }
        field(85; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            TableRelation = "Tax Area";
        }
        field(86; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
        }
        field(87; "Tax Group Code"; Code[10])
        {
            Caption = 'Tax Group Code';
            TableRelation = "Tax Group";
        }
        field(88; "Use Tax"; Boolean)
        {
            Caption = 'Use Tax';
        }
        field(90; "Applies-to Doc. Type"; Option)
        {
            Caption = 'Applies-to Doc. Type';
            Description = 'NPR5.38';
            OptionCaption = ' ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund';
            OptionMembers = " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund;
        }
        field(91; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
            Description = 'NPR5.38';
        }
        field(92; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            Description = 'NPR5.38';
        }
        field(95; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(96; "VAT Prod. Posting Group"; Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(98; "VAT Amount (LCY)"; Decimal)
        {
            Caption = 'VAT Amount (LCY)';
        }
        field(99; "VAT Base Amount (LCY)"; Decimal)
        {
            Caption = 'VAT Base Amount';
        }
        field(106; "VAT Identifier"; Code[10])
        {
            Caption = 'VAT Identifier';
            Description = 'NPR5.36';
            Editable = false;
        }
        field(160; "Orig. POS Sale ID"; Integer)
        {
            Caption = 'Orig. POS Sale ID';
            Description = 'NPR5.32';
        }
        field(161; "Orig. POS Line No."; Integer)
        {
            Caption = 'Orig. POS Line No.';
            Description = 'NPR5.32';
        }
        field(170; "Retail ID"; Guid)
        {
            Caption = 'Retail ID';
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                //-NPR5.38 [294747]
                ShowDimensions;
                //+NPR5.38 [294747]
            end;
        }
        field(500; EFT; Boolean)
        {
            Caption = 'EFT';
        }
        field(501; "EFT Refundable"; Boolean)
        {
            Caption = 'EFT Refundable';
        }
        field(502; Token; Text[50])
        {
            Caption = 'Token';
        }
        field(600; "Entry Date"; Date)
        {
            CalcFormula = Lookup ("POS Entry"."Entry Date" WHERE("Entry No." = FIELD("POS Entry No.")));
            Caption = 'Entry Date';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(610; "Starting Time"; Time)
        {
            CalcFormula = Lookup ("POS Entry"."Starting Time" WHERE("Entry No." = FIELD("POS Entry No.")));
            Caption = 'Starting Time';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(620; "Ending Time"; Time)
        {
            CalcFormula = Lookup ("POS Entry"."Ending Time" WHERE("Entry No." = FIELD("POS Entry No.")));
            Caption = 'Ending Time';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "POS Entry No.", "Line No.")
        {
        }
        key(Key2; "Document No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        showdim: Integer;

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
        POSEntry: Record "POS Entry";
    begin

        //-NPR5.42 [314834]
        //-NPR5.38 [294717]
        // DimMgt.ShowDimensionSet("Dimension Set ID",STRSUBSTNO('%1 %2 - %3',TABLECAPTION,"POS Entry No.","Line No."));
        //+NPR5.38 [294717]

        POSEntry.Get("POS Entry No.");
        if ((POSEntry."Post Entry Status" = POSEntry."Post Entry Status"::Posted) and (POSEntry."Post Item Entry Status" = POSEntry."Post Item Entry Status"::Posted)) then begin
            DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2 %3', TableCaption, "POS Entry No.", "Line No."));
        end else begin
            //"Dimension Set ID" := DimMgt.EditDimensionSet ("Dimension Set ID",STRSUBSTNO('%1 %2 %3',TABLECAPTION,"POS Entry No.", "Line No."));  //NPR5.54 [397063]-revoked
            //-NPR5.54 [397063]
            "Dimension Set ID" :=
              DimMgt.EditDimensionSet(
                "Dimension Set ID", StrSubstNo('%1 %2 %3', TableCaption, "POS Entry No.", "Line No."), "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            //+NPR5.54 [397063]
            Modify();
        end;
        //+NPR5.42 [314834]
    end;
}

