page 6014532 "NPR POS Sale Tax"
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR POS Sale Tax";
    DataCaptionFields = "Source Table Caption";
    Caption = 'POS Sale Tax';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(SourceTaxDetails)
            {
                Caption = 'Source Tax Details';

                field("Source Tax Calc. Type"; Rec."Source Tax Calc. Type")
                {
                    ApplicationArea = All;
                    Caption = 'Tax Calculation Type';
                    ToolTip = 'Specifies value of the field Tax Calculation Type.';
                    Editable = false;
                }
                field("Source Prices Including Tax"; Rec."Source Prices Including Tax")
                {
                    ApplicationArea = All;
                    Caption = 'Prices Including Tax';
                    ToolTip = 'Specifies value of Prices Including Tax from source.';
                    Editable = false;
                }
                field("Source Unit Price"; Rec."Source Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies unit price from source';
                    Editable = false;
                }
                field("Source Tax Group Code"; Rec."Source Tax Group Code")
                {
                    ApplicationArea = All;
                    Caption = 'Tax Group Code';
                    ToolTip = 'Specifies value of the field Tax Group.';
                    Editable = false;
                }
                field("Source Tax Area Code"; Rec."Source Tax Area Code")
                {
                    ApplicationArea = All;
                    Caption = 'Tax Area Code';
                    ToolTip = 'Specifies value of the field Tax Area.';
                    Editable = false;
                }
                field("Tax Group Type"; Rec."Tax Group Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how tax calculation will be grouped. E.g. by tax area or tax jurisdiction.';
                    Editable = false;
                }
                field("Tax Area Code for Key"; Rec."Tax Area Code for Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how tax calculation will be grouped. Value is set based on Tax Group Type';
                    Editable = false;
                }
                field("Source Tax Liable"; Rec."Source Tax Liable")
                {
                    ApplicationArea = All;
                    Caption = 'Tax Liable';
                    ToolTip = 'Specifies value of the field Tax Liable.';
                    Editable = false;
                }
                group(Quantities)
                {
                    Caption = 'Quantities';

                    field("Source Quantity (Base)"; Rec."Source Quantity (Base)")
                    {
                        ApplicationArea = All;
                        Caption = 'Quantity (Base)';
                        ToolTip = 'Specifies base quantity from source.';
                        Editable = false;
                    }
                    field("Source Quantity"; Rec."Source Quantity")
                    {
                        ApplicationArea = All;
                        Caption = 'Quantity';
                        ToolTip = 'Specifies quantity from source.';
                        Editable = false;
                    }
                }
                group(SourceDiscounts)
                {
                    Caption = 'Discounts';

                    field("Source Allow Line Discount"; Rec."Source Allow Line Discount")
                    {
                        ApplicationArea = All;
                        Caption = 'Allow Line Discount Amount';
                        ToolTip = 'Specifies if line discount is allowed.';
                        Editable = false;
                    }
                    field("Source Discount %"; Rec."Source Discount %")
                    {
                        ApplicationArea = All;
                        Caption = 'Discount %';
                        ToolTip = 'Specifies discount % from source.';
                        Editable = false;
                    }
                    field("Source Discount Amount"; Rec."Source Discount Amount")
                    {
                        ApplicationArea = All;
                        Caption = 'Discount Amount';
                        ToolTip = 'Specifies discount amount from source.';
                        Editable = false;
                    }
                    field("Source Allow Invoice Discount"; Rec."Source Allow Invoice Discount")
                    {
                        ApplicationArea = All;
                        Caption = 'Allow Invoice Discount Amount';
                        ToolTip = 'Specifies if invoice discount is allowed.';
                        Editable = false;
                    }
                    field("Source Invoice Disc. Amount"; Rec."Source Invoice Disc. Amount")
                    {
                        ApplicationArea = All;
                        Caption = 'Invoice Discount Amount';
                        ToolTip = 'Specifies invoice discount amount from source.';
                        Editable = false;
                    }
                }
            }
            part(ActiveTaxAmountLines; "NPR POS Sale Tax Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Source Rec. System Id" = FIELD("Source Rec. System Id");
                UpdatePropagation = Both;
            }
            group(CalculationTaxDetails)
            {
                Caption = 'Calculation Tax Details';
                field("Source Rec. System Id"; Rec."Source Rec. System Id")
                {
                    ApplicationArea = Advanced;
                    Caption = 'Source Record System id';
                    ToolTip = 'Specifies unique value of source record from which tax calculation is created.';
                    Editable = false;
                }
                group(Units)
                {
                    Caption = 'Units';

                    field("Calculated Price Excl. Tax"; Rec."Calculated Price Excl. Tax")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies calculated price excluding tax';
                        Editable = false;
                    }
                    field("Calculated Unit Tax"; Rec."Calculated Unit Tax")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies calculated unit tax';
                        Editable = false;
                    }
                    field("Calculated Price Incl. Tax"; Rec."Calculated Price Incl. Tax")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies calculated price including tax';
                        Editable = false;
                    }
                }
                group(CalculatedDiscounts)
                {
                    Caption = 'Discounts';

                    field("Calc. Applied Line Discount"; Rec."Calc. Applied Line Discount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies if line discount is applied on tax calculation.';
                        Editable = false;
                    }
                    field("Calculated Discount %"; Rec."Calculated Discount %")
                    {
                        ApplicationArea = All;
                        Caption = 'Discount %';
                        ToolTip = 'Specifies discount % if line discount is applied.';
                        Editable = false;
                    }
                    field("Calculated Discount Amount"; Rec."Calculated Discount Amount")
                    {
                        ApplicationArea = All;
                        Caption = 'Discount Amount';
                        ToolTip = 'Specifies discount amount if line discount is applied.';
                        Editable = false;
                    }
                    field("Calc. Applied Invoice Discount"; Rec."Calc. Applied Invoice Discount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies if invoice discount is applied.';
                        Editable = false;
                    }
                    field("Calc. Invoice Disc. Amount"; Rec."Calculated Inv. Disc. Amount")
                    {
                        ApplicationArea = All;
                        Caption = 'Invoice Discount Amount';
                        ToolTip = 'Specifies invoice discount amount if invoice discount is applied.';
                        Editable = false;
                    }
                }
                group(Amounts)
                {
                    Caption = 'Amounts';

                    field("Calculated Line Amount"; Rec."Calculated Line Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies calculated line amount';
                        Editable = false;
                    }
                    field("Calculated Amount Excl. Tax"; Rec."Calculated Amount Excl. Tax")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies calculated amount excluding tax';
                        Editable = false;
                    }
                    field("Calculated Tax Amount"; Rec."Calculated Tax Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies calculated tax amount';
                        Editable = false;
                    }
                    field("Calculated Tax %"; Rec."Calculated Tax %")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies calculated tax %';
                        Editable = false;
                    }
                    field("Calculated Amount Incl. Tax"; Rec."Calculated Amount Incl. Tax")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies calculated amount including tax';
                        Editable = false;
                    }
                }
            }
        }
    }
}