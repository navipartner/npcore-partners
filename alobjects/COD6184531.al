codeunit 6184531 "EFT Adyen Abort Unfinished Trx"
{
    // NPR5.53/MMV /20200126 CASE 377533 Created object

    TableNo = "EFT Transaction Request";

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

    local procedure AbortLastUnfinishedTrx(EFTTransactionRequest: Record "EFT Transaction Request")
    var
        LastEFTTransactionRequest: Record "EFT Transaction Request";
        EFTAdyenResponseParser: Codeunit "EFT Adyen Response Parser";
        EFTTransactionLoggingMgt: Codeunit "EFT Transaction Logging Mgt.";
        EntryNoToCheck: Integer;
        EFTAdyenCloudIntegration: Codeunit "EFT Adyen Cloud Integration";
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
        if LastEFTTransactionRequest."External Result Received" then
          exit;

        EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionRequest."Entry No.", StrSubstNo('Creating abort request for entry %1', EntryNoToCheck), '');
        EFTAdyenCloudIntegration.AbortTransaction(LastEFTTransactionRequest);
    end;

    local procedure GetLastTransaction(EFTTransactionRequest: Record "EFT Transaction Request"): Integer
    var
        LastEFTTransactionRequest: Record "EFT Transaction Request";
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
        if not LastEFTTransactionRequest.FindLast then
          exit(-1);

        EntryNoToCheck := LastEFTTransactionRequest."Entry No.";

        LastEFTTransactionRequest.SetRange("Processing Type", LastEFTTransactionRequest."Processing Type"::AUXILIARY);
        LastEFTTransactionRequest.SetFilter("Auxiliary Operation ID", '%1|%2|%3', 2,4,5);
        if LastEFTTransactionRequest.FindLast then
          if LastEFTTransactionRequest."Entry No." > EntryNoToCheck then
            EntryNoToCheck := LastEFTTransactionRequest."Entry No.";

        exit(EntryNoToCheck);
    end;
}

