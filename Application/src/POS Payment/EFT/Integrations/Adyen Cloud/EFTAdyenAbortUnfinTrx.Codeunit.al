codeunit 6184531 "NPR EFT Adyen Abort Unfin. Trx"
{
    Access = Internal;
    // NPR5.53/MMV /20200126 CASE 377533 Created object
    // NPR5.54/MMV /20200415 CASE 364340 Set sales ticket number correctly.

    TableNo = "NPR EFT Transaction Request";

    trigger OnRun()
    begin
        AbortLastUnfinishedTrx(Rec);
    end;

    var
        Response: Text;

    procedure SetResponse(ResponseIn: Text)
    begin
        Response := ResponseIn;
    end;

    local procedure AbortLastUnfinishedTrx(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Resp. Parser";
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
        EntryNoToCheck: Integer;
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
        AbortReqLbl: Label 'Creating abort request for entry %1';
    begin
        if EFTTransactionRequest.Successful then
            exit;
        if not EFTAdyenResponseParser.IsInProgressError(Response) then
            exit;
        EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionRequest."Entry No.", 'Trx In Progress Error', '');

        EntryNoToCheck := GetLastTransaction(EFTTransactionRequest);
        if EntryNoToCheck = -1 then
            exit;

        if not LastEFTTransactionRequest.Get(EntryNoToCheck) then
            exit;
        if LastEFTTransactionRequest."External Result Known" then
            exit;

        EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionRequest."Entry No.", StrSubstNo(AbortReqLbl, EntryNoToCheck), '');
        EFTAdyenCloudIntegration.AbortTransaction(LastEFTTransactionRequest, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
    end;

    local procedure GetLastTransaction(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Integer
    var
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EntryNoToCheck: Integer;
    begin
        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::AUXILIARY) and (EFTTransactionRequest."Auxiliary Operation ID" = 2) then
            EFTTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No."); //Filter to last trx before this chain

        LastEFTTransactionRequest.SetRange("Register No.", EFTTransactionRequest."Register No.");
        LastEFTTransactionRequest.SetRange("Integration Type", EFTTransactionRequest."Integration Type");
        LastEFTTransactionRequest.SetFilter("Entry No.", '<%1', EFTTransactionRequest."Entry No.");
        LastEFTTransactionRequest.SetFilter("Processing Type", '%1|%2|%3',
          LastEFTTransactionRequest."Processing Type"::PAYMENT,
          LastEFTTransactionRequest."Processing Type"::REFUND,
          LastEFTTransactionRequest."Processing Type"::VOID);
        if not LastEFTTransactionRequest.FindLast() then
            exit(-1);

        EntryNoToCheck := LastEFTTransactionRequest."Entry No.";

        LastEFTTransactionRequest.SetRange("Processing Type", LastEFTTransactionRequest."Processing Type"::AUXILIARY);
        LastEFTTransactionRequest.SetFilter("Auxiliary Operation ID", '%1|%2|%3', 2, 4, 5);
        if LastEFTTransactionRequest.FindLast() then
            if LastEFTTransactionRequest."Entry No." > EntryNoToCheck then
                EntryNoToCheck := LastEFTTransactionRequest."Entry No.";

        exit(EntryNoToCheck);
    end;
}

