page 6151167 "NPR NpGp POS Sales Entries"
{
    Extensible = False;
    Caption = 'Global POS Sales Entries';
    ContextSensitiveHelpPage = 'docs/retail/pos_profiles/how-to/global_profile/global_profile/';
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpGp POS Sales Entry";
    CardPageId = "NPR NpGp POS Sales Entry Card";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;
    AdditionalSearchTerms = 'Global POS Entry List';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store Code"; Rec."POS Store Code")
                {

                    ToolTip = 'Specifies the POS store code.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {

                    ToolTip = 'Specifies the POS unit number.';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the document number.';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No.';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    ToolTip = 'Specifies the posting date.';
                    ApplicationArea = NPRRetail;
                }
                field("Fiscal No."; Rec."Fiscal No.")
                {

                    ToolTip = 'Specifies the fiscal number.';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the salesperson code.';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {

                    ToolTip = 'Specifies the currency code.';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Factor"; Rec."Currency Factor")
                {

                    ToolTip = 'Specifies the currency factor.';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Amount"; Rec."Sales Amount")
                {

                    ToolTip = 'Specifies the sales amount.';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {

                    ToolTip = 'Specifies the discount amount.';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Quantity"; Rec."Sales Quantity")
                {

                    ToolTip = 'Specifies the sales quantity.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Return Sales Quantity"; Rec."Return Sales Quantity")
                {

                    ToolTip = 'Specifies the return sales quantity.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Total Amount"; Rec."Total Amount")
                {

                    ToolTip = 'Specifies the total amount.';
                    ApplicationArea = NPRRetail;
                }
                field("Total Tax Amount"; Rec."Total Tax Amount")
                {

                    ToolTip = 'Specifies the total tax amount.';
                    ApplicationArea = NPRRetail;
                }
                field("Total Amount Incl. Tax"; Rec."Total Amount Incl. Tax")
                {

                    ToolTip = 'Specifies the total amount including tax.';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the entry number.';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Time"; Rec."Entry Time")
                {

                    ToolTip = 'Specifies the entry time.';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Type"; Rec."Entry Type")
                {

                    ToolTip = 'Specifies the entry type.';
                    ApplicationArea = NPRRetail;
                }
                field("Original Company"; Rec."Original Company")
                {
                    ToolTip = 'Specifies the Original Company.';
                    ApplicationArea = NPRRetail;
                }
                field("System Id"; Rec.SystemId)
                {

                    ToolTip = 'Specifies the system ID.';
                    ApplicationArea = NPRRetail;
                }

            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(SalesLines)
            {
                Caption = 'Sales Line List';
                Image = Sales;
                ToolTip = 'Displays all Sales Lines';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "NPR NpGp POS Sales Lines";
            }
            action(PaymentLines)
            {
                Caption = 'Payment Line List';
                Image = Sales;
                ToolTip = 'Displays all Payment Lines';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "NPR NpGp POS Payment Lines";
            }
            action("POS Info")
            {
                Caption = 'POS Info';
                Image = List;
                RunObject = Page "NPR NpGp POS Info POS Entry";

                ToolTip = 'Displays the global POS informattion entries page.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

