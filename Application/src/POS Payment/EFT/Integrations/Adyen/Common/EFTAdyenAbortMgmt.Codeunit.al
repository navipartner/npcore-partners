codeunit 6184636 "NPR EFT Adyen Abort Mgmt"
{
    Access = Internal;

    procedure CreateAbortTransactionRequest(EFTTransactionRequest: Record "NPR EFT Transaction Request") EntryNo: Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        AbortEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
    begin
#pragma warning disable AA0139
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        EFTFrameworkMgt.CreateAuxRequest(AbortEFTTransactionRequest, EFTSetup, 1, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
#pragma warning restore AA0139
        AbortEFTTransactionRequest."Processed Entry No." := EFTTransactionRequest."Entry No.";
        if AbortEFTTransactionRequest."Hardware ID" = '' then
            AbortEFTTransactionRequest."Hardware ID" := EFTTransactionRequest."Hardware ID";
        AbortEFTTransactionRequest.Modify();
        Commit();
        Exit(AbortEFTTransactionRequest."Entry No.");
    end;

    internal procedure CreateAbortDataCollectionTransactionRequest(EFTTransactionRequest: Record "NPR EFT Transaction Request") EntryNo: Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        AbortEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTFrameworkMgt.CreateAuxRequest(AbortEFTTransactionRequest, 1, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.", EFTTransactionRequest."POS Payment Type Code");
        AbortEFTTransactionRequest."Created From Data Collection" := true;
        AbortEFTTransactionRequest."Processed Entry No." := EFTTransactionRequest."Entry No.";
        if AbortEFTTransactionRequest."Hardware ID" = '' then
            AbortEFTTransactionRequest."Hardware ID" := EFTTransactionRequest."Hardware ID";
        AbortEFTTransactionRequest.Insert();
        AbortEFTTransactionRequest."Reference Number Input" := Format(AbortEFTTransactionRequest."Entry No.");
        AbortEFTTransactionRequest.Modify();
        Commit();
        Exit(AbortEFTTransactionRequest."Entry No.");
    end;

    procedure CreateAbortAcquireCardRequest(EFTTransactionRequest: Record "NPR EFT Transaction Request") EntryNo: Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        AbortEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        EFTFrameworkMgt.CreateAuxRequest(AbortEFTTransactionRequest, EFTSetup, 3, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
        AbortEFTTransactionRequest."Processed Entry No." := EFTTransactionRequest."Entry No.";
        AbortEFTTransactionRequest.Modify();
        Commit();
        Exit(AbortEFTTransactionRequest."Entry No.");
    end;

    procedure CanAbortLastUnfinishedTrx(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var EntryNoToAbort: Integer): Boolean
    var
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
        AbortReqLbl: Label 'Creating abort request for entry %1';
    begin
        EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionRequest."Entry No.", 'Trx In Progress Error', '');

        EntryNoToAbort := GetLastTransaction(EFTTransactionRequest);
        if EntryNoToAbort = -1 then
            exit(false);

        if not LastEFTTransactionRequest.Get(EntryNoToAbort) then
            exit(false);
        if LastEFTTransactionRequest."External Result Known" then
            exit(false);

        EFTTransactionLoggingMgt.WriteLogEntry(EFTTransactionRequest."Entry No.", StrSubstNo(AbortReqLbl, EntryNoToAbort), '');
        exit(true)
    end;

    local procedure GetLastTransaction(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Integer
    var
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EntryNoToCheck: Integer;
    begin
        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::AUXILIARY) and (EFTTransactionRequest."Auxiliary Operation ID" = "NPR EFT Adyen Aux Operation"::ACQUIRE_CARD.AsInteger()) then
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
        LastEFTTransactionRequest.SetFilter(
            "Auxiliary Operation ID",
            '%1|%2|%3',
            "NPR EFT Adyen Aux Operation"::ACQUIRE_CARD.AsInteger(),
            "NPR EFT Adyen Aux Operation"::DETECT_SHOPPER.AsInteger(),
            "NPR EFT Adyen Aux Operation"::CLEAR_SHOPPER.AsInteger()
        );
        if LastEFTTransactionRequest.FindLast() then
            if LastEFTTransactionRequest."Entry No." > EntryNoToCheck then
                EntryNoToCheck := LastEFTTransactionRequest."Entry No.";

        exit(EntryNoToCheck);
    end;
}