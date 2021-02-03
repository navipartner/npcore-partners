page 6060064 "NPR EAN Prefixes per Countries"
{
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
                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country Code field';
                }
                field("Country Name"; Rec."Country Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country Name field';
                }
                field(Prefix; Rec.Prefix)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prefix field';
                }
            }
        }
    }
}

