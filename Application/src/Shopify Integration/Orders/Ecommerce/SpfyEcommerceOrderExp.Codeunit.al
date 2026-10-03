#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248572 "NPR Spfy Ecommerce Order Exp" implements "NPR Feature Management"
{
    Access = Internal;

    procedure AddFeature()
    var
        Feature: Record "NPR Feature";
    begin
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := GetFeatureDescription();
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

    internal procedure GetFeatureDescription(): Text[2048]
    var
        FeatureDescriptionLbl: Label 'Shopify Ecommerce Order Experience', MaxLength = 2048;
    begin
        exit(FeatureDescriptionLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure NPRFeatureOnBeforeValidateEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature"; CurrFieldNo: Integer)
    var
        SpfyIntNotEnabledErr: Label 'Please enable %1 first before enabling this feature.', Comment = '%1 Feature Description';
    begin
        if not (Rec.Id = GetFeatureId()) or (CurrFieldNo = 0) then
            exit;
        if Rec.Enabled then begin
            if not SpfyIntegrationFeature.IsFeatureEnabled() then
                RaiseError(StrSubstNo(SpfyIntNotEnabledErr, SpfyIntegrationFeature.GetFeatureDescription()));
        end;
        HandleJobQueues(Rec);
    end;

    // A page saves the flag on a later round trip than the validate check, so the queue is checked again when the row is saved.
    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnAfterModifyEvent', '', false, false)]
    local procedure NPRFeatureOnAfterModify(var Rec: Record "NPR Feature"; RunTrigger: Boolean)
    begin
        if not RunTrigger or not Rec.Enabled or (Rec.Id <> GetFeatureId()) then
            exit;
        RefuseWhileLegacyReturnsPending(Rec, true);
    end;

    /// <summary>
    /// Under the lock the legacy poll and job take before they write: a row committed first refuses the switch, a switch committed first stops them.
    /// </summary>
    local procedure RefuseWhileLegacyReturnsPending(Feature: Record "NPR Feature"; UnderLock: Boolean)
    var
        LegacyReturnQueue: Record "NPR Spfy Legacy Return Queue";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        PendingLegacyReturnsErr: Label 'Enabling the %2 feature is not possible because there are unprocessed entries in the %1 that must be handled first.', Comment = '%1 = table caption, %2 = feature description';
    begin
        if UnderLock then
            if SpfyLegacyReturnMgt.FeatureSwitchedOn() then;
        LegacyReturnQueue.SetCurrentKey(Status);
        LegacyReturnQueue.ReadIsolation := IsolationLevel::ReadUncommitted;
        LegacyReturnQueue.SetFilter(Status, '%1|%2|%3', LegacyReturnQueue.Status::New, LegacyReturnQueue.Status::Processing, LegacyReturnQueue.Status::"Draft Created");
        if not LegacyReturnQueue.IsEmpty() then
            RaiseError(StrSubstNo(PendingLegacyReturnsErr, LegacyReturnQueue.TableCaption(), Feature.Description));
    end;

    internal procedure HandleJobQueues(Feature: Record "NPR Feature")
    var
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
    begin
        if Feature.Enabled then begin
            DisableJobQueues(StrSubstNo('%1|%2|%3', Codeunit::"NPR Spfy Order Mgt.", Codeunit::"NPR Spfy Legacy Return Poll JQ", Codeunit::"NPR Spfy Legacy Return Proc JQ"), Feature);
            SpfyEcomSalesDocPrcssr.SetupJobQueues();
        end else begin
            CheckForUnprocessedEntries(Feature);
            SpfyOrderImportJQ.SetupJobQueue(false);
            SpfyEventDocProcessorJQ.SetupJobQueue(false);
            if SpfyIntegrationFeature.IsFeatureEnabled() then begin
                OrderMgt.SetupJobQueues();
                // Pass the new state: the feature row is not saved yet, so OrderMgt still reads the old one.
                SpfyLegacyReturnPollJQ.SetupJobQueues(false);
            end;
        end;
    end;

    local procedure DisableJobQueues(FormatedCodeunitId: Text; Rec: Record "NPR Feature")
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
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
        // Deleting the entry alone leaves its monitored row, from which the refresher recreates a protected job.
        foreach JobQueueKey in JobQueueDict.Keys do
            if JobQueueEntry.Get(JobQueueKey) then
                JobQueueMgt.CancelNpManagedJob(JobQueueEntry);
    end;

    internal procedure CheckForUnprocessedEntries(Feature: Record "NPR Feature")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
        LegacyReturnQueue: Record "NPR Spfy Legacy Return Queue";
        UserContinued: Boolean;
        ContrinueDisableCarefullyMsg: Label 'There are Orders in the %1 that were processed with errors. Disabling %2 feature may cause those orders in the %1 to remain unprocessed. Do you want to continue?', Comment = '%1= tablecaption;%2 = Feature description';
        ContrinueEnableCarefullyMsg: Label 'There are Orders in the %1 that were processed with errors. Enabling %2 feature may cause those orders in the %1 to remain unprocessed. Do you want to continue?', Comment = '%1= tablecaption;%2 = Feature description';
        PendingEventLogEntriesErr: Label 'Disabling the %1 feature is not possible because there are unprocessed event log entries in Ready status that must be handled first.', Comment = '%1 = Feature description';
        PendingImportEntriesErr: Label 'Enabling the %1 feature is not possible because there are unprocessed import types that must be handled first.', Comment = '%1=Feature description';
        ContinueEnableWithFailedLegacyReturnsMsg: Label 'There are returns in the %1 that failed or were dismissed. Enabling the %2 feature may leave the failed ones unprocessed and import the dismissed ones again through e-commerce documents, since a return handled by hand carries no document the e-commerce import recognises. Do you want to continue?', Comment = '%1 = Shopify Legacy Return Queue table caption, %2 = feature description';
    begin
        If Feature.Enabled then begin
            RefuseWhileLegacyReturnsPending(Feature, false);
            LegacyReturnQueue.SetCurrentKey(Status);
            LegacyReturnQueue.ReadIsolation := IsolationLevel::ReadUncommitted;
            LegacyReturnQueue.SetFilter(Status, '%1|%2', LegacyReturnQueue.Status::Error, LegacyReturnQueue.Status::Dismissed);
            if not LegacyReturnQueue.IsEmpty() then
                UserContinued := GetUserResponse(StrSubstNo(ContinueEnableWithFailedLegacyReturnsMsg, LegacyReturnQueue.TableCaption(), Feature.Description));
            If not ShopifySetup.Get() then
                exit;
            ImportEntry.SetCurrentKey("Import Type", Imported);
            ImportEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
            ImportEntry.SetFilter("Import Type", MapAllImportTypeCodes(ShopifySetup."Data Processing Handler ID"));
            ImportEntry.SetRange(Imported, false);
            ImportEntry.SetRange("Runtime Error", true);
            if not ImportEntry.IsEmpty() then
                UserContinued := GetUserResponse(StrSubstNo(ContrinueEnableCarefullyMsg, ImportEntry.TableCaption(), Feature.Description));
            ImportEntry.SetRange("Runtime Error");
            if not ImportEntry.IsEmpty() then
                RaiseError(StrSubstNo(PendingImportEntriesErr, Feature.Description));
            if UserContinued then
                EmitUserDecisionToTelemetry(Feature.Description);
        end else begin
            SpfyEventLogEntry.SetCurrentKey("Processing Status");
            SpfyEventLogEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
            SpfyEventLogEntry.SetRange("Processing Status", SpfyEventLogEntry."Processing Status"::Error);
            IF not SpfyEventLogEntry.IsEmpty() then
                UserContinued := GetUserResponse(StrSubstNo(ContrinueDisableCarefullyMsg, SpfyEventLogEntry.TableCaption(), Feature.Description));
            SpfyEventLogEntry.SetRange("Processing Status", SpfyEventLogEntry."Processing Status"::Ready);
            IF not SpfyEventLogEntry.IsEmpty() then
                RaiseError(StrSubstNo(PendingEventLogEntriesErr, Feature.Description));
            if UserContinued then
                EmitUserDecisionToTelemetry(Feature.Description);
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