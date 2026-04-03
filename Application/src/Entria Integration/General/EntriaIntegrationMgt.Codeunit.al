#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6150987 "NPR Entria Integration Mgt."
{
    Access = Internal;
    SingleInstance = true;

    var
        _EntriaSetup: Record "NPR Entria Integration Setup";
        _EntriaStore: Record "NPR Entria Store";

    internal procedure CheckIsEnabled(EntriaStoreCode: Code[20])
    var
        IntegrationDisabledErr: Label 'NaviPartner BC-Entria integration is disabled. Please open the "Entria Integration Setup" page and enable the integration.';
        IntegrationDisabledAllStoresErr: Label 'NaviPartner BC-Entria integration must be enabled for at least one Entria store. Please open the "Entria Store" page and enable the integration.';
        IntegrationDisabledStoreErr: Label 'NaviPartner BC-Entria integration is disabled for the "%1" Entria store. Please open the "Entria Store" page and enable the integration.', Comment = '%1 - Entria store code';
    begin
        _EntriaSetup.GetRecordOnce(false);
        if not _EntriaSetup."Enable Integration" then
            Error(IntegrationDisabledErr);

        if EntriaStoreCode = '' then begin
            if HasEnabledStore() then
                exit;
            Error(IntegrationDisabledAllStoresErr);
        end;

        if IsEnabled(EntriaStoreCode) then
            exit;
        Error(IntegrationDisabledStoreErr, EntriaStoreCode);
    end;

    internal procedure IsEnabled(EntriaStoreCode: Code[20]): Boolean
    begin
        GetStore(EntriaStoreCode);
        exit(IsStoreEnabled(_EntriaStore));
    end;

    internal procedure HasEnabledStore(): Boolean
    var
        EntriaStore: Record "NPR Entria Store";
    begin
        if ReadySetup() then begin
            EntriaStore.SetRange(Enabled, true);
            exit(not EntriaStore.IsEmpty());
        end;

        exit(false);
    end;

    internal procedure HasEnabledSalesOrderIntegrationStore(): Boolean
    var
        EntriaStore: Record "NPR Entria Store";
    begin
        if ReadySetup() then begin
            EntriaStore.SetLoadFields(Enabled, "Sales Order Integration");
            EntriaStore.SetRange(Enabled, true);
            if EntriaStore.FindSet() then
                repeat
                    if EntriaStore."Sales Order Integration" then
                        exit(true);
                until EntriaStore.Next() = 0;
        end;
        exit(false);
    end;

    local procedure ReadySetup(): Boolean
    begin
        if _EntriaSetup.IsEmpty() then
            exit(false);

        _EntriaSetup.GetRecordOnce(false);
        exit(_EntriaSetup."Enable Integration");
    end;

    internal procedure SetRereadSetup()
    begin
        Clear(_EntriaSetup);
        Clear(_EntriaStore);
        SelectLatestVersion();
    end;

    local procedure GetStore(EntriaStoreCode: Code[20])
    begin
        if EntriaStoreCode = _EntriaStore.Code then
            exit;
        if EntriaStoreCode = '' then
            Clear(_EntriaStore)
        else
            _EntriaStore.Get(EntriaStoreCode);
    end;

    local procedure IsStoreEnabled(EntriaStore: Record "NPR Entria Store"): Boolean
    begin
        if not ReadySetup() then
            exit(false);

        if EntriaStore.Code = '' then
            exit(false);

        exit(EntriaStore.Enabled);
    end;

    internal procedure UpsertConnectionParams(var Rec: Record "NPR Entria Store")
    var
        InputDialog: Page "NPR Input Dialog";
        NewUrl: Text;
        NewKey: Text;
        MaskedKey: Text;
        MaskedLbl: Label '***', Locked = true;
        BaseUrlLbl: Label 'Entria Base Url';
        ParamsSavedMsg: Label 'Connection Parameters saved successfully.';
        SecretKeyLbl: Label 'Secret API Key';
    begin
        if Rec.HasAPIKey() then
            MaskedKey := MaskedLbl;

        NewUrl := Rec."Entria Url";
        InputDialog.SetInput(1, NewUrl, BaseUrlLbl);
        InputDialog.SetInput(2, MaskedKey, SecretKeyLbl);
        if not (InputDialog.RunModal() = Action::OK) then
            exit;

        InputDialog.InputText(1, NewUrl);
        if NewUrl <> Rec."Entria Url" then
            Rec.Validate("Entria Url", NewUrl);

        InputDialog.InputText(2, NewKey);
        if NewKey = '' then begin
            if Rec.HasAPIKey() then
                Rec.DeleteAPIKey();
        end else
            if NewKey <> MaskedLbl then
                Rec.SetAPIKey(NewKey);

        Rec.Modify();
        Message(ParamsSavedMsg);
    end;

    internal procedure ValidateEntriaUrl(var Rec: Record "NPR Entria Store")
    var
        EntriaAPIHandler: Codeunit "NPR Entria API Handler";
        InvalidEntriaUrlErr: Label 'The URL must be a valid Entria store URL.';
    begin
        if (Rec."Entria URL" = '') then
            exit;
#pragma warning disable AA0139
        if not Rec."Entria URL".ToLower().StartsWith('https://') and not Rec."Entria URL".ToLower().StartsWith('http://') then
            Rec."Entria URL" := CopyStr('https://' + Rec."Entria URL", 1, MaxStrLen(Rec."Entria URL"));
        if Rec."Entria URL".ToLower().EndsWith('/admin/') then
            Rec."Entria URL" := CopyStr(Rec."Entria URL", 1, StrLen(Rec."Entria URL") - 7)
        else
            if Rec."Entria URL".ToLower().EndsWith('/admin') then
                Rec."Entria URL" := CopyStr(Rec."Entria URL", 1, StrLen(Rec."Entria URL") - 6);
        if Rec."Entria URL".EndsWith('/') then
            Rec."Entria URL" := CopyStr(Rec."Entria URL", 1, StrLen(Rec."Entria URL") - 1);
#pragma warning restore
        if not EntriaAPIHandler.IsValidEntriaUrl(Rec."Entria URL") then
            Error(InvalidEntriaUrlErr);
    end;

    internal procedure TestEntriaStoreConnection(EntriaStore: Record "NPR Entria Store")
    var
        EntriaAPIHandler: Codeunit "NPR Entria API Handler";
        EntriaResponse: JsonToken;
        Window: Dialog;
        QueryingEntriaLbl: Label 'Testing connection to Entria...';
        SuccessMsg: Label 'Connection successful! Entria backend is reachable and API authentication is working.';
        NoAPIKeyErr: Label 'Please configure the Entria API Key before testing connectivity.';
    begin
        EntriaStore.TestField("Entria Url");
        if not EntriaStore.HasAPIKey() then
            Error(NoAPIKeyErr);

        Window.Open(QueryingEntriaLbl);
        ClearLastError();
        if not EntriaAPIHandler.GetEntriaStoreList(EntriaStore.Code, EntriaResponse) then begin
            Window.Close();
            Error(GetLastErrorText());
        end;
        Window.Close();

        if GuiAllowed() then
            Message(SuccessMsg);
    end;

    internal procedure SetupJobQueues()
    var
        EntriaOrderImportJQ: Codeunit "NPR Entria Order Import JQ";
        MasterSwitch: Boolean;
    begin
        SetRereadSetup();
        MasterSwitch := HasEnabledSalesOrderIntegrationStore();
        EntriaOrderImportJQ.SetupJobQueue(MasterSwitch);
    end;

    internal procedure HasRunningEntriaJob(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetCurrentKey("Object Type to Run", "Object ID to Run", Status);
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Entria Order Import JQ");
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"In Process");
        exit(not JobQueueEntry.IsEmpty());
    end;
}
#endif