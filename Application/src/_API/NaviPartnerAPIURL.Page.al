page 6184874 "NPR NaviPartner API URL"
{
    PageType = StandardDialog;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    Caption = 'NaviPartner API URL', Locked = true;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(ApiUrl; ApiUrl)
                {
                    ToolTip = 'Specifies the base URL to this company, for all APIs defined on https://api.navipartner.com';
                    Caption = 'API URL';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        EnvironmentInformation: Codeunit "Environment Information";
        TypeHelper: Codeunit "Type Helper";
        EnvironmentName: Text;
        ThisCompanyName: Text;
        AzureADTenant: Codeunit "Azure AD Tenant";
        WebUrl: Text;
        Container: Text;
    begin
        EnvironmentName := EnvironmentInformation.GetEnvironmentName();
        ThisCompanyName := CompanyName();
        WebUrl := GetUrl(ClientType::Web);

        if WebUrl.Contains('dynamics-retail.net') then begin
            //Crane
            Container := WebUrl.Substring(9, 8);
            ApiUrl := StrSubstNo('https://api.npretail.app/%1/%2/%3/', Container, 'BC', TypeHelper.UrlEncode(ThisCompanyName));
        end else begin
            ApiUrl := StrSubstNo('https://api.npretail.app/%1/%2/%3/', AzureADTenant.GetAadTenantId(), TypeHelper.UrlEncode(EnvironmentName), TypeHelper.UrlEncode(ThisCompanyName));
        end;
    end;

    var
        ApiUrl: Text;
}