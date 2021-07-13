page 6014553 "NPR Mixed Discount Levels"
{
    // NPR5.55/ALPO/20200714 CASE 412946 Mixed Discount enhancement: support for multiple discount amount levels

    Caption = 'Mix Discount Levels';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR Mixed Discount Level";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Mixed Discount Code"; Rec."Mixed Discount Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Mixed Discount Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Multiple Of"; Rec."Multiple Of")
                {

                    ToolTip = 'Specifies the value of the Multiple Of field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {

                    ToolTip = 'Specifies the value of the Discount Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount %"; Rec."Discount %")
                {

                    ToolTip = 'Specifies the value of the Discount % field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

