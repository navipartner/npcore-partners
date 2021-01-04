page 6184871 "NPR DropBox Overview"
{
    Caption = 'DropBox Overview';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR DropBox Overview";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account Code"; "Account Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the DropBox Account Code field';
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

