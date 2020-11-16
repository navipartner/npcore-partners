page 6184862 "NPR Azr. Storage Cogn. Search"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'Azure Storage Cognitive Search';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Azure Storage Cogn. Search";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account Name"; "Account Name")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Search Service Name"; "Search Service Name")
                {
                    ApplicationArea = All;
                }
                field(Index; Index)
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

