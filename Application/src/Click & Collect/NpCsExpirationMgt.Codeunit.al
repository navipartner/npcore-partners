codeunit 6151207 "NPR NpCs Expiration Mgt."
{
    TableNo = "NPR NpCs Document";

    trigger OnRun()
    begin
        if Rec."Entry No." = 0 then
            UpdateExpirationStatusAll(Rec.Type::"Collect in Store", false)
        else
            if Rec.Find() then
                UpdateExpirationStatus(Rec, false);
    end;

    procedure SetExpiresAt(var NpCsDocument: Record "NPR NpCs Document")
    begin
        if NpCsDocument."Delivery Status" in [NpCsDocument."Delivery Status"::Delivered, NpCsDocument."Delivery Status"::Expired] then
            exit;
        if NpCsDocument."Processing Status" in [NpCsDocument."Processing Status"::Rejected, NpCsDocument."Processing Status"::Expired] then
            exit;

        if NpCsDocument."Delivery Status" = NpCsDocument."Delivery Status"::Ready then begin
            if NpCsDocument."Delivery expires at" <> 0DT then
                exit;
            if NpCsDocument."Delivery Expiry Days (Qty.)" <= 0 then
                exit;

            NpCsDocument."Delivery expires at" := CalcDeliveryExpiresAt(NpCsDocument);

            exit;
        end;

        if NpCsDocument."Processing expires at" <> 0DT then
            exit;
        if NpCsDocument."Processing Expiry Duration" <= 0 then
            exit;

        NpCsDocument."Processing expires at" := CalcProcessingExpiresAt(NpCsDocument);
    end;

    local procedure CalcProcessingExpiresAt(NpCsDocument: Record "NPR NpCs Document") ExpiresAt: DateTime
    var
        NpCsStoreOpeningHoursMgt: Codeunit "NPR NpCs Store Open.Hours Mgt.";
    begin
        if NpCsDocument."Processing Expiry Duration" <= 0 then
            exit(0DT);
        if NpCsDocument."Processing updated at" = 0DT then
            NpCsDocument."Processing updated at" := CurrentDateTime;

        ExpiresAt := NpCsStoreOpeningHoursMgt.CalcNextOpeningDTDuration(NpCsDocument."Opening Hour Set", NpCsDocument."Processing updated at", NpCsDocument."Processing Expiry Duration");
        exit(ExpiresAt);
    end;

    local procedure CalcDeliveryExpiresAt(NpCsDocument: Record "NPR NpCs Document") ExpiresAt: DateTime
    var
        NpCsStoreOpeningHoursMgt: Codeunit "NPR NpCs Store Open.Hours Mgt.";
    begin
        if NpCsDocument."Delivery Expiry Days (Qty.)" <= 0 then
            exit(0DT);
        if NpCsDocument."Processing updated at" = 0DT then
            NpCsDocument."Processing updated at" := CurrentDateTime;

        ExpiresAt := NpCsStoreOpeningHoursMgt.CalcNextClosingDTDaysQty(NpCsDocument."Opening Hour Set", NpCsDocument."Processing updated at", NpCsDocument."Delivery Expiry Days (Qty.)");
        exit(ExpiresAt);
    end;

    local procedure UpdateExpirationStatusAll(Type: Integer; SkipWorkflow: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if Type in [NpCsDocument.Type::"Send to Store", NpCsDocument.Type::"Collect in Store"] then
            NpCsDocument.SetRange(Type, Type);
        NpCsDocument.SetFilter("Processing expires at", '<=%1&<>%2', CurrentDateTime, 0DT);
        NpCsDocument.SetFilter("Processing Status", '=%1|=%2', NpCsDocument."Processing Status"::" ", NpCsDocument."Processing Status"::Pending);
        NpCsDocument.SetFilter("Delivery Status", '<>%1&<>%2', NpCsDocument."Delivery Status"::Delivered, NpCsDocument."Delivery Status"::Expired);
        if NpCsDocument.FindSet() then
            repeat
                UpdateExpirationStatus(NpCsDocument, SkipWorkflow);
            until NpCsDocument.Next() = 0;

        NpCsDocument.SetRange("Processing expires at");
        NpCsDocument.SetFilter("Processing Status", '<>%1&<>%2', NpCsDocument."Processing Status"::Rejected, NpCsDocument."Processing Status"::Expired);
        NpCsDocument.SetFilter("Delivery expires at", '<=%1&<>%2', CurrentDateTime, 0DT);
        NpCsDocument.SetFilter("Delivery Status", '=%1|=%2', NpCsDocument."Delivery Status"::" ", NpCsDocument."Delivery Status"::Ready);
        if NpCsDocument.FindSet() then
            repeat
                UpdateExpirationStatus(NpCsDocument, SkipWorkflow);
            until NpCsDocument.Next() = 0;
    end;

    procedure UpdateExpirationStatus(var NpCsDocument: Record "NPR NpCs Document"; SkipWorkflow: Boolean)
    begin
        if NpCsDocument."Delivery Status" in [NpCsDocument."Delivery Status"::Delivered, NpCsDocument."Delivery Status"::Expired] then
            exit;
        if NpCsDocument."Processing Status" in [NpCsDocument."Processing Status"::" ", NpCsDocument."Processing Status"::Pending] then begin
            UpdateExpirationStatusProcessing(NpCsDocument, SkipWorkflow);
            exit;
        end;

        if NpCsDocument."Delivery Status" in [NpCsDocument."Delivery Status"::" ", NpCsDocument."Delivery Status"::Ready] then begin
            UpdateExpirationStatusDelivery(NpCsDocument, SkipWorkflow);
            exit;
        end;
    end;

    local procedure UpdateExpirationStatusProcessing(var NpCsDocument: Record "NPR NpCs Document"; SkipWorkflow: Boolean)
    var
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
    begin
        if NpCsDocument."Processing expires at" = 0DT then
            exit;
        if NpCsDocument."Processing expires at" <= CurrentDateTime then
            NpCsCollectMgt.ExpireProcessing(NpCsDocument, SkipWorkflow);
    end;

    local procedure UpdateExpirationStatusDelivery(var NpCsDocument: Record "NPR NpCs Document"; SkipWorkflow: Boolean)
    var
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
    begin
        if NpCsDocument."Delivery expires at" = 0DT then
            exit;
        if NpCsDocument."Delivery expires at" <= CurrentDateTime then
            NpCsCollectMgt.ExpireDelivery(NpCsDocument, SkipWorkflow);
    end;

    procedure ScheduleUpdateExpirationStatus(NpCsDocument: Record "NPR NpCs Document"; NotBefore: DateTime)
    begin
        TASKSCHEDULER.CreateTask(CurrCodeunitId(), 0, true, CompanyName, NotBefore, NpCsDocument.RecordId);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpCs Expiration Mgt.");
    end;
}

