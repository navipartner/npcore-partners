page 6184862 "Azr. Storage Cognitive Search"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'Azure Storage Cognitive Search';
    PageType = List;
    SourceTable = "Azure Storage Cognitive Search";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account Name";"Account Name")
                {
                }
                field(Description;Description)
                {
                }
                field("Search Service Name";"Search Service Name")
                {
                }
                field(Index;Index)
                {
                }
            }
        }
    }

    actions
    {
    }
}

