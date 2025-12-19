#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248572 "NPR Spfy Ecommerce Order Exp" implements "NPR Feature Management"
{
    Access = Internal;

    procedure AddFeature()
    var
        Feature: Record "NPR Feature";
        FeatureDescriptionLbl: Label 'Shopify Ecommerce Order Experience', MaxLength = 2048;
    begin
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := FeatureDescriptionLbl;
        Feature.Validate(Feature, "NPR Feature"::"Shopify Ecommerce Order Experience");
        Feature.Insert();
    end;

    procedure IsFeatureEnabled(): Boolean
    var
        Feature: Record "NPR Feature";
    begin
        if (not Feature.Get(GetFeatureId())) then
            exit(false);

        exit(Feature.Enabled);
    end;

    procedure SetFeatureEnabled(NewEnabled: Boolean)
    var
        Feature: Record "NPR Feature";
    begin
        if not Feature.Get(GetFeatureId()) then
            exit;

        if (Feature.Enabled = NewEnabled) then
            exit;

        Feature.Validate(Enabled, NewEnabled);
        Feature.Modify();
    end;

    internal procedure GetFeatureId(): Text[50]
    var
        FeatureDescriptionLbl: Label 'ShopifyEcommOrderExp', Locked = true;
    begin
#pragma warning restore AA0139
        exit(FeatureDescriptionLbl);
#pragma warning disable AA0139
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure NPRFeatureOnBeforeValidateEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature"; CurrFieldNo: Integer)
    var
        SpfyIntNotEnabledErr: Label 'Please enable %1 first before enabling this feature.', Comment = '%1 Feature Description';
    begin
        if not (Rec.Id = GetFeatureId()) or (CurrFieldNo = 0) then
            exit;
        if Rec.Enabled then
            if not SpfyIntegrationFeature.IsFeatureEnabled() then
                RaiseError(StrSubstNo(SpfyIntNotEnabledErr, SpfyIntegrationFeature.GetFeatureDescription()));
        HandleJobQueues(Rec);
    end;

    local procedure HandleJobQueues(Rec: Record "NPR Feature")
    var
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
    begin
        if Rec.Enabled then begin
            DisableJobQueues(Format(Codeunit::"NPR Spfy Order Mgt."), Rec);
            SpfyEcomSalesDocPrcssr.SetupJobQueues();
        end else begin
            DisableJobQueues(StrSubstNo('%1|%2', Codeunit::"NPR Spfy Order Import JQ", Codeunit::"NPR Spfy Event Doc ProcessorJQ"), Rec);
            if SpfyIntegrationFeature.IsFeatureEnabled() then
                OrderMgt.SetupJobQueues();
        end;
    end;

    local procedure DisableJobQueues(FormatedCodeunitId: Text; Rec: Record "NPR Feature")
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueDict: Dictionary of [Guid, Boolean];
        JobQueueKey: Guid;
    begin
        JobQueueEntry.Reset();
        JobQueueEntry.SetFilter("Object ID to Run", FormatedCodeunitId);
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        if JobQueueEntry.FindSet() then
            repeat
                JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
                if not JobQueueDict.ContainsKey(JobQueueEntry.ID) then
                    JobQueueDict.Add(JobQueueEntry.ID, true)
            until JobQueueEntry.Next() = 0;

        Clear(JobQueueEntry);
        CheckForUnprocessedEntries(Rec);
        foreach JobQueueKey in JobQueueDict.Keys do
            if JobQueueEntry.Get(JobQueueKey) then
                JobQueueEntry.Delete(true);
    end;

    local procedure CheckForUnprocessedEntries(Rec: Record "NPR Feature")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
        UserContinued: Boolean;
        ContrinueDisableCarefullyMsg: Label 'There are Orders in the %1 that were processed with errors. Disabling %2 feature may cause those orders in the %1 to remain unprocessed. Do you want to continue?', Comment = '%1= tablecaption;%2 = Feature description';
        ContrinueEnableCarefullyMsg: Label 'There are Orders in the %1 that were processed with errors. Enabling %2 feature may cause those orders in the %1 to remain unprocessed. Do you want to continue?', Comment = '%1= tablecaption;%2 = Feature description';
        PendingEventLogEntriesErr: Label 'Disabling the %1 feature is not possible because there are unprocessed event log entries in Ready status that must be handled first.', Comment = '%1 = Feature description';
        PendingImportEntriesErr: Label 'Enabling the %1 feature is not possible because there are unprocessed import types that must be handled first.', Comment = '%1=Feature description';
    begin
        If Rec.Enabled then begin
            If not ShopifySetup.Get() then
                exit;
            ImportEntry.SetCurrentKey("Import Type", Imported);
            ImportEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
            ImportEntry.SetFilter("Import Type", MapAllImportTypeCodes(ShopifySetup."Data Processing Handler ID"));
            ImportEntry.SetRange(Imported, false);
            ImportEntry.SetRange("Runtime Error", true);
            if not ImportEntry.IsEmpty() then
                UserContinued := GetUserResponse(StrSubstNo(ContrinueEnableCarefullyMsg, ImportEntry.TableCaption(), Rec.Description));
            ImportEntry.SetRange("Runtime Error");
            if not ImportEntry.IsEmpty() then
                RaiseError(StrSubstNo(PendingImportEntriesErr, Rec.Description));
            if UserContinued then
                EmitUserDecisionToTelemetry(Rec.Description);
        end else begin
            SpfyEventLogEntry.SetCurrentKey("Processing Status");
            SpfyEventLogEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
            SpfyEventLogEntry.SetRange("Processing Status", SpfyEventLogEntry."Processing Status"::Error);
            IF not SpfyEventLogEntry.IsEmpty() then
                UserContinued := GetUserResponse(StrSubstNo(ContrinueDisableCarefullyMsg, SpfyEventLogEntry.TableCaption(), Rec.Description));
            SpfyEventLogEntry.SetRange("Processing Status", SpfyEventLogEntry."Processing Status"::Ready);
            IF not SpfyEventLogEntry.IsEmpty() then
                RaiseError(StrSubstNo(PendingEventLogEntriesErr, Rec.Description));
            if UserContinued then
                EmitUserDecisionToTelemetry(Rec.Description);
        end;
    end;

    local procedure GetUserResponse(QuestionTxt: text) UserContinued: Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if not ConfirmManagement.GetResponseOrDefault(QuestionTxt, false) then
            Error('');

        UserContinued := true;
    end;

    local procedure EmitUserDecisionToTelemetry(FeatureDescription: Text)
    var
        ActiveSession: Record "Active Session";
        CustomDimensions: Dictionary of [Text, Text];
        MessageLbl: Label 'The user has enabled %1 feature even though there are records with errors.', Comment = '%1=Feature description', Locked = true;
    begin
        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            ActiveSession.Init();

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_SessionId', Format(Database.SessionId(), 0, 9));
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");

        Session.LogMessage('NPR_ShopifyEcommOrderExp_Enabled', StrSubstNo(MessageLbl, FeatureDescription), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    local procedure MapAllImportTypeCodes(HandlerId: Code[20]): Text
    var
        CreateTxt: Text;
        DeleteTxt: Text;
        PostTxt: Text;
    begin
        CreateTxt := StrSubstNo('%1_CREATE_ORDER', HandlerId);
        PostTxt := StrSubstNo('%1_POST_ORDER', HandlerId);
        DeleteTxt := StrSubstNo('%1_DELETE_ORDER', HandlerId);

        exit(StrSubstNo('%1|%2|%3', CreateTxt, PostTxt, DeleteTxt));
    end;

    local procedure RaiseError(InputTxt: Text)
    begin
        Message(InputTxt);
        Error('');
    end;

    var
        SpfyIntegrationFeature: Codeunit "NPR Spfy Integration Feature";
}
#endif