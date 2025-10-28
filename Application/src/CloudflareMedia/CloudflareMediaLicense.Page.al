page 6185128 "NPR CloudflareMediaLicense"
{
    Extensible = False;
    PageType = Card;
    UsageCategory = None;
    Caption = 'Cloudflare Media License';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'License Information';

                field(LicenseKey; _LicenseKey)
                {
                    Caption = 'License Key';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies license key.';
                    Editable = true;

                    trigger OnValidate()
                    var
                        CloudFlareFacade: Codeunit "NPR CloudflareMediaFacade";
                    begin
                        if (not CloudFlareFacade.AddLicense(_LicenseKey)) then
                            Error('The license is not valid. %1', GetLastErrorText());

                        if (not CloudFlareFacade.GetLicenseInfo(_KeyId, _ExpirationDate)) then
                            Error('The license is not valid. %1', GetLastErrorText());

                        CurrPage.Update();
                    end;

                }
            }
            Group(Details)
            {
                Caption = 'Details';
                field(kid; _KeyId)
                {
                    Caption = 'Key ID';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Key ID (kid) of the license.';
                    Editable = false;
                }
                field(ExpirationDate; _ExpirationDate)
                {
                    Caption = 'Expiration Date (UTC)';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the expiration date of the license.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RemoveLicense)
            {
                Caption = 'Remove License';
                Image = Delete;
                ApplicationArea = NPRRetail;
                ToolTip = 'Removes the current license.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    CloudFlareFacade: Codeunit "NPR CloudflareMediaFacade";
                begin
                    if (not CloudFlareFacade.RemoveLicense()) then
                        Error('There is no license to remove. %1', GetLastErrorText());

                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        CloudFlareFacade: Codeunit "NPR CloudflareMediaFacade";
    begin
        Clear(_LicenseKey);
        Clear(_KeyId);
        Clear(_ExpirationDate);

        if (CloudFlareFacade.GetLicenseInfo(_KeyId, _ExpirationDate)) then
            exit;

        _ExpirationDate := 0DT;
        _KeyId := 'Invalid License.';
    end;

    var
        _LicenseKey: Text;
        _KeyId: Text;
        _ExpirationDate: DateTime;
}
