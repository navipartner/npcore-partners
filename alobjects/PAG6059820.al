page 6059820 "Transactional Email Setup"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created

    Caption = 'Transactional Email Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Transactional Email Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Client ID";"Client ID")
                {
                }
                field("API Key";"API Key")
                {
                }
                field("API URL";"API URL")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(CheckConnection)
            {
                Caption = 'Test Connection';
                Image = Link;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    CampaignMonitorMgt: Codeunit "CampaignMonitor Mgt.";
                begin
                    CampaignMonitorMgt.CheckConnection;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
          Init;
          Insert(true);
        end;
    end;
}

