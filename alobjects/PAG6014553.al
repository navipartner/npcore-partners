page 6014553 "Mixed Discount Levels"
{
    // NPR5.55/ALPO/20200714 CASE 412946 Mixed Discount enhancement: support for multiple discount amount levels

    Caption = 'Mix Discount Levels';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Mixed Discount Level";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Mixed Discount Code"; "Mixed Discount Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Multiple Of"; "Multiple Of")
                {
                    ApplicationArea = All;
                }
                field("Discount Amount"; "Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("Discount %"; "Discount %")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

