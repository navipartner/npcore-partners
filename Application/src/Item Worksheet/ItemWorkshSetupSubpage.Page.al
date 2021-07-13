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

                    ToolTip = 'Specifies the value of the Related Field Name field.';
                    ApplicationArea = NPRRetail;
                }
                field(Value; Rec.Value)
                {

                    ToolTip = 'Specifies the value of the Value field.';
                    ApplicationArea = NPRRetail;
                }
                field("Create New"; Rec."Create New")
                {

                    ToolTip = 'Specifies the value of the Create New field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}

