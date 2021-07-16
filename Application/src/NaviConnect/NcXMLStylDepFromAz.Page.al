page 6151511 "NPR Nc XML Styl. Dep. From Az."
{
    PageType = NavigatePage;
    ApplicationArea = NPRNaviConnect;
    UsageCategory = Administration;
    Caption = 'XML Stylesheet Deploy from Azure';

    layout
    {
        area(Content)
        {
            field("XML Stylesheet"; XmlStylesheet)
            {
                ApplicationArea = NPRNaviConnect;
                Caption = 'XML Stylesheet';
                Lookup = true;
                ToolTip = 'Specifies the value of the XML Stylesheet field';
                trigger OnLookup(var SelectedValue: Text): Boolean
                var
                    rapidstartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
                    AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
                    xmlStyleList: List of [Text];
                    TempRetailList: Record "NPR Retail List" temporary;
                    xmlStyle: Text;
                    BaseUri: Text;
                    Secret: Text;
                begin
                    BaseUri := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataBaseUrl');
                    Secret := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataSecret');

                    rapidstartBaseDataMgt.GetAllPackagesInBlobStorage(BaseUri + '/xmlstylesheet/?restype=container&comp=list'
                        + '&sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret, xmlStyleList);

                    foreach xmlStyle in xmlStyleList do begin
                        TempRetailList.Number += 1;
                        TempRetailList.Value := xmlStyle;
                        TempRetailList.Choice := xmlStyle;
                        TempRetailList.Insert();
                    end;

                    if Page.Runmodal(Page::"NPR Retail List", TempRetailList) <> Action::LookupOK then
                        exit(false);

                    SelectedValue := TempRetailList.Value;
                    exit(true);
                end;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionFinish)
            {
                ApplicationArea = NPRNaviConnect;
                Caption = 'Finish';
                InFooterBar = true;
                ToolTip = 'Executes the Finish action';
                Image = Action;

                trigger OnAction()
                var
                    AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
                    BaseURL: Text;
                begin
                    BaseURL := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataBaseUrl') + '/xmlstylesheet/';
                    DownloadXmlStylesheet(BaseURL);
                    CurrPage.Close();
                end;
            }
        }
    }

    local procedure DownloadXmlStylesheet(TemplateUrl: Text)
    var
        NcImportType: Record "NPR Nc Import Type";
        Client: HttpClient;
        Response: HttpResponseMessage;
        InStr: InStream;
        OutStr: OutStream;
    begin
        if TemplateUrl = '' then
            exit;

        NcImportType.Get(ImportyTypeCode);
        if NcImportType."XML Stylesheet".HasValue then
            if not Confirm(Text001) then
                exit;

        Client.UseDefaultNetworkWindowsAuthentication();
        Client.Get(TemplateUrl + XmlStylesheet, Response);

        if Response.IsSuccessStatusCode then begin
            NcImportType."XML Stylesheet".CreateOutStream(OutStr);
            Response.Content.ReadAs(InStr);
            CopyStream(OutStr, InStr);
            NcImportType.Modify();
        end else
            Error(Response.ReasonPhrase);
    end;

    procedure Initialize(SetImportyTypeCode: Code[20])
    begin
        ImportyTypeCode := SetImportyTypeCode;
    end;

    var
        ImportyTypeCode: Code[20];
        XmlStylesheet: Text;
        Text001: Label 'Current XML Stylesheet is not empty. Do you want to update it?';
}