page 6184929 "NPR NPDesignerSetupCard"
{
    Extensible = false;
    PageType = Card;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR NPDesignerSetup";
    Caption = 'NPDesigner Setup Card';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(URL; Rec.DesignerURL)
                {
                    ToolTip = 'Specifies the value of the URL field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(ApiAuthorization; Rec.ApiAuthorization)
                {
                    ToolTip = 'Specifies the value of the API Authorization field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(PublicTicketURL; Rec.PublicTicketURL)
                {
                    ToolTip = 'Specifies the value of the Public URL field. Will fill in %1 with the token and %2 with designer id. Example: reservation=%1&design=%2', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        Setup: Record "NPR NPDesignerSetup";
    begin
        if (not Setup.Get('')) then begin
            Setup.PublicTicketURL := 'https://tickets.npretail.app?reservation=%1&design=%2';
            Setup.Insert();
        end;
    end;
}