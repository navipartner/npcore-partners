page 6060104 "NPR MM Members. Point Entry"
{
    // MM1.17/TSA/20161214  CASE 243075 Member Point System

    Caption = 'Membership Point Entry';
    Editable = false;
    PageType = List;
    SourceTable = "NPR MM Members. Points Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                }
                field("Point Constraint"; "Point Constraint")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Value Entry No."; "Value Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Membership Entry No."; "Membership Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Loyalty Code"; "Loyalty Code")
                {
                    ApplicationArea = All;
                }
                field("Loyalty Item Point Line No."; "Loyalty Item Point Line No.")
                {
                    ApplicationArea = All;
                }
                field("Amount (LCY)"; "Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Awarded Amount (LCY)"; "Awarded Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Awarded Points"; "Awarded Points")
                {
                    ApplicationArea = All;
                }
                field("Redeemed Points"; "Redeemed Points")
                {
                    ApplicationArea = All;
                }
                field(Points; Points)
                {
                    ApplicationArea = All;
                }
                field("Period Start"; "Period Start")
                {
                    ApplicationArea = All;
                }
                field("Period End"; "Period End")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("&Navigate")
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea=All;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc("Posting Date", "Document No.");
                    Navigate.Run;
                end;
            }
        }
    }
}

