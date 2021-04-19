page 6014576 "NPR Services Combination"
{


    PageType = ListPart;
    SourceTable = "NPR Services Combination";
    caption = 'NPR Services Combination';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Shipping Agent"; Rec."Shipping Agent")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the "Shipping Agent"';

                }
                field("Shipping Service"; Rec."Shipping Service")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the "Shipping service"';
                }
                field("Service Code"; Rec."Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the "Shipping service" that is required from the Provider';
                }
                field("Service Description"; Rec."Service Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the "Shipping service Description"';
                }
            }
        }
    }
}

