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
                    ToolTip = 'Specifies the value of the Feed Code field';
                }
                field(Url; Url)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Url field';
                }
                field("Show as New Within"; "Show as New Within")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show as New Within field';
                }
                field(Default; Default)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default field';
                }
            }
        }
    }

    actions
    {
    }
}

