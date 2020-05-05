page 6184882 "FTP Dir. Select"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'Choose Upload Directory';
    PageType = ListPlus;
    SourceTable = "FTP Overview";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("File Name";"File Name")
                {
                }
            }
        }
    }

    actions
    {
    }
}

