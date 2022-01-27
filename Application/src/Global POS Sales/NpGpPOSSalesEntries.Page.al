page 6151167 "NPR NpGp POS Sales Entries"
{
    Extensible = False;
    Caption = 'Global POS Sales Entries';
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpGp POS Sales Entry";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store Code"; Rec."POS Store Code")
                {

                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Fiscal No."; Rec."Fiscal No.")
                {

                    ToolTip = 'Specifies the value of the Fiscal No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {

                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Factor"; Rec."Currency Factor")
                {

                    ToolTip = 'Specifies the value of the Currency Factor field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Amount"; Rec."Sales Amount")
                {

                    ToolTip = 'Specifies the value of the Sales Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {

                    ToolTip = 'Specifies the value of the Discount Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Quantity"; Rec."Sales Quantity")
                {

                    ToolTip = 'Specifies the value of the Sales Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Return Sales Quantity"; Rec."Return Sales Quantity")
                {

                    ToolTip = 'Specifies the value of the Return Sales Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Amount"; Rec."Total Amount")
                {

                    ToolTip = 'Specifies the value of the Total Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Tax Amount"; Rec."Total Tax Amount")
                {

                    ToolTip = 'Specifies the value of the Total Tax Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Amount Incl. Tax"; Rec."Total Amount Incl. Tax")
                {

                    ToolTip = 'Specifies the value of the Total Amount Incl. Tax field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Time"; Rec."Entry Time")
                {

                    ToolTip = 'Specifies the value of the Entry Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Type"; Rec."Entry Type")
                {

                    ToolTip = 'Specifies the value of the Entry Type field';
                    ApplicationArea = NPRRetail;
                }
                field("System Id"; Rec.SystemId)
                {

                    ToolTip = 'Specifies the value of the System Id field';
                    ApplicationArea = NPRRetail;
                }
            }
            part("POS Sales Lines"; "NPR NpGp POSSalesEntry Subpage")
            {
                Caption = 'POS Sales Lines';
                SubPageLink = "POS Entry No." = FIELD("Entry No.");
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("POS Info")
            {
                Caption = 'POS Info';
                Image = List;
                RunObject = Page "NPR NpGp POS Info POS Entry";

                ToolTip = 'Executes the POS Info action';
                ApplicationArea = NPRRetail;
                //RunPageLink = "POS Entry No."=FIELD("Entry No.");
            }
        }
    }
}

