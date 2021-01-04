page 6184882 "NPR FTP Dir. Select"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'Choose Upload Directory';
    PageType = ListPlus;
    UsageCategory = Administration;
    SourceTable = "NPR FTP Overview";
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

