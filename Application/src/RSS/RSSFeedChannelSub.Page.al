page 6059937 "NPR RSS Feed Channel Sub."
{
    // NPR5.22/TJ/20160407 CASE 233762 Added new fields Url, Show As New Within and Default

    Caption = 'RSS Feed Channel Subscriptions';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR RSS Feed Channel Sub.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Feed Code"; "Feed Code")
                {
                    ApplicationArea = All;
                }
                field(Url; Url)
                {
                    ApplicationArea = All;
                }
                field("Show as New Within"; "Show as New Within")
                {
                    ApplicationArea = All;
                }
                field(Default; Default)
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

