page 6184863 "Azure Storage Dir. Select"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'Select Upload Directory';
    PageType = ListPlus;
    SourceTable = "Azure Storage Overview";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Container Name";"Container Name")
                {
                }
                field("File Name";"File Name")
                {
                    Caption = 'Directory';
                }
            }
        }
    }

    actions
    {
    }
}

