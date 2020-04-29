page 6060104 "MM Membership Point Entry"
{
    // MM1.17/TSA/20161214  CASE 243075 Member Point System

    Caption = 'Membership Point Entry';
    Editable = false;
    PageType = List;
    SourceTable = "MM Membership Points Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field("Entry Type";"Entry Type")
                {
                }
                field("Point Constraint";"Point Constraint")
                {
                }
                field("Posting Date";"Posting Date")
                {
                }
                field("Value Entry No.";"Value Entry No.")
                {
                }
                field("Customer No.";"Customer No.")
                {
                }
                field("Membership Entry No.";"Membership Entry No.")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("Loyalty Code";"Loyalty Code")
                {
                }
                field("Loyalty Item Point Line No.";"Loyalty Item Point Line No.")
                {
                }
                field("Amount (LCY)";"Amount (LCY)")
                {
                }
                field("Awarded Amount (LCY)";"Awarded Amount (LCY)")
                {
                }
                field("Awarded Points";"Awarded Points")
                {
                }
                field("Redeemed Points";"Redeemed Points")
                {
                }
                field(Points;Points)
                {
                }
                field("Period Start";"Period Start")
                {
                }
                field("Period End";"Period End")
                {
                }
                field("Item No.";"Item No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
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

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc("Posting Date","Document No.");
                    Navigate.Run;
                end;
            }
        }
    }
}

