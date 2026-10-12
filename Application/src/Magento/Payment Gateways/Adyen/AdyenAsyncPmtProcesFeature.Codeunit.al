codeunit 6248661 "NPR AdyenAsyncPmtProcesFeature" implements "NPR Feature Management"
{
    Access = Internal;

    procedure AddFeature()
    var
        Feature: Record "NPR Feature";
    begin
        if Feature.Get(GetFeatureId()) then
            exit;
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := GetFeatureDescription();
        Feature.Validate(Feature, Enum::"NPR Feature"::"Async Adyen Payment Processing");
        Feature.Insert();
    end;

    procedure IsFeatureEnabled(): Boolean
    var
        Feature: Record "NPR Feature";
    begin
        if not Feature.Get(GetFeatureId()) then
            exit(false);
        exit(Feature.Enabled);
    end;

    procedure SetFeatureEnabled(NewEnabled: Boolean)
    var
        Feature: Record "NPR Feature";
    begin
        if not Feature.Get(GetFeatureId()) then
            exit;

        Feature.Enabled := NewEnabled;
        Feature.Modify();
    end;

    local procedure GetFeatureId(): Text[50]
    var
        FeatureIdTok: Label 'asynchAdyenPaymentProcessing', Locked = true, MaxLength = 50;
    begin
        exit(FeatureIdTok);
    end;

    local procedure GetFeatureDescription(): Text[2048]
    var
        FeatureDescriptionLbl: Label 'Asynchronous Adyen Payment Processing', MaxLength = 2024;
    begin
        exit(FeatureDescriptionLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure NPRFeatureOnBeforeValidateEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature"; CurrFieldNo: Integer)
    var
        MerchantAccount: Record "NPR Adyen Merchant Account";
        ConfirmManagement: Codeunit "Confirm Management";
        ConfirmCreateWebhooksLbl: Label 'Enabling this feature will set up a webhook for CAPTURE and CAPTURE_FAILED on every %1 that does not already have one. Do you want to continue?', Comment = '%1 = NP Pay Merchant Account table caption';
        DisableWithCapturesInFlightQst: Label 'Some payment lines have an Adyen capture waiting for confirmation. While this feature is disabled the confirmations are not processed, and those lines stay uncaptured until the feature is enabled again or the capture request is reset. Do you want to disable the feature?';
    begin
        if not (Rec.Id = GetFeatureId()) then
            exit;
        if CurrFieldNo <> Rec.FieldNo(Enabled) then
            exit;
        if not Rec.Enabled and HasCapturesInFlight() then
            if not ConfirmManagement.GetResponseOrDefault(DisableWithCapturesInFlightQst, false) then
                Error('');
        if Rec.Enabled then
            if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(ConfirmCreateWebhooksLbl, MerchantAccount.TableCaption), false) then
                Error('');
        ApplyProcessing(Rec);
    end;

    /// <summary>
    /// True when an Adyen payment line on a document the CAPTURE webhook handles is still waiting for capture confirmation.
    /// </summary>
    internal procedure HasCapturesInFlight(): Boolean
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentGateway.SetRange("Integration Type", Enum::"NPR PG Integrations"::Adyen);
        if not PaymentGateway.FindSet() then
            exit(false);

        PaymentLine.SetRange("Capture Requested", true);
        PaymentLine.SetRange("Date Captured", 0D);
        repeat
            PaymentLine.SetRange("Payment Gateway Code", PaymentGateway.Code);

            PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
            PaymentLine.SetRange("Document Type");
            if not PaymentLine.IsEmpty() then
                exit(true);

            PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
            PaymentLine.SetFilter("Document Type", '%1|%2', PaymentLine."Document Type"::Order, PaymentLine."Document Type"::Invoice);
            if not PaymentLine.IsEmpty() then
                exit(true);
        until PaymentGateway.Next() = 0;
        exit(false);
    end;

    local procedure ApplyProcessing(Rec: Record "NPR Feature")
    var
        AdyenCaptureWebhookJQ: Codeunit "NPR Adyen Async Pay ProcessJQ";
        AsyncAdyenPayProcessing: Codeunit "NPR Async Adyen Pmt Processing";
    begin
        if Rec.Enabled then begin
            AsyncAdyenPayProcessing.EnsureCaptureWebhooks();
            AdyenCaptureWebhookJQ.ScheduleJobQueue();
        end else
            DisableJobQueue(AdyenCaptureWebhookJQ.GetCodeunitId());
    end;

    local procedure DisableJobQueue(CodeunitId: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        MonitoredJQMgt: Codeunit "NPR Monitored Job Queue Mgt.";
    begin
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object ID to Run", CodeunitId);
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        if JobQueueEntry.FindSet() then
            repeat
                MonitoredJQMgt.DeleteMonitoredJobQueueEntry(JobQueueEntry);
            until JobQueueEntry.Next() = 0;

        // A monitored entry left without its job makes the job queue refresher recreate the job or fail on every run.
        MonitoredJQEntry.SetCurrentKey("Object ID to Run", "Object Type to Run");
        MonitoredJQEntry.SetRange("Object ID to Run", CodeunitId);
        MonitoredJQEntry.SetRange("Object Type to Run", MonitoredJQEntry."Object Type to Run"::Codeunit);
        if not MonitoredJQEntry.IsEmpty() then
            MonitoredJQEntry.DeleteAll(true);
    end;

}
