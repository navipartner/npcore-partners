page 6150811 "NPR NpGp POS Sales Entry Card"
{
    Caption = 'Global POS Sales Entry Card';
    PageType = Document;
    SourceTable = "NPR NpGp POS Sales Entry";
    Editable = false;
    UsageCategory = None;
    Extensible = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the entry number.';
                    ApplicationArea = NPRRetail;
                }
                field("Original Company"; Rec."Original Company")
                {
                    ToolTip = 'Specifies the Original Company.';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
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
                field("Fiscal No."; Rec."Fiscal No.")
                {
                    ToolTip = 'Specifies the fiscal number.';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the posting date.';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No.';
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
                    Importance = Additional;
                }
                field("Currency Factor"; Rec."Currency Factor")
                {
                    ToolTip = 'Specifies the currency factor.';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
                field("Sales Amount"; Rec."Sales Amount")
                {
                    ToolTip = 'Specifies the sales amount.';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ToolTip = 'Specifies the discount amount.';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ToolTip = 'Specifies the total amount.';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
                field("Total Tax Amount"; Rec."Total Tax Amount")
                {
                    ToolTip = 'Specifies the total tax amount.';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
                field("Total Amount Incl. Tax"; Rec."Total Amount Incl. Tax")
                {
                    ToolTip = 'Specifies the total amount including tax.';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Specifies the entry type.';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Time"; Rec."Entry Time")
                {
                    ToolTip = 'Specifies the entry time.';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
            }
            part("POS Sales Lines"; "NPR NpGp POSSalesEntry Subpage")
            {
                Caption = 'Sales';
                SubPageLink = "POS Entry No." = FIELD("Entry No.");
                ApplicationArea = NPRRetail;
            }
            part("POS Payment Lines"; "NPR NpGp POSPaymeLines Subpage")
            {
                Caption = 'Payments';
                SubPageLink = "POS Entry No." = FIELD("Entry No.");
                ApplicationArea = NPRRetail;
            }
        }
    }
}
