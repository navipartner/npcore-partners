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

                    ToolTip = 'Specifies value of the field Tax Jurisdiction.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Tax Type"; Rec."Tax Type")
                {

                    ToolTip = 'Specifies value of the field Tax Type.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Round Tax"; Rec."Round Tax")
                {

                    ToolTip = 'Specifies value of the field Round Tax.';
                    Visible = false;
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Is Report-to Jurisdiction"; Rec."Is Report-to Jurisdiction")
                {

                    ToolTip = 'Specifies value of the field Is Report to Jurisdiction.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Print Order"; Rec."Print Order")
                {

                    ToolTip = 'Specifies value of the field Print Order.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Print Description"; Rec."Print Description")
                {

                    ToolTip = 'Specifies value of the field Print Descripttion.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Calculate Tax on Tax"; Rec."Calculate Tax on Tax")
                {

                    ToolTip = 'Specifies value of the field Calculate Tax on Tax.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price Excl. Tax"; Rec."Unit Price Excl. Tax")
                {

                    ToolTip = 'Specifies value of the field Unit Price before applied tax.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price Incl. Tax"; Rec."Unit Price Incl. Tax")
                {

                    ToolTip = 'Specifies value of the field Unit Price after applied tax.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies value of the field Quantity.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Tax %"; Rec."Tax %")
                {

                    ToolTip = 'Specifies value of the field Tax %.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Unit Tax"; Rec."Unit Tax")
                {

                    ToolTip = 'Specifies value of the field Unit Tax.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Amount Excl. Tax"; Rec."Amount Excl. Tax")
                {

                    ToolTip = 'Specifies value of the field Amount before applied tax.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {

                    ToolTip = 'Specifies value of the field Discount Amount.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Amount Incl. Tax"; Rec."Amount Incl. Tax")
                {

                    ToolTip = 'Specifies value of the field Amount after applied tax.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}