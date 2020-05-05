page 6184881 "FTP Overview"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'FTP Overview';
    PageType = List;
    SourceTable = "FTP Overview";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Host Code";"Host Code")
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

