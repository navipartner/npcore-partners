page 6150714 "NPR POS Stargate Pckg Method"
{
    Caption = 'POS Stargate Package Method';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Stargate Pckg. Method";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Method Name"; "Method Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Method Name field';
                }
                field("Package Name"; "Package Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Package Name field';
                }
            }
        }
    }

    actions
    {
    }
}

