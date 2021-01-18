page 6060050 "NPR Item Worksh. Setup Subpage"
{
    Caption = 'Item Worksheet Setup Subpage';
    PageType = ListPart;
    SourceTable = "NPR Missing Setup Record";
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Related Field Name"; Rec."Related Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Related Field Name field.';
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Value field.';
                }
                field("Create New"; Rec."Create New")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create New field.';
                }
            }
        }
    }

}

