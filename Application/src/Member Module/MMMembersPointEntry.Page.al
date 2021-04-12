page 6060104 "NPR MM Members. Point Entry"
{

    Caption = 'Membership Point Entry';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Members. Points Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Type field';
                }
                field("Point Constraint"; Rec."Point Constraint")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Point Constraint field';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field("Value Entry No."; Rec."Value Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Value Entry No. field';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Loyalty Code"; Rec."Loyalty Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Loyalty Code field';
                }
                field("Loyalty Item Point Line No."; Rec."Loyalty Item Point Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Loyalty Item Point Line No. field';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount (LCY) field';
                }
                field("Awarded Amount (LCY)"; Rec."Awarded Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Awarded Amount (LCY) field';
                }
                field("Awarded Points"; Rec."Awarded Points")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Awarded Points field';
                }
                field("Redeemed Points"; Rec."Redeemed Points")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Redeemed Points field';
                }
                field(Points; Rec.Points)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points field';
                }
                field("Period Start"; Rec."Period Start")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Start field';
                }
                field("Period End"; Rec."Period End")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period End field';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the &Navigate action';

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

