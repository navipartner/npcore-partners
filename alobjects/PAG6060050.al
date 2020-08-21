page 6060050 "Item Worksheet Setup Subpage"
{
    // NPR4.19\BR\20160216  CASE 182391 Object Created

    Caption = 'Item Worksheet Setup Subpage';
    PageType = ListPart;
    SourceTable = "Missing Setup Record";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Related Field Name"; "Related Field Name")
                {
                    ApplicationArea = All;
                }
                field(Value; Value)
                {
                    ApplicationArea = All;
                }
                field("Create New"; "Create New")
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

