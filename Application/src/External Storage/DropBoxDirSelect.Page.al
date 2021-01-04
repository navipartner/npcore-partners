page 6184872 "NPR DropBox Dir. Select"
{
    Caption = 'Select Upload Directory';
    PageType = ListPlus;
    UsageCategory = Administration;
    SourceTable = "NPR DropBox Overview";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("File Name"; "File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File Name field';
                }
            }
        }
    }

    actions
    {
    }
}

