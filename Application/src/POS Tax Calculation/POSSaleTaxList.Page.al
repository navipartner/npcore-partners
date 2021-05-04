page 6014541 "NPR POS Sale Tax List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    SourceTable = "NPR POS Sale Tax";
    Caption = 'POS Sale Tax List';
    CardPageId = "NPR POS Sale Tax";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Source Rec. System Id"; Rec."Source Rec. System Id")
                {
                    ApplicationArea = Advanced;
                    Caption = 'Source Record System id';
                    ToolTip = 'Specifies unique value of source record from which tax calculation is created.';
                    Editable = false;
                }
                field("Source Tax Calc. Type"; Rec."Source Tax Calc. Type")
                {
                    ApplicationArea = All;
                    Caption = 'Tax Calculation Type';
                    ToolTip = 'Specifies value of the field Tax Calculation Type.';
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
                field("Source Prices Including Tax"; Rec."Source Prices Including Tax")
                {
                    ApplicationArea = All;
                    Caption = 'Prices Including Tax';
                    ToolTip = 'Specifies value of Prices Including Tax from source.';
                    Visible = false;
                    Editable = false;
                }
                field("Calculated Price Excl. Tax"; Rec."Calculated Price Excl. Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how tax calculation will be grouped. Value is set based on Tax Group Type';
                }
                field("Calculated Price Incl. Tax"; Rec."Calculated Price Incl. Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how tax calculation will be grouped. Value is set based on Tax Group Type';
                }
                field("Source Quantity (Base)"; Rec."Source Quantity (Base)")
                {
                    ApplicationArea = All;
                    Caption = 'Quantity (Base)';
                    ToolTip = 'Specifies base quantity from source.';
                    Editable = false;
                }
                field("Source Discount %"; Rec."Source Discount %")
                {
                    ApplicationArea = All;
                    Caption = 'Discount %';
                    ToolTip = 'Specifies discount % from source.';
                    Editable = false;
                }
                field("Calculated Amount Excl. Tax"; Rec."Calculated Amount Excl. Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how tax calculation will be grouped. Value is set based on Tax Group Type';
                }
                field("Calculated Amount Incl. Tax"; Rec."Calculated Amount Incl. Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how tax calculation will be grouped. Value is set based on Tax Group Type';
                }
                field("Calculated Unit Tax"; Rec."Calculated Unit Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how tax calculation will be grouped. Value is set based on Tax Group Type';
                }
            }
        }
    }
}