page 6184863 "NPR Azure Storage Dir. Select"
{
    Caption = 'Select Upload Directory';
    PageType = ListPlus;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Azure Storage Overview";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Container Name"; "Container Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Container Name field';
                }
                field("File Name"; "File Name")
                {
                    ApplicationArea = All;
                    Caption = 'Directory';
                    ToolTip = 'Specifies the value of the Directory field';
                }
            }
        }
    }

    actions
    {
    }
}

