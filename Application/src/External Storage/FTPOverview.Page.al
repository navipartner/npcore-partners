page 6184881 "NPR FTP Overview"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'FTP Overview';
    PageType = List;
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the FTP Host Code field';
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

