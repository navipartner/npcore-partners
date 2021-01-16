page 6060064 "NPR EAN Prefixes per Countries"
{
    // NPR5.46/NPKNAV/20181008  CASE 327838 Transport NPR5.46 - 8 October 2018

    AutoSplitKey = false;
    Caption = 'EAN Prefixes per Countries';
    PageType = List;
    SourceTable = "NPR EAN Prefix per Country";
    SourceTableView = SORTING("Country Code");
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Country Code"; "Country Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country Code field';
                }
                field("Country Name"; "Country Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country Name field';
                }
                field(Prefix; Prefix)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prefix field';
                }
            }
        }
    }

    actions
    {
    }
}

