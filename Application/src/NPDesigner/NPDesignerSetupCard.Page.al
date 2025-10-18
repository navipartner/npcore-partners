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
                Caption = 'NPDesigner Setup';
                field(URL; Rec.DesignerURL)
                {
                    ToolTip = 'Specifies the value of the URL field.';
                    ApplicationArea = NPRRetail;
                }
                field(ApiAuthorization; Rec.ApiAuthorization)
                {
                    ToolTip = 'Specifies the value of the API Authorization field.';
                    ApplicationArea = NPRRetail;
                }
                field(EnableManifest; Rec.EnableManifest)
                {
                    ToolTip = 'Specifies whether the manifest functionality is enabled.';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        _ShowUrlFields := not Rec.EnableManifest;
                        CurrPage.Update(false);
                    end;
                }
                field(AssetsUrl; Rec.AssetsUrl)
                {
                    ToolTip = 'Specifies the base URL for assets. Default is https://assets.npretail.com/.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(TicketUrls)
            {
                Caption = 'Ticket URLs';
                Visible = _ShowUrlFields;
                field(PublicTicketURL; Rec.PublicTicketURL)
                {
                    ToolTip = 'Specifies the value of the Public Ticket URL field. Will fill in %1 with the ticket id and %2 with designer id. Example: ticket=%1&design=%2', Comment = '%';
                    ApplicationArea = NPRRetail;
                    Visible = _ShowUrlFields;
                }
                field(PublicOrderURL; Rec.PublicOrderURL)
                {
                    ToolTip = 'Specifies the value of the Public Order URL field. Will fill in %1 with the token and %2 with designer id. Example: reservation=%1&design=%2', Comment = '%';
                    ApplicationArea = NPRRetail;
                    Visible = _ShowUrlFields;
                }
            }
        }
    }

    var
        _ShowUrlFields: Boolean;

    trigger OnOpenPage()
    var
        Setup: Record "NPR NPDesignerSetup";
    begin
        if (not Setup.Get('')) then begin
            Setup.EnableManifest := false; // Switch to true when manifest functionality is released and obsolete the ticket URL and Order URL fields
            Setup.PublicTicketURL := 'https://tickets.npretail.app?ticket=%1&design=%2';
            Setup.PublicOrderURL := 'https://tickets.npretail.app?reservation=%1&design=%2';
            Setup.Insert();
        end;

        _ShowUrlFields := not Setup.EnableManifest;
    end;

    trigger OnAfterGetRecord()
    begin
        _ShowUrlFields := not Rec.EnableManifest;
    end;

}