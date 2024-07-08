page 6150891 "NPR Job Queue Refresh Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'Job Queue Refresh Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    Extensible = false;
    PageType = Card;
    SourceTable = "NPR Job Queue Refresh Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether refreshing the list of NP Retail related job queue entries should be enabled. Default value is true.';
                }
                field("Last Refreshed"; Rec."Last Refreshed")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date and time when the list of NP Retail related job queue entries was refreshed the last time.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}
