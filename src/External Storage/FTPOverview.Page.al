page 6184881 "NPR FTP Overview"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'FTP Overview';
    PageType = List;
    SourceTable = "NPR FTP Overview";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Host Code"; "Host Code")
                {
                    ApplicationArea = All;
                }
                field("File Name"; "File Name")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
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

