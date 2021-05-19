page 6151167 "NPR NpGp POS Sales Entries"
{
    Caption = 'Global POS Sales Entries';
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpGp POS Sales Entry";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field("Fiscal No."; Rec."Fiscal No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fiscal No. field';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Currency Factor"; Rec."Currency Factor")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Factor field';
                }
                field("Sales Amount"; Rec."Sales Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Amount field';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Amount field';
                }
                field("Sales Quantity"; Rec."Sales Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Quantity field';
                }
                field("Return Sales Quantity"; Rec."Return Sales Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Sales Quantity field';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Amount field';
                }
                field("Total Tax Amount"; Rec."Total Tax Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Tax Amount field';
                }
                field("Total Amount Incl. Tax"; Rec."Total Amount Incl. Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Amount Incl. Tax field';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Entry Time"; Rec."Entry Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Time field';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Type field';
                }
                field("System Id"; Rec.SystemId)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the System Id field';
                }
            }
            part("POS Sales Lines"; "NPR NpGp POSSalesEntry Subpage")
            {
                Caption = 'POS Sales Lines';
                SubPageLink = "POS Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the POS Info action';
                //RunPageLink = "POS Entry No."=FIELD("Entry No.");
            }
        }
    }
}

