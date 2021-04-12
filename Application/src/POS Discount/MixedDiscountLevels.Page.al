page 6014553 "NPR Mixed Discount Levels"
{
    // NPR5.55/ALPO/20200714 CASE 412946 Mixed Discount enhancement: support for multiple discount amount levels

    Caption = 'Mix Discount Levels';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Mixed Discount Level";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Mixed Discount Code"; Rec."Mixed Discount Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Mixed Discount Code field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Multiple Of"; Rec."Multiple Of")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Multiple Of field';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Amount field';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount % field';
                }
            }
        }
    }

    actions
    {
    }
}

