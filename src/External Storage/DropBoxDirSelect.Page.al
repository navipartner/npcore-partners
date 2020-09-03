page 6184872 "NPR DropBox Dir. Select"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'Select Upload Directory';
    PageType = ListPlus;
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
                }
            }
        }
    }

    actions
    {
    }
}

