page 6184861 "NPR Azure Storage Overview"
{
    Caption = 'Azure Storage Overview';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Azure Storage Overview";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account name"; "Account name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Azure Account Name field';
                }
                field("Container Name"; "Container Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Container Name field';
                }
                field("File Name"; "File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File Name field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
            }
        }
    }

    actions
    {
    }
}

