page 6014532 "NPR POS Sale Tax"
{
    Extensible = False;
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

                    Caption = 'Tax Calculation Type';
                    ToolTip = 'Specifies value of the field Tax Calculation Type.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Source Prices Including Tax"; Rec."Source Prices Including Tax")
                {

                    Caption = 'Prices Including Tax';
                    ToolTip = 'Specifies value of Prices Including Tax from source.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Source Unit Price"; Rec."Source Unit Price")
                {

                    ToolTip = 'Specifies unit price from source';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Source Tax Group Code"; Rec."Source Tax Group Code")
                {

                    Caption = 'Tax Group Code';
                    ToolTip = 'Specifies value of the field Tax Group.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Source Tax Area Code"; Rec."Source Tax Area Code")
                {

                    Caption = 'Tax Area Code';
                    ToolTip = 'Specifies value of the field Tax Area.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Tax Group Type"; Rec."Tax Group Type")
                {

                    ToolTip = 'Specifies how tax calculation will be grouped. E.g. by tax area or tax jurisdiction.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Tax Area Code for Key"; Rec."Tax Area Code for Key")
                {

                    ToolTip = 'Specifies how tax calculation will be grouped. Value is set based on Tax Group Type';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Source Tax Liable"; Rec."Source Tax Liable")
                {

                    Caption = 'Tax Liable';
                    ToolTip = 'Specifies value of the field Tax Liable.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                group(Quantities)
                {
                    Caption = 'Quantities';

                    field("Source Quantity (Base)"; Rec."Source Quantity (Base)")
                    {

                        Caption = 'Quantity (Base)';
                        ToolTip = 'Specifies base quantity from source.';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                    field("Source Quantity"; Rec."Source Quantity")
                    {

                        Caption = 'Quantity';
                        ToolTip = 'Specifies quantity from source.';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                }
                group(SourceDiscounts)
                {
                    Caption = 'Discounts';

                    field("Source Allow Line Discount"; Rec."Source Allow Line Discount")
                    {

                        Caption = 'Allow Line Discount Amount';
                        ToolTip = 'Specifies if line discount is allowed.';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                    field("Source Discount %"; Rec."Source Discount %")
                    {

                        Caption = 'Discount %';
                        ToolTip = 'Specifies discount % from source.';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                    field("Source Discount Amount"; Rec."Source Discount Amount")
                    {

                        Caption = 'Discount Amount';
                        ToolTip = 'Specifies discount amount from source.';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            part(ActiveTaxAmountLines; "NPR POS Sale Tax Lines")
            {

                SubPageLink = "Source Rec. System Id" = FIELD("Source Rec. System Id");
                UpdatePropagation = Both;
                ApplicationArea = NPRRetail;
            }
            group(CalculationTaxDetails)
            {
                Caption = 'Calculation Tax Details';
                field("Source Rec. System Id"; Rec."Source Rec. System Id")
                {

                    Caption = 'Source Record System id';
                    ToolTip = 'Specifies unique value of source record from which tax calculation is created.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                group(Units)
                {
                    Caption = 'Units';

                    field("Calculated Price Excl. Tax"; Rec."Calculated Price Excl. Tax")
                    {

                        ToolTip = 'Specifies calculated price excluding tax';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                    field("Calculated Unit Tax"; Rec."Calculated Unit Tax")
                    {

                        ToolTip = 'Specifies calculated unit tax';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                    field("Calculated Price Incl. Tax"; Rec."Calculated Price Incl. Tax")
                    {

                        ToolTip = 'Specifies calculated price including tax';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                }
                group(CalculatedDiscounts)
                {
                    Caption = 'Discounts';

                    field("Calc. Applied Line Discount"; Rec."Calc. Applied Line Discount")
                    {

                        ToolTip = 'Specifies if line discount is applied on tax calculation.';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                    field("Calculated Discount %"; Rec."Calculated Discount %")
                    {

                        Caption = 'Discount %';
                        ToolTip = 'Specifies discount % if line discount is applied.';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                    field("Calculated Discount Amount"; Rec."Calculated Discount Amount")
                    {

                        Caption = 'Discount Amount';
                        ToolTip = 'Specifies discount amount if line discount is applied.';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Amounts)
                {
                    Caption = 'Amounts';

                    field("Calculated Line Amount"; Rec."Calculated Line Amount")
                    {

                        ToolTip = 'Specifies calculated line amount';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                    field("Calculated Amount Excl. Tax"; Rec."Calculated Amount Excl. Tax")
                    {

                        ToolTip = 'Specifies calculated amount excluding tax';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                    field("Calculated Tax Amount"; Rec."Calculated Tax Amount")
                    {

                        ToolTip = 'Specifies calculated tax amount';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                    field("Calculated Tax %"; Rec."Calculated Tax %")
                    {

                        ToolTip = 'Specifies calculated tax %';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                    field("Calculated Amount Incl. Tax"; Rec."Calculated Amount Incl. Tax")
                    {

                        ToolTip = 'Specifies calculated amount including tax';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }
}
