page 6014533 "NPR POS Sale Tax Lines"
{
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR POS Sale Tax Line";
    Caption = 'Lines';
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Tax Jurisdiction Code"; Rec."Tax Jurisdiction Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies value of the field Tax Jurisdiction.';
                    Editable = false;
                }
                field("Tax Type"; Rec."Tax Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies value of the field Tax Type.';
                    Editable = false;
                }
                field("Round Tax"; Rec."Round Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies value of the field Round Tax.';
                    Visible = false;
                    Editable = false;
                }
                field("Is Report-to Jurisdiction"; Rec."Is Report-to Jurisdiction")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies value of the field Is Report to Jurisdiction.';
                    Editable = false;
                }
                field("Print Order"; Rec."Print Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies value of the field Print Order.';
                    Editable = false;
                }
                field("Print Description"; Rec."Print Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies value of the field Print Descripttion.';
                    Editable = false;
                }
                field("Calculate Tax on Tax"; Rec."Calculate Tax on Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies value of the field Calculate Tax on Tax.';
                    Editable = false;
                }
                field("Unit Price Excl. Tax"; Rec."Unit Price Excl. Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies value of the field Unit Price before applied tax.';
                    Editable = false;
                }
                field("Unit Price Incl. Tax"; Rec."Unit Price Incl. Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies value of the field Unit Price after applied tax.';
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies value of the field Quantity.';
                    Editable = false;
                }
                field("Tax %"; Rec."Tax %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies value of the field Tax %.';
                    Editable = false;
                }
                field("Unit Tax"; Rec."Unit Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies value of the field Unit Tax.';
                    Editable = false;
                }
                field("Amount Excl. Tax"; Rec."Amount Excl. Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies value of the field Amount before applied tax.';
                    Editable = false;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies value of the field Discount Amount.';
                    Editable = false;
                }
                field("Amount Incl. Tax"; Rec."Amount Incl. Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies value of the field Amount after applied tax.';
                    Editable = false;
                }
            }
        }
    }
}