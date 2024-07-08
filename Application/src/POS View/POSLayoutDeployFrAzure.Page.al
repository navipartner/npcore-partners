page 6150761 "NPR POS Layout Deploy Fr.Azure"
{
    Extensible = False;
    PageType = NavigatePage;
    UsageCategory = None;
    Caption = 'Deploy POS Layouts from Azure';

    layout
    {
        area(Content)
        {
            field("POS Layout"; PosLayoutPackageName)
            {
                Caption = 'POS Layout';
                ApplicationArea = NPRRetail;
                ToolTip = 'Select a POS layout package to deploy from.';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    exit(LookupPosLayoutPackage(Text));
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
    local procedure LookupPosLayoutPackage(var Text: Text): Boolean
    var
        TempRetailList: Record "NPR Retail List" temporary;
        RapidStartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
        PackageList: List of [Text];
        Package: Text;
        AzureUriLbl: Label '%1/?restype=container&comp=list&%2%3', Comment = '%1 - Base Uri, %2 - Uri extension, %3 - Secret';
    begin
        RapidstartBaseDataMgt.GetAllPackagesInBlobStorage(
            StrSubstNo(AzureUriLbl, PosLayoutsAzureDataUrl(), UriFilterParametersLbl, AzureNpRetailBaseDataSecret()), PackageList);
        foreach Package in PackageList do begin
            TempRetailList.Number += 1;
            TempRetailList.Value := CopyStr(Package, 1, MaxStrLen(TempRetailList.Value));
            TempRetailList.Choice := CopyStr(Package, 1, MaxStrLen(TempRetailList.Choice));
            TempRetailList.Insert();
        end;

        if Page.Runmodal(Page::"NPR Retail List", TempRetailList) <> Action::LookupOK then
            exit(false);
        Text := TempRetailList.Value;
        exit(true);
    end;

    [NonDebuggable]
    local procedure OnFinishAction()
    var
        ManagedPackageMgt: Codeunit "NPR Managed Package Mgt.";
        AzureUriLbl: Label '%1/%2?%3%4', Comment = '%1 - Base Uri, %2 - Package name, %3 - Uri extension, %4 - Secret';
        NothingSelectedErr: Label 'Please select a remote POS layout package first.';
    begin
        if PosLayoutPackageName = '' then
            Error(NothingSelectedErr);
        ManagedPackageMgt.AddExpectedTableID(Database::"NPR POS Layout");
        ManagedPackageMgt.DeployPackageFromURL(
            StrSubstNo(AzureUriLbl, PosLayoutsAzureDataUrl(), PosLayoutPackageName, UriFilterParametersLbl, AzureNpRetailBaseDataSecret()));
        CurrPage.Close();
    end;

    [NonDebuggable]
    local procedure PosLayoutsAzureDataUrl(): Text
    var
        BaseData: Codeunit "NPR Base Data";
        AzureUriLbl: Label '%1/poslayouts', Comment = '%1 - Base Uri';
    begin
        exit(StrSubstNo(AzureUriLbl, BaseData.GetBaseUrl()));
    end;

    [NonDebuggable]
    local procedure AzureNpRetailBaseDataSecret(): Text
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        exit(AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailBaseDataSecret'));
    end;

    var
        PosLayoutPackageName: Text;
        UriFilterParametersLbl: Label 'sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=';
}
