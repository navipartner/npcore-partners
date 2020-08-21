page 6150714 "POS Stargate Package Method"
{
    Caption = 'POS Stargate Package Method';
    Editable = false;
    PageType = List;
    SourceTable = "POS Stargate Package Method";

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

