page 6014541 "NPR POS Sale Tax List"
{
    PageType = List;

    UsageCategory = Lists;
    Editable = false;
    SourceTable = "NPR POS Sale Tax";
    Caption = 'POS Sale Tax List';
    CardPageId = "NPR POS Sale Tax";
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Source Rec. System Id"; Rec."Source Rec. System Id")
                {

                    Caption = 'Source Record System id';
                    ToolTip = 'Specifies unique value of source record from which tax calculation is created.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Source Tax Calc. Type"; Rec."Source Tax Calc. Type")
                {

                    Caption = 'Tax Calculation Type';
                    ToolTip = 'Specifies value of the field Tax Calculation Type.';
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
                field("Source Prices Including Tax"; Rec."Source Prices Including Tax")
                {

                    Caption = 'Prices Including Tax';
                    ToolTip = 'Specifies value of Prices Including Tax from source.';
                    Visible = false;
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Calculated Price Excl. Tax"; Rec."Calculated Price Excl. Tax")
                {

                    ToolTip = 'Specifies how tax calculation will be grouped. Value is set based on Tax Group Type';
                    ApplicationArea = NPRRetail;
                }
                field("Calculated Price Incl. Tax"; Rec."Calculated Price Incl. Tax")
                {

                    ToolTip = 'Specifies how tax calculation will be grouped. Value is set based on Tax Group Type';
                    ApplicationArea = NPRRetail;
                }
                field("Source Quantity (Base)"; Rec."Source Quantity (Base)")
                {

                    Caption = 'Quantity (Base)';
                    ToolTip = 'Specifies base quantity from source.';
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
                field("Calculated Amount Excl. Tax"; Rec."Calculated Amount Excl. Tax")
                {

                    ToolTip = 'Specifies how tax calculation will be grouped. Value is set based on Tax Group Type';
                    ApplicationArea = NPRRetail;
                }
                field("Calculated Amount Incl. Tax"; Rec."Calculated Amount Incl. Tax")
                {

                    ToolTip = 'Specifies how tax calculation will be grouped. Value is set based on Tax Group Type';
                    ApplicationArea = NPRRetail;
                }
                field("Calculated Unit Tax"; Rec."Calculated Unit Tax")
                {

                    ToolTip = 'Specifies how tax calculation will be grouped. Value is set based on Tax Group Type';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}