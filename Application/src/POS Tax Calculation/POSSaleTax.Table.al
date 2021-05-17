table 6014570 "NPR POS Sale Tax"
{
    DataClassification = CustomerContent;
    Caption = 'POS Sale Tax';
    LookupPageId = "NPR POS Sale Tax List";
    DrillDownPageId = "NPR POS Sale Tax List";
    fields
    {
        field(1; "Source Rec. System Id"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Source Record System Id';
        }
        field(2; "Source Amount"; Decimal)
        {
            Caption = 'Source Amount';
            DataClassification = CustomerContent;
        }
        field(3; "Source Prices Including Tax"; Boolean)
        {
            Caption = 'Source Prices Including Tax';
            DataClassification = CustomerContent;
        }
        field(4; "Source Tax Liable"; Boolean)
        {
            Caption = 'Source Tax Liable';
            DataClassification = CustomerContent;
        }
        field(5; "Source Tax Group Code"; Code[20])
        {
            Caption = 'Source Tax Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Group";
        }
        field(6; "Source Tax Area Code"; Code[20])
        {
            Caption = 'Source Tax Area Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Area";
        }
        field(7; "Source Quantity (Base)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Source Quantity (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(8; "Source Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Source Quantity';
            DecimalPlaces = 0 : 5;
            MaxValue = 99.999;
        }
        field(9; "Source Unit Price"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Source Unit Price';
            AutoFormatExpression = "Source Currency Code";
            AutoFormatType = 2;
        }
        field(10; "Source Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(11; "Source Currency Factor"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            MinValue = 0;
        }
        field(12; "Source Tax Calc. Type"; Enum "NPR POS Tax Calc. Type")
        {
            Caption = 'Source Tax Calculation Type';
            DataClassification = CustomerContent;
        }
        field(13; "Source Is Positive Amount"; Boolean)
        {
            Caption = 'Source Is Positive Amount';
            DataClassification = CustomerContent;
        }
        field(14; "Source Posting Date"; Date)
        {
            Caption = 'Source Posting Date';
            DataClassification = CustomerContent;
        }
        field(15; "Source Line Amount"; Decimal)
        {
            Caption = 'Source Line Amount';
            DataClassification = CustomerContent;
            AutoFormatExpression = "Source Currency Code";
            AutoFormatType = 1;
        }
        field(16; "Source Discount %"; Decimal)
        {
            Caption = 'Source Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 1;
            MaxValue = 100;
            MinValue = 0;
        }
        field(17; "Source Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Source Currency Code";
            AutoFormatType = 1;
            Caption = 'Source Discount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(18; "Source Table Caption"; Text[250])
        {
            Caption = 'Source Table Caption';
            DataClassification = CustomerContent;
        }
        field(19; "Source Tax Identifier"; Code[20])
        {
            Caption = 'Tax Identifier';
            DataClassification = CustomerContent;
        }
        field(20; "Source Tax %"; Decimal)
        {
            Caption = 'Source Tax %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(21; "Source Invoice Disc. Amount"; Decimal)
        {
            AutoFormatExpression = "Source Currency Code";
            AutoFormatType = 1;
            Caption = 'Source Invoice Discount Amount';
            DataClassification = CustomerContent;
        }
        field(22; "Source Allow Invoice Discount"; Boolean)
        {
            Caption = 'Source Allow Invoice Discount';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(23; "Source Allow Line Discount"; Boolean)
        {
            Caption = 'Source Allow Line Discount';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(100; "Calculated Amount Excl. Tax"; Decimal)
        {
            Caption = 'Calculated Amount Excl. Tax';
            DataClassification = CustomerContent;
            AutoFormatExpression = "Source Currency Code";
            AutoFormatType = 1;
        }
        field(101; "Calculated Amount Incl. Tax"; Decimal)
        {
            Caption = 'Calculated Amount Incl. Tax';
            DataClassification = CustomerContent;
            AutoFormatExpression = "Source Currency Code";
            AutoFormatType = 1;
        }
        field(102; "Calculated Price Excl. Tax"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Calculated Unit Price Excl. Tax';
            AutoFormatExpression = "Source Currency Code";
            AutoFormatType = 2;
        }
        field(103; "Calculated Price Incl. Tax"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Calculated Unit Price Incl. Tax';
            AutoFormatExpression = "Source Currency Code";
            AutoFormatType = 2;
        }
        field(104; "Calculated Unit Tax"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Calculated Unit Tax';
            AutoFormatExpression = "Source Currency Code";
            AutoFormatType = 2;
        }
        field(105; "Calculated Tax Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Calculated Unit Tax';
            AutoFormatExpression = "Source Currency Code";
            AutoFormatType = 1;
        }
        field(106; "Tax Area Code for Key"; Code[20])
        {
            Caption = 'Tax Area Code for Key';
            DataClassification = CustomerContent;
            TableRelation = "Tax Area";
        }
        field(107; "Tax Group Type"; Enum "NPR POS Tax Group Type")
        {
            Caption = 'Tax Group Type';
            DataClassification = CustomerContent;
        }
        field(108; "Calculated Tax %"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Calculated Tax %';
            DecimalPlaces = 0 : 5;
        }
        field(109; "Calculated Discount %"; Decimal)
        {
            Caption = 'Calculated Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 1;
            MaxValue = 100;
            MinValue = 0;
        }
        field(110; "Calculated Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Source Currency Code";
            AutoFormatType = 1;
            Caption = 'Calculated Discount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(111; "Calculated Inv. Disc. Amount"; Decimal)
        {
            AutoFormatExpression = "Source Currency Code";
            AutoFormatType = 1;
            Caption = 'Calculated Inv. Disc. Amount';
            DataClassification = CustomerContent;
        }
        field(112; "Calc. Applied Invoice Discount"; Boolean)
        {
            Caption = 'Applied Invoice Discount';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(113; "Calc. Applied Line Discount"; Boolean)
        {
            Caption = 'Applied Line Discount';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(46; "Calculated Line Amount"; Decimal)
        {
            Caption = 'Calculated Line Amount';
            DataClassification = CustomerContent;
            AutoFormatExpression = "Source Currency Code";
            AutoFormatType = 1;
        }
    }

    keys
    {
        key(PK; "Source Rec. System Id")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
    begin
        POSSaleTaxCalc.DeleteAllLines(Rec);
    end;

    trigger OnRename()
    var
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
    begin
        POSSaleTaxCalc.RenameNotAllowed();
    end;

    procedure CopyFromSource(SaleLinePOS: Record "NPR POS Sale Line")
    begin
        "Source Prices Including Tax" := SaleLinePOS."Price Includes VAT";
        "Source Posting Date" := SaleLinePOS.Date;
        "Source Table Caption" := CopyStr(SaleLinePOS.TableCaption(), 1, MaxStrLen(Rec."Source Table Caption"));
        "Source Quantity (Base)" := SaleLinePOS."Quantity (Base)";
        "Source Quantity" := SaleLinePOS."Quantity";
        "Source Unit Price" := SaleLinePOS."Unit Price";
        "Source Currency Code" := SaleLinePOS."Currency Code";
        "Source Tax Identifier" := SaleLinePOS."VAT Identifier";
        "SOurce Tax %" := SaleLinePOS."VAT %";
        "Source Allow Invoice Discount" := SaleLinePOS."Allow Invoice Discount";
        "Source Allow Line Discount" := SaleLinePOS."Allow Line Discount";

        OnAfterCopyFromSource(SaleLinePOS);
    end;

    procedure CopyFromSourceAmounts(SaleLinePOS: Record "NPR POS Sale Line")
    begin
        "Source Discount %" := SaleLinePOS."Discount %";
        "Source Discount Amount" := SaleLinePOS."Discount Amount";
        "Source Line Amount" := SaleLinePOS."Line Amount";
        "Source Is Positive Amount" := SaleLinePOS."Line Amount" > 0;
        "Source Invoice Disc. Amount" := SaleLinePOS."Invoice Discount Amount";

        OnAfterCopyFromSourceAmounts(SaleLinePOS);
    end;

    procedure GetHandler(var POSTaxCalc: Interface "NPR POS ITaxCalc")
    begin
        POSTaxCalc := "Source Tax Calc. Type";
    end;

    procedure SetTaxCalcTypeFromSource(SaleLinePOS: Record "NPR POS Sale Line")
    var
        Handled: Boolean;
        UnknownTaxCalculationTypeErr: Label 'Unknown Tax Calculation Type: %1 %2';
    begin
        case SaleLinePOS."VAT Calculation Type" of
            SaleLinePOS."VAT Calculation Type"::"Full VAT":
                "Source Tax Calc. Type" := "Source Tax Calc. Type"::"Full VAT";
            SaleLinePOS."VAT Calculation Type"::"Normal VAT":
                "Source Tax Calc. Type" := "Source Tax Calc. Type"::"Normal VAT";
            SaleLinePOS."VAT Calculation Type"::"Reverse Charge VAT":
                "Source Tax Calc. Type" := "Source Tax Calc. Type"::"Reverse Charge VAT";
            SaleLinePOS."VAT Calculation Type"::"Sales Tax":
                "Source Tax Calc. Type" := "Source Tax Calc. Type"::"Sales Tax";
            else begin
                    OnSetTaxCalcType(Handled);
                    if not Handled then
                        error(UnknownTaxCalculationTypeErr,
                                FieldCaption("Source Tax Calc. Type"), "Source Tax Calc. Type");
                end;
        end;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterCopyFromSource(SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterCopyFromSourceAmounts(SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnSetTaxCalcType(var Handled: Boolean)
    begin
    end;
}