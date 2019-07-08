codeunit 6151207 "NpCs Expiration Mgt."
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    TableNo = "NpCs Document";

    trigger OnRun()
    begin
        UpdateExpirationStatus(Rec,false);
    end;

    var
        Text000: Label 'Document Processing expired';
        Text001: Label 'Document Delivery expired';

    procedure SetExpiresAt(var NpCsDocument: Record "NpCs Document")
    var
        PrevRec: Text;
    begin
        if NpCsDocument."Delivery Status" in [NpCsDocument."Delivery Status"::Delivered,NpCsDocument."Delivery Status"::Expired] then
          exit;
        if NpCsDocument."Processing Status" in [NpCsDocument."Processing Status"::Rejected,NpCsDocument."Processing Status"::Expired] then
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

    local procedure CalcProcessingExpiresAt(NpCsDocument: Record "NpCs Document") ExpiresAt: DateTime
    var
        NpCsStoreOpeningHoursMgt: Codeunit "NpCs Store Opening Hours Mgt.";
    begin
        if NpCsDocument."Processing Expiry Duration" <= 0 then
          exit(0DT);
        if NpCsDocument."Processing updated at" = 0DT then
          NpCsDocument."Processing updated at" := CurrentDateTime;

        ExpiresAt := NpCsStoreOpeningHoursMgt.CalcNextOpeningDTDuration(NpCsDocument."Processing updated at",NpCsDocument."Processing Expiry Duration");
    end;

    local procedure CalcDeliveryExpiresAt(NpCsDocument: Record "NpCs Document") ExpiresAt: DateTime
    var
        NpCsStoreOpeningHoursMgt: Codeunit "NpCs Store Opening Hours Mgt.";
    begin
        if NpCsDocument."Delivery Expiry Days (Qty.)" <= 0 then
            exit(0DT);
        if NpCsDocument."Processing updated at" = 0DT then
          NpCsDocument."Processing updated at" := CurrentDateTime;

        NpCsDocument."Delivery expires at" := NpCsStoreOpeningHoursMgt.CalcNextClosingDTDaysQty(NpCsDocument."Processing updated at",NpCsDocument."Delivery Expiry Days (Qty.)");
    end;

    procedure UpdateExpirationStatus(var NpCsDocument: Record "NpCs Document";SkipWorkflow: Boolean)
    begin
        if NpCsDocument."Processing Status" in [NpCsDocument."Processing Status"::" ",NpCsDocument."Processing Status"::Pending] then begin
          UpdateExpirationStatusProcessing(NpCsDocument,SkipWorkflow);
          exit;
        end;

        if NpCsDocument."Delivery Status" in [NpCsDocument."Delivery Status"::" ",NpCsDocument."Delivery Status"::Ready] then begin
          UpdateExpirationStatusDelivery(NpCsDocument,SkipWorkflow);
          exit;
        end;
    end;

    local procedure UpdateExpirationStatusProcessing(var NpCsDocument: Record "NpCs Document";SkipWorkflow: Boolean)
    var
        NpCsCollectMgt: Codeunit "NpCs Collect Mgt.";
    begin
        if NpCsDocument."Processing expires at" = 0DT then
          exit;
        if NpCsDocument."Processing expires at" <= CurrentDateTime then
          NpCsCollectMgt.ExpireProcessing(NpCsDocument,SkipWorkflow);
    end;

    local procedure UpdateExpirationStatusDelivery(var NpCsDocument: Record "NpCs Document";SkipWorkflow: Boolean)
    var
        NpCsCollectMgt: Codeunit "NpCs Collect Mgt.";
    begin
        if NpCsDocument."Delivery expires at" = 0DT then
          exit;
        if NpCsDocument."Delivery expires at" <= CurrentDateTime then
          NpCsCollectMgt.ExpireDelivery(NpCsDocument,SkipWorkflow);
    end;

    procedure ScheduleUpdateExpirationStatus(NpCsDocument: Record "NpCs Document";NotBefore: DateTime)
    begin
        //TASKSCHEDULER.CREATETASK(CurrCodeunitId(),0,TRUE,COMPANYNAME,NotBefore,NpCsDocument.RECORDID);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpCs Expiration Mgt.");
    end;
}

