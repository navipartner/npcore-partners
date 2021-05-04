table 6014571 "NPR POS Sale Tax Line"
{
    DataClassification = CustomerContent;
    Caption = 'POS Sale Tax Line';

    fields
    {
        field(1; "Source Rec. System Id"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Source Record System Id';
        }
        field(2; "Tax Area Code for Key"; Code[20])
        {
            Caption = 'Tax Area Code for Key';
            DataClassification = CustomerContent;
            TableRelation = "Tax Area";
        }
        field(4; "Tax Jurisdiction Code"; Code[10])
        {
            Caption = 'Tax Jurisdiction Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Jurisdiction";
        }
        field(5; Positive; Boolean)
        {
            Caption = 'Positive';
            DataClassification = CustomerContent;
        }
        field(6; "Tax Type"; Enum "NPR POS Tax Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Tax Type';
            NotBlank = false;
        }
        field(20; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Area";
        }
        field(21; "Tax Calculation Type"; Enum "NPR POS Tax Calc. Type")
        {
            Caption = 'Tax Calculation Type';
            DataClassification = CustomerContent;
        }
        field(22; "Round Tax"; Option)
        {
            Caption = 'Round Tax';
            DataClassification = CustomerContent;
            OptionCaption = 'To Nearest,Up,Down';
            OptionMembers = "To Nearest",Up,Down;
        }
        field(23; "Is Report-to Jurisdiction"; Boolean)
        {
            Caption = 'Is Report-to Jurisdiction';
            DataClassification = CustomerContent;
        }
        field(24; "Print Order"; Integer)
        {
            Caption = 'Print Order';
            DataClassification = CustomerContent;
        }
        field(25; "Print Description"; Text[100])
        {
            Caption = 'Print Description';
            DataClassification = CustomerContent;
        }
        field(26; "Calculation Order"; Integer)
        {
            Caption = 'Calculation Order';
            DataClassification = CustomerContent;
        }
        field(27; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
        }
        field(28; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(29; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(30; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(31; "Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Discount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(32; "Tax Calc. Type"; Enum "Tax Calculation Type")
        {
            Caption = 'Tax Calculation Type';
            DataClassification = CustomerContent;
        }
        field(34; "Tax %"; Decimal)
        {
            Caption = 'Tax %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(35; "Unit Tax"; Decimal)
        {
            Caption = 'Unit Tax';
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
        }
        field(36; "Tax Group Code"; Code[20])
        {
            Caption = 'Tax Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Group";
        }
        field(37; "Unit Price Excl. Tax"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price Excl. Tax';
        }
        field(38; "Unit Price Incl. Tax"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price Incl. Tax';
        }
        field(39; "Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(40; "Calculate Tax on Tax"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Calculate Tax on Tax';
            TableRelation = Currency;
        }
        field(41; "Tax Group Type"; Enum "NPR POS Tax Group Type")
        {
            Caption = 'Tax Group Type';
            DataClassification = CustomerContent;
        }
        field(42; "Amount Excl. Tax"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Unit Price Excl. Tax';
        }
        field(43; "Amount Incl. Tax"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Unit Price Incl. Tax';
        }
        field(44; "Tax Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Unit Price Incl. Tax';
        }
        field(45; "Tax Identifier"; Code[20])
        {
            Caption = 'Tax Identifier';
            DataClassification = CustomerContent;
        }
        field(46; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
        }
        field(47; "Use Tax"; Boolean)
        {
            Caption = 'Use Tax';
            DataClassification = CustomerContent;
        }
        field(48; "Invoice Disc. Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Invoice Discount Amount';
            DataClassification = CustomerContent;
        }
        field(49; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 1;
            MaxValue = 100;
            MinValue = 0;
        }
        field(50; "Allow Invoice Discount"; Boolean)
        {
            Caption = 'Allow Invoice Discount';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(51; "Allow Line Discount"; Boolean)
        {
            Caption = 'Allow Line Discount';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(52; "Applied Invoice Discount"; Boolean)
        {
            Caption = 'Applied Invoice Discount';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(53; "Applied Line Discount"; Boolean)
        {
            Caption = 'Applied Line Discount';
            DataClassification = CustomerContent;
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Source Rec. System Id", "Tax Area Code for Key", "Tax Jurisdiction Code", "Tax Type", Positive, "Tax Identifier", "Tax Group Code", "Use Tax")
        {
            Clustered = true;
        }
    }

    procedure FindLine(POSSaleTax: Record "NPR POS Sale Tax"; TaxAreaLine: Record "Tax Area Line"; TaxDetail: Record "Tax Detail"): Boolean
    begin
        Rec."Source Rec. System Id" := POSSaleTax."Source Rec. System Id";
        Rec."Tax Area Code for Key" := POSSaleTax."Tax Area Code for Key";
        Rec."Tax Jurisdiction Code" := TaxAreaLine."Tax Jurisdiction Code";
        case TaxDetail."Tax Type" of
            0: //"Sales Tax" for W1; "Sales and Use Tax" for US
                Rec."Tax Type" := Rec."Tax Type"::"Sales Tax";
            TaxDetail."Tax Type"::"Excise Tax":
                Rec."Tax Type" := Rec."Tax Type"::"Excise Tax";
        end;
        Rec.Positive := POSSaleTax."Source Is Positive Amount";
        Rec."Tax Identifier" := POSSaleTax."Source Tax Identifier";
        Rec."Use Tax" := false;
        exit(Rec.Find());
    end;

    procedure FindLine(POSSaleTax: Record "NPR POS Sale Tax"; TaxType: Enum "NPR POS Tax Type"; UseTax: Boolean): Boolean
    begin
        Rec."Source Rec. System Id" := POSSaleTax."Source Rec. System Id";
        Rec."Tax Type" := TaxType;
        Rec.Positive := POSSaleTax."Source Is Positive Amount";
        Rec."Tax Identifier" := POSSaleTax."Source Tax Identifier";
        Rec."Use Tax" := UseTax;
        exit(Rec.Find());
    end;

    procedure CopyFromHeader(POSSaleTax: Record "NPR POS Sale Tax")
    begin
        "Quantity (Base)" := POSSaleTax."Source Quantity (Base)";
        Quantity := POSSaleTax."Source Quantity";
        if POSSaleTax."Source Prices Including Tax" then
            "Unit Price Incl. Tax" := POSSaleTax."Source Unit Price"
        else
            "Unit Price Excl. Tax" := POSSaleTax."Source Unit Price";
        "Line Amount" := POSSaleTax."Source Line Amount";
        "Discount %" := POSSaleTax."Source Discount %";
        "Invoice Disc. Amount" := POSSaleTax."Source Invoice Disc. Amount";
        "Discount Amount" := POSSaleTax."Source Discount Amount";
        "Allow Line Discount" := POSSaleTax."Source Allow Line Discount";
        "Allow Invoice Discount" := POSSaleTax."Source Allow Invoice Discount";
        "Tax Group Code" := POSSaleTax."Source Tax Group Code";
        "Tax Calculation Type" := POSSaleTax."Source Tax Calc. Type";
        "Tax Area Code" := POSSaleTax."Source Tax Area Code";
        "Tax Liable" := POSSaleTax."Source Tax Liable";
        "Posting Date" := POSSaleTax."Source Posting Date";
        "Tax Group Type" := POSSaleTax."Tax Group Type";
        "Tax Area Code for Key" := POSSaleTax."Tax Area Code for Key";
        "Tax Calc. Type" := POSSaleTax."Source Tax Calc. Type";
        "Tax %" := POSSaleTax."Source Tax %";
        "Currency Code" := POSSaleTax."Source Currency Code";

        OnAfterCopyFromHeader(POSSaleTax);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterCopyFromHeader(POSSaleTax: Record "NPR POS Sale Tax")
    begin
    end;
}