table 6150623 "NPR POS Entry Payment Line"
{
    Caption = 'POS Entry Payment Line';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Entry Pmt. Line List";
    LookupPageID = "NPR POS Entry Pmt. Line List";

    fields
    {
        field(1; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry";
        }
        field(3; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
        }
        field(4; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(7; "POS Period Register No."; Integer)
        {
            Caption = 'POS Period Register No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            TableRelation = "NPR POS Period Register";
        }
        field(10; "POS Payment Method Code"; Code[10])
        {
            Caption = 'POS Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(11; "POS Payment Bin Code"; Code[10])
        {
            Caption = 'POS Payment Bin Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin";
        }
        field(14; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(31; "Payment Fee %"; Decimal)
        {
            Caption = 'Payment Fee %';
            DataClassification = CustomerContent;
        }
        field(32; "Payment Fee Amount"; Decimal)
        {
            Caption = 'Payment Fee Amount';
            DataClassification = CustomerContent;
        }
        field(33; "Payment Amount"; Decimal)
        {
            Caption = 'Payment Amount';
            DataClassification = CustomerContent;
        }
        field(34; "Payment Fee % (Non-invoiced)"; Decimal)
        {
            Caption = 'Payment Fee % (Non-invoiced)';
            DataClassification = CustomerContent;
        }
        field(35; "Payment Fee Amount (Non-inv.)"; Decimal)
        {
            Caption = 'Payment Fee Amount (Non-inv.)';
            DataClassification = CustomerContent;
        }
        field(39; "Currency Code"; Code[10])
        {
            Caption = 'Paid Currency Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            TableRelation = Currency;
        }
        field(40; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(41; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(50; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(51; "Amount (Sales Currency)"; Decimal)
        {
            Caption = 'Amount (Sales Currency)';
            DataClassification = CustomerContent;
        }
        field(55; "Rounding Amount"; Decimal)
        {
            Caption = 'Rounding Amount';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
        }
        field(56; "Rounding Amount (Sales Curr.)"; Decimal)
        {
            Caption = 'Rounding Amount (Sales Curr.)';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
        }
        field(57; "Rounding Amount (LCY)"; Decimal)
        {
            Caption = 'Rounding Amount (LCY)';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
        }
        field(77; "VAT Calculation Type"; Enum "Tax Calculation Type")
        {
            Caption = 'VAT Calculation Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(84; "Gen. Posting Type"; Option)
        {
            Caption = 'Gen. Posting Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Purchase,Sale';
            OptionMembers = " ",Purchase,Sale;
        }
        field(85; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Area";
        }
        field(86; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
        }
        field(87; "Tax Group Code"; Code[20])
        {
            Caption = 'Tax Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Group";
        }
        field(88; "Use Tax"; Boolean)
        {
            Caption = 'Use Tax';
            DataClassification = CustomerContent;
        }
        field(90; "Applies-to Doc. Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Applies-to Doc. Type';
            DataClassification = CustomerContent;
        }
        field(91; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(92; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(95; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(96; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }
        field(98; "VAT Amount (LCY)"; Decimal)
        {
            Caption = 'VAT Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(99; "VAT Base Amount (LCY)"; Decimal)
        {
            Caption = 'VAT Base Amount';
            DataClassification = CustomerContent;
        }
        field(106; "VAT Identifier"; Code[20])
        {
            Caption = 'VAT Identifier';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            Editable = false;
        }
        field(160; "Orig. POS Sale ID"; Integer)
        {
            Caption = 'Orig. POS Sale ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.32';
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced by SystemID';
        }
        field(161; "Orig. POS Line No."; Integer)
        {
            Caption = 'Orig. POS Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.32';
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced by SystemID';
        }
        field(170; "Retail ID"; Guid)
        {
            Caption = 'Retail ID';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced by SystemID';
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
        field(500; EFT; Boolean)
        {
            Caption = 'EFT';
            DataClassification = CustomerContent;
        }
        field(501; "EFT Refundable"; Boolean)
        {
            Caption = 'EFT Refundable';
            DataClassification = CustomerContent;
        }
        field(502; Token; Text[50])
        {
            Caption = 'Token';
            DataClassification = CustomerContent;
        }
        field(600; "Entry Date"; Date)
        {
            CalcFormula = Lookup("NPR POS Entry"."Entry Date" WHERE("Entry No." = FIELD("POS Entry No.")));
            Caption = 'Entry Date';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(610; "Starting Time"; Time)
        {
            CalcFormula = Lookup("NPR POS Entry"."Starting Time" WHERE("Entry No." = FIELD("POS Entry No.")));
            Caption = 'Starting Time';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(620; "Ending Time"; Time)
        {
            CalcFormula = Lookup("NPR POS Entry"."Ending Time" WHERE("Entry No." = FIELD("POS Entry No.")));
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

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.Get("POS Entry No.");
        if ((POSEntry."Post Entry Status" = POSEntry."Post Entry Status"::Posted) and (POSEntry."Post Item Entry Status" = POSEntry."Post Item Entry Status"::Posted)) then begin
            DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2 %3', TableCaption, "POS Entry No.", "Line No."));
        end else begin
            "Dimension Set ID" :=
              DimMgt.EditDimensionSet(
                "Dimension Set ID", StrSubstNo('%1 %2 %3', TableCaption, "POS Entry No.", "Line No."), "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            Modify();
        end;
    end;
}

