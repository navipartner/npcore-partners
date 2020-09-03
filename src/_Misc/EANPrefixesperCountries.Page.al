page 6060064 "NPR EAN Prefixes per Countries"
{
    // NPR5.46/NPKNAV/20181008  CASE 327838 Transport NPR5.46 - 8 October 2018

    AutoSplitKey = false;
    Caption = 'EAN Prefixes per Countries';
    PageType = List;
    SourceTable = "NPR EAN Prefix per Country";
    SourceTableView = SORTING("Country Code");
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Country Code"; "Country Code")
                {
                    ApplicationArea = All;
                }
                field("Country Name"; "Country Name")
                {
                    ApplicationArea = All;
                }
                field(Prefix; Prefix)
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

