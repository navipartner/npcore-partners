codeunit 6151207 "NpCs Expiration Mgt."
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // #344264/MHA /20190717  CASE 344264 Adjusted OnRun() to check expiration on all documents if not run with specific rec

    TableNo = "NpCs Document";

    trigger OnRun()
    begin
        //-#344264 [344264]
        if Rec."Entry No." = 0 then
          UpdateExpirationStatusAll(Rec.Type::"Collect in Store",false)
        else if Rec.Find then
          UpdateExpirationStatus(Rec,false);
        //+#344264 [344264]
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
        //-#344264 [344264]
        exit(ExpiresAt);
        //+#344264 [344264]
    end;

    local procedure CalcDeliveryExpiresAt(NpCsDocument: Record "NpCs Document") ExpiresAt: DateTime
    var
        NpCsStoreOpeningHoursMgt: Codeunit "NpCs Store Opening Hours Mgt.";
    begin
        if NpCsDocument."Delivery Expiry Days (Qty.)" <= 0 then
            exit(0DT);
        if NpCsDocument."Processing updated at" = 0DT then
          NpCsDocument."Processing updated at" := CurrentDateTime;

        //-#344264 [344264]
        ExpiresAt := NpCsStoreOpeningHoursMgt.CalcNextClosingDTDaysQty(NpCsDocument."Processing updated at",NpCsDocument."Delivery Expiry Days (Qty.)");
        exit(ExpiresAt);
        //+#344264 [344264]
    end;

    local procedure UpdateExpirationStatusAll(Type: Integer;SkipWorkflow: Boolean)
    var
        NpCsDocument: Record "NpCs Document";
    begin
        //-#344264 [344264]
        if Type in [NpCsDocument.Type::"Send to Store",NpCsDocument.Type::"Collect in Store"] then
          NpCsDocument.SetRange(Type,Type);
        NpCsDocument.SetFilter("Processing expires at",'<=%1&<>%2',CurrentDateTime,0DT);
        NpCsDocument.SetFilter("Processing Status",'=%1|=%2',NpCsDocument."Processing Status"::" ",NpCsDocument."Processing Status"::Pending);
        NpCsDocument.SetFilter("Delivery Status",'<>%1&<>%2',NpCsDocument."Delivery Status"::Delivered,NpCsDocument."Delivery Status"::Expired);
        if NpCsDocument.FindSet then
          repeat
            UpdateExpirationStatus(NpCsDocument,SkipWorkflow);
          until NpCsDocument.Next = 0;

        NpCsDocument.SetRange("Processing expires at");
        NpCsDocument.SetFilter("Processing Status",'<>%1&<>%2',NpCsDocument."Processing Status"::Rejected,NpCsDocument."Processing Status"::Expired);
        NpCsDocument.SetFilter("Delivery expires at",'<=%1&<>%2',CurrentDateTime,0DT);
        NpCsDocument.SetFilter("Delivery Status",'=%1|=%2',NpCsDocument."Delivery Status"::" ",NpCsDocument."Delivery Status"::Ready);
        if NpCsDocument.FindSet then
          repeat
            UpdateExpirationStatus(NpCsDocument,SkipWorkflow);
          until NpCsDocument.Next = 0;
        //+#344264 [344264]
    end;

    procedure UpdateExpirationStatus(var NpCsDocument: Record "NpCs Document";SkipWorkflow: Boolean)
    begin
        //-#344264 [344264]
        if NpCsDocument."Delivery Status" in [NpCsDocument."Delivery Status"::Delivered,NpCsDocument."Delivery Status"::Expired] then
          exit;
        //+#344264 [344264]
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
        TASKSCHEDULER.CreateTask(CurrCodeunitId(),0,true,CompanyName,NotBefore,NpCsDocument.RecordId);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-NPR10.00.00.5.51 [344264]
        exit(CODEUNIT::"NpCs Expiration Mgt.");
        //+NPR10.00.00.5.51 [344264]
    end;
}

