page 6150714 "NPR POS Stargate Pckg Method"
{
    Caption = 'POS Stargate Package Method';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
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
                }
                field("Package Name"; "Package Name")
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

