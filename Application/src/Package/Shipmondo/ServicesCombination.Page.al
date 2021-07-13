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

                    ToolTip = 'Specifies the "Shipping Agent"';
                    ApplicationArea = NPRRetail;

                }
                field("Shipping Service"; Rec."Shipping Service")
                {

                    ToolTip = 'Specifies the "Shipping service"';
                    ApplicationArea = NPRRetail;
                }
                field("Service Code"; Rec."Service Code")
                {

                    ToolTip = 'Specifies the "Shipping service" that is required from the Provider';
                    ApplicationArea = NPRRetail;
                }
                field("Service Description"; Rec."Service Description")
                {

                    ToolTip = 'Specifies the "Shipping service Description"';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

