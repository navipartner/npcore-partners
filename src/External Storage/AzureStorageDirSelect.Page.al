page 6184863 "NPR Azure Storage Dir. Select"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'Select Upload Directory';
    PageType = ListPlus;
    UsageCategory = Administration;
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
                }
                field("File Name"; "File Name")
                {
                    ApplicationArea = All;
                    Caption = 'Directory';
                }
            }
        }
    }

    actions
    {
    }
}

