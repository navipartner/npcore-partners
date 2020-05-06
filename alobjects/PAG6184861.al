page 6184861 "Azure Storage Overview"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'Azure Storage Overview';
    Editable = false;
    PageType = List;
    SourceTable = "Azure Storage Overview";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account name";"Account name")
                {
                }
                field("Container Name";"Container Name")
                {
                }
                field("File Name";"File Name")
                {
                }
                field(Name;Name)
                {
                }
            }
        }
    }

    actions
    {
    }
}

