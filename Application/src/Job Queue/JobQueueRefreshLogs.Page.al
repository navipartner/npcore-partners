page 6185096 "NPR Job Queue Refresh Logs"
{
    Extensible = false;
    UsageCategory = History;
    ApplicationArea = NPRRetail;
    Caption = 'Job Queue Refresh Logs';
    PageType = List;
    SourceTable = "NPR Job Queue Refresh Log";
    SourceTableView = sorting("Last Refreshed") order(descending);
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("JQ Runner User Name"; Rec."JQ Runner User Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the JQ Runner User Name.';
                }
                field("Last Refreshed"; Rec."Last Refreshed")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date and time when the job queue entries were refreshed the last time by the corresponding JQ Runner.';
                }
            }
        }
    }
}
