page 6060104 "NPR MM Members. Point Entry"
{

    Caption = 'Membership Point Entry';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Members. Points Entry";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Type"; Rec."Entry Type")
                {

                    ToolTip = 'Specifies the value of the Entry Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Point Constraint"; Rec."Point Constraint")
                {

                    ToolTip = 'Specifies the value of the Point Constraint field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Value Entry No."; Rec."Value Entry No.")
                {

                    ToolTip = 'Specifies the value of the Value Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {

                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Loyalty Code"; Rec."Loyalty Code")
                {

                    ToolTip = 'Specifies the value of the Loyalty Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Loyalty Item Point Line No."; Rec."Loyalty Item Point Line No.")
                {

                    ToolTip = 'Specifies the value of the Loyalty Item Point Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Awarded Amount (LCY)"; Rec."Awarded Amount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Awarded Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Awarded Points"; Rec."Awarded Points")
                {

                    ToolTip = 'Specifies the value of the Awarded Points field';
                    ApplicationArea = NPRRetail;
                }
                field("Redeemed Points"; Rec."Redeemed Points")
                {

                    ToolTip = 'Specifies the value of the Redeemed Points field';
                    ApplicationArea = NPRRetail;
                }
                field(Points; Rec.Points)
                {

                    ToolTip = 'Specifies the value of the Points field';
                    ApplicationArea = NPRRetail;
                }
                field("Period Start"; Rec."Period Start")
                {

                    ToolTip = 'Specifies the value of the Period Start field';
                    ApplicationArea = NPRRetail;
                }
                field("Period End"; Rec."Period End")
                {

                    ToolTip = 'Specifies the value of the Period End field';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the &Navigate action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                    Navigate.Run();
                end;
            }
        }
    }
}

