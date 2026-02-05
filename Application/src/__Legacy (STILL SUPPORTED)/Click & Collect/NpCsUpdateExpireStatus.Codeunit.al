codeunit 6151513 "NPR NpCs Update Expire Status"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
    trigger OnRun()
    begin
        UpdateExpirationStatusAll()
    end;

    local procedure UpdateExpirationStatusAll()
    var
        NpCsDocument: Record "NPR NpCs Document";
        NpCsExpirationMgt: Codeunit "NPR NpCs Expiration Mgt.";
    begin
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetFilter("Processing expires at", '<=%1&<>%2', CurrentDateTime, 0DT);
        NpCsDocument.SetFilter("Processing Status", '=%1|=%2', NpCsDocument."Processing Status"::" ", NpCsDocument."Processing Status"::Pending);
        NpCsDocument.SetFilter("Delivery Status", '<>%1&<>%2', NpCsDocument."Delivery Status"::Delivered, NpCsDocument."Delivery Status"::Expired);
        if NpCsDocument.FindSet() then
            repeat
                NpCsExpirationMgt.ScheduleUpdateExpirationStatus(NpCsDocument, NpCsDocument."Processing expires at");
            until NpCsDocument.Next() = 0;

        NpCsDocument.SetRange("Processing expires at");
        NpCsDocument.SetFilter("Processing Status", '<>%1&<>%2', NpCsDocument."Processing Status"::Rejected, NpCsDocument."Processing Status"::Expired);
        NpCsDocument.SetFilter("Delivery expires at", '<=%1&<>%2', CurrentDateTime, 0DT);
        NpCsDocument.SetFilter("Delivery Status", '=%1|=%2', NpCsDocument."Delivery Status"::" ", NpCsDocument."Delivery Status"::Ready);
        if NpCsDocument.FindSet() then
            repeat
                NpCsExpirationMgt.ScheduleUpdateExpirationStatus(NpCsDocument, NpCsDocument."Delivery expires at");
            until NpCsDocument.Next() = 0;

    end;
}
