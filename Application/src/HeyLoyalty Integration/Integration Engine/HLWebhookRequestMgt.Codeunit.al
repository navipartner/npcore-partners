codeunit 6150948 "NPR HL Webhook Request Mgt."
{
    Access = Internal;

    var
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";

    procedure ProcessWebhookRequests(var HLWebhookRequestIn: Record "NPR HL Webhook Request"; WithDialog: Boolean)
    var
        HLWebhookRequest: Record "NPR HL Webhook Request";
        HLWebhookRequest2: Record "NPR HL Webhook Request";
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
        SuccessNo: Integer;
        DoneLbl: Label 'Done. Successfully proccessed %1 out of %2 requests.';
        NothingToDoErr: Label 'No requests were found for processing. Please note that system will process only requests with "%1" set to values "%2" or "%3".', Comment = '%1 - Field "Processing Status" caption, %2, %3 - "New" and "Error" processing status values.';
        WindowTxt001: Label 'Processing HeyLoyalty Webhook requests...\\';
        WindowTxt002: Label 'Request #1##### of #2#####\';
    begin
        HLWebhookRequest.Copy(HLWebhookRequestIn);
        HLWebhookRequest.FilterGroup(2);
        HLWebhookRequest.SetFilter("Processing Status", '%1|%2', HLWebhookRequest."Processing Status"::New, HLWebhookRequest."Processing Status"::Error);
        HLWebhookRequest.FilterGroup(0);
        if HLWebhookRequest.IsEmpty() then begin
            HLWebhookRequest."Processing Status" := HLWebhookRequest."Processing Status"::New;
            HLWebhookRequest2."Processing Status" := HLWebhookRequest2."Processing Status"::Error;
            Error(NothingToDoErr, HLWebhookRequest.FieldCaption("Processing Status"), HLWebhookRequest."Processing Status", HLWebhookRequest2."Processing Status");
        end;

        if WithDialog then begin
            Window.Open(
                WindowTxt001 +
                WindowTxt002
            );
            RecNo := 0;
            TotalRecNo := HLWebhookRequest.Count();
            Window.Update(2, TotalRecNo);
        end;

        if HLWebhookRequest.FindSet() then
            repeat
                if WithDialog then begin
                    RecNo += 1;
                    Window.Update(1, RecNo);
                end;

                HLWebhookRequest2 := HLWebhookRequest;
                if ProcessWebhookRequest(HLWebhookRequest2) then
                    SuccessNo += 1;
            until HLWebhookRequest.Next() = 0;

        if WithDialog then begin
            Window.Close();
            Message(DoneLbl, SuccessNo, TotalRecNo);
        end;
    end;

    procedure ProcessWebhookRequest(var HLWebhookRequest: Record "NPR HL Webhook Request") Success: Boolean
    var
    begin
        Commit();
        ClearLastError();

        case true of
            IsConnectionTest(HLWebhookRequest):
                begin
                    HLWebhookRequest.SetStatusFinished();  //has a commit
                    Success := true;
                end;
            else
                Success := Codeunit.Run(Codeunit::"NPR HL Member Webhook Handler", HLWebhookRequest);
        end;

        if not Success then
            if HLWebhookRequest.Find() then
                HLWebhookRequest.SetStatusError(GetLastErrorText());  //has a commit
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR HL Webhook Request", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnNewHLWebhookRequest(var Rec: Record "NPR HL Webhook Request")
    begin
        if Rec.IsTemporary() or (Rec."Processing Status" <> Rec."Processing Status"::New) then
            exit;
        if not IsConnectionTest(Rec) then
            if not HLIntegrationMgt.IsEnabled("NPR HL Integration Area"::Members) then
                exit;

        ProcessWebhookRequest(Rec);
    end;

    local procedure IsConnectionTest(HLWebhookRequest: Record "NPR HL Webhook Request"): Boolean
    var
        ConnectionTestTok: Label 'CONNECTION TEST', Locked = true;
    begin
        exit(UpperCase(HLWebhookRequest."HL Request Type") = ConnectionTestTok);
    end;
}