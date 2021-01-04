page 6184862 "NPR Azr. Storage Cogn. Search"
{
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
                    ToolTip = 'Specifies the value of the Azure Account Name field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Search Service Name"; "Search Service Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Search Service Name field';
                }
                field(Index; Index)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Search Index field';
                }
            }
        }
    }

    actions
    {
    }
}

