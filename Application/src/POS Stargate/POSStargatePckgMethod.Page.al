page 6150714 "NPR POS Stargate Pckg Method"
{
    Caption = 'POS Stargate Package Method';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Stargate Pckg. Method";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Method Name"; Rec."Method Name")
                {

                    ToolTip = 'Specifies the value of the Method Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Package Name"; Rec."Package Name")
                {

                    ToolTip = 'Specifies the value of the Package Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

