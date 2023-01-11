﻿page 6151554 "NPR NpXml Templ. Dep. From Az."
{
    Extensible = False;
    PageType = NavigatePage;

    UsageCategory = Administration;
    Caption = 'XML Template Deploy from Azure';
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            field("XML Template"; XmlTemplates)
            {

                Caption = 'XML Template';
                Lookup = true;
                ToolTip = 'Specifies the value of the XmlTemplate field';
                ApplicationArea = NPRRetail;
                trigger OnLookup(var SelectedValues: Text): Boolean
                begin
                    exit(OnLookupXMLTemplate(SelectedValues));
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

                Caption = 'Finish';
                InFooterBar = true;
                ToolTip = 'Executes the Finish action';
                Image = Action;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    OnFinishAction();
                end;
            }
        }
    }



    [NonDebuggable]
    local procedure OnFinishAction()
    var
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        XmlTemplateList: List of [Text];
        XmlTemplate: Text;
        TemplateCode: Text;
        BaseURL: Text;
    begin
        XmlTemplateList := XmlTemplates.Split(',');
        foreach XmlTemplate in XmlTemplateList do begin
            BaseURL := AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailBaseDataBaseUrl') + '/npxml/' + XmlTemplate.Substring(1, XmlTemplate.LastIndexOf('/'));
            TemplateCode := XmlTemplate.Substring(XmlTemplate.LastIndexOf('/') + 1);
            TemplateCode := TemplateCode.Substring(1, TemplateCode.IndexOf('.xml') - 1);
            NpXmlTemplateMgt.ImportNpXmlTemplateUrl(CopyStr(TemplateCode, 1, 20), BaseURL);
        end;
        CurrPage.Close();
    end;

    [NonDebuggable]
    local procedure OnLookupXMLTemplate(var SelectedValues: Text): Boolean
    var
        rapidstartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        packageList: List of [Text];
        TempRetailList: Record "NPR Retail List" temporary;
        RetailListPage: Page "NPR Retail List";
        package: Text;
        BaseUri: Text;
        Secret: Text;
    begin
        BaseUri := AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailBaseDataBaseUrl');
        Secret := AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailBaseDataSecret');

        rapidstartBaseDataMgt.GetAllPackagesInBlobStorage(BaseUri + '/npxml/?restype=container&comp=list'
            + '&sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret, packageList);

        foreach package in packageList do begin
            TempRetailList.Number += 1;
            TempRetailList.Value := CopyStr(package, 1, MaxStrLen(TempRetailList.Value));
            TempRetailList.Choice := CopyStr(package, 1, MaxStrLen(TempRetailList.Choice));
            TempRetailList.Insert();
        end;

        RetailListPage.LookupMode(true);
        RetailListPage.SetRec(TempRetailList);
        if RetailListPage.RunModal() <> Action::LookupOK then
            exit(false);

        SelectedValues := '';
        RetailListPage.GetSelectionFilter(TempRetailList);
        TempRetailList.MarkedOnly(true);
        if TempRetailList.FindSet() then
            repeat
                if StrLen(SelectedValues) > 0 then
                    SelectedValues += ',';
                SelectedValues += TempRetailList.Value;
            until TempRetailList.Next() = 0;

        exit(true);
    end;

    var
        XmlTemplates: Text;
}
