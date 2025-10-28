page 6185123 "NPR CloudflareMediaSetupCard"
{
    Extensible = False;
    PageType = Card;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    Caption = 'Cloudflare Media Setup Card';
    editable = true;

    layout
    {
        area(Content)
        {
            group(LicenseGroup)
            {
                Caption = 'License Information';
                field(LicenseInfo; _LicenseInfo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or manage license information.';
                    Caption = 'License Info';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = _BadLicense;
                    trigger OnDrillDown()
                    var
                        PageAction: Action;
                    begin
                        PageAction := Page.RunModal(Page::"NPR CloudflareMediaLicense");
                        CurrPage.Update();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(OpenMediaLinks)
            {
                Caption = 'Media Links';
                Image = List;
                ToolTip = 'Open the Cloudflare Media Links.';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                begin
                    Page.Run(Page::"NPR CloudflareMediaLinkList");
                end;
            }
        }
    }
    var
        _LicenseInfo: Text;
        _ExpirationDate: DateTime;
        _BadLicense: Boolean;

    trigger OnAfterGetRecord()
    var
        CloudFlareFacade: Codeunit "NPR CloudflareMediaFacade";
        KeyId: Text;
        NoLicense: Label 'No License';
        ExpirationDate: Label 'Expiration Date: %1';
    begin
        _LicenseInfo := NoLicense;

        if (CloudFlareFacade.GetLicenseInfo(KeyId, _ExpirationDate)) then
            _LicenseInfo := StrSubstNo(ExpirationDate, Format(_ExpirationDate));

        _BadLicense := (_LicenseInfo = NoLicense) or (CurrentDateTime() > _ExpirationDate);

    end;

}
