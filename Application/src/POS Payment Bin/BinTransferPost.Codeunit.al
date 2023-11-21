codeunit 6150633 "NPR BinTransferPost"
{
    Access = Internal;
    internal procedure SetReleased(JournalEntryNo: Integer; Released: Boolean)
    var
        BinTransferJnl: Record "NPR BinTransferJournal";
        BinTransferSetup: Record "NPR Bin Transfer Profile";
        PostedBinTransferEntry: Record "NPR PostedBinTransferEntry";
    begin
        BinTransferJnl.Get(JournalEntryNo);

        if (BinTransferJnl.Status = BinTransferJnl.Status::RECEIVED) then
            exit;

        if ((Released) and (BinTransferJnl.Status <> BinTransferJnl.Status::RELEASED)) then begin
            BinTransferJnl.Status := BinTransferJnl.Status::RELEASED;
            BinTransferJnl.TestField(StoreCode);
            BinTransferJnl.TestField(TransferFromBinCode);
            BinTransferJnl.TestField(TransferToBinCode);
            BinTransferJnl.TestField(PaymentMethod);
        end;

        if ((not Released) and (BinTransferJnl.Status = BinTransferJnl.Status::RELEASED)) then begin
            BinTransferJnl.Status := BinTransferJnl.Status::OPEN;
            if (PostedBinTransferEntry.Get(JournalEntryNo)) then
                PostedBinTransferEntry.Delete();
        end;

        BinTransferJnl.Modify();

        if (Released) then
            if (BinTransferSetup.Get()) then
                if (BinTransferSetup.PrintOnRelease) then
                    ReleasePrint(JournalEntryNo);

    end;

    internal procedure InitPaymentMethodDenomination(PaymentMethodCode: Code[10]; JournalEntryNo: Integer)
    var
        PaymentMethod: Record "NPR POS Payment Method";
        PaymentMethodDenomination: Record "NPR Payment Method Denom";
        TransferDenomination: Record "NPR BinTransferDenomination";
    begin
        if (not (PaymentMethod.Get(PaymentMethodCode))) then
            exit;

        PaymentMethodDenomination.SetFilter("POS Payment Method Code", '=%1', PaymentMethodCode);
        PaymentMethodDenomination.SetFilter(Blocked, '=%1', false);
        if (PaymentMethodDenomination.FindSet()) then begin
            repeat
                TransferDenomination.EntryNo := JournalEntryNo;
                TransferDenomination.POSPaymentMethodCode := PaymentMethodCode;
                TransferDenomination.DenominationType := PaymentMethodDenomination."Denomination Type";
                TransferDenomination.Denomination := PaymentMethodDenomination.Denomination;
                TransferDenomination.DenominationVariantID := PaymentMethodDenomination."Denomination Variant ID";
                if (not TransferDenomination.Insert()) then
                    ;
            until (PaymentMethodDenomination.Next() = 0);
        end;
    end;

    internal procedure ReceiveToPaymentBin(JournalEntryNo: Integer)
    var
        BinTransferJnl: Record "NPR BinTransferJournal";
        BinTransferProfile: Record "NPR Bin Transfer Profile";
    begin
        BinTransferJnl.Get(JournalEntryNo);
        BinTransferJnl.TestField(Status, BinTransferJnl.Status::RELEASED);

        if (not (BinTransferProfile.Get())) then
            BinTransferProfile.Init();

        TransferAndPostEntry(JournalEntryNo);

        BinTransferJnl.Status := BinTransferJnl.Status::RECEIVED;
        BinTransferJnl.Modify();

        if (BinTransferProfile.PostToGeneralLedgerOnReceive) then
            TransferAndPostEntry(JournalEntryNo);
    end;

    internal procedure ReceiveToPaymentBinAndPost(JournalEntryNo: Integer)
    var
        BinTransferJnl: Record "NPR BinTransferJournal";
        WrongStatus: Label 'Status of the record must not be open.';
    begin
        BinTransferJnl.Get(JournalEntryNo);
        if (BinTransferJnl.Status = BinTransferJnl.Status::OPEN) then
            Error(WrongStatus);

        BinTransferJnl.Status := BinTransferJnl.Status::RECEIVED;
        BinTransferJnl.Modify();

        TransferAndPostEntry(JournalEntryNo);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    internal procedure TransferAndPostEntry(JournalEntryNo: Integer)
    var
        BinTransferJnl: Record "NPR BinTransferJournal";
        TempBinTransferJnlToPost: Record "NPR BinTransferJournal" temporary;
        BinTransferSetup: Record "NPR Bin Transfer Profile";
    begin
        BinTransferJnl.Get(JournalEntryNo);
        TempBinTransferJnlToPost.TransferFields(BinTransferJnl, true);
        TempBinTransferJnlToPost.Insert();

        TransferAndPost(TempBinTransferJnlToPost);

        if (BinTransferSetup.Get()) then
            if (BinTransferSetup.PrintOnReceive) then
                ReceivePrint(JournalEntryNo);

    end;

    local procedure TransferAndPost(var TempBinJournalLinesToTransfer: Record "NPR BinTransferJournal" temporary)
    var
        PosPostEntries: Codeunit "NPR POS Post Entries";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        SourcePostingSetup: Record "NPR POS Posting Setup";
        TargetPostingSetup: Record "NPR POS Posting Setup";
        PaymentMethod: Record "NPR POS Payment Method";
        PosStore: Record "NPR POS Store";
        PosPostingProfile: Record "NPR POS Posting Profile";
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        BinTransferJournal: Record "NPR BinTransferJournal";
        BinTransferProfile: Record "NPR Bin Transfer Profile";
        NothingToTransfer: Label 'Nothing to transfer.';
        NotTemporary: Label 'Incorrect parameter sent to function TransferAndPost()';
        SourcePostingNotFound: Label '%1 not found for source on journal line entry no. %2';
        TargetPostingNotFound: Label '%1 not found for target on journal line entry no. %2';
        SalespersonCode: Code[20];
        DocumentNo: Code[20];
        ShortcutDim1, ShortcutDim2 : Code[20];
        DimSetID: Integer;
        PaymentMethodExchangeRate: Decimal;
    begin
        if (not TempBinJournalLinesToTransfer.IsTemporary()) then
            Error(NotTemporary);

        TempBinJournalLinesToTransfer.Reset();
        if (TempBinJournalLinesToTransfer.IsEmpty()) then
            Error(NothingToTransfer);

        if (not (BinTransferProfile.Get())) then
            BinTransferProfile.Init();

        DocumentNo := TempBinJournalLinesToTransfer.DocumentNo;
        if (DocumentNo = '') then
            DocumentNo := CopyStr(StrSubstNo('NPRTX-%1%2', Date2DMY(Today(), 3), PadOnLeft(TempBinJournalLinesToTransfer.EntryNo, 5)), 1, MaxStrLen(DocumentNo));

        TempBinJournalLinesToTransfer.FindSet();
        repeat

            PosStore.Get(TempBinJournalLinesToTransfer.StoreCode);
            PosPostingProfile.Get(PosStore."POS Posting Profile");
            PaymentMethod.Get(TempBinJournalLinesToTransfer.PaymentMethod);

            if (PaymentMethod."Currency Code" <> '') then
                if (not PaymentMethod."Use Stand. Exc. Rate for Bal.") then
                    PaymentMethodExchangeRate := 100 / PaymentMethod."Fixed Rate";

            if (not PosPostEntries.GetPostingSetup(TempBinJournalLinesToTransfer.StoreCode, TempBinJournalLinesToTransfer.PaymentMethod, TempBinJournalLinesToTransfer.TransferFromBinCode, SourcePostingSetup)) then
                Error(SourcePostingNotFound, SourcePostingSetup.TableCaption(), TempBinJournalLinesToTransfer.EntryNo);

            if (not PosPostEntries.GetPostingSetup(TempBinJournalLinesToTransfer.StoreCode, TempBinJournalLinesToTransfer.PaymentMethod, TempBinJournalLinesToTransfer.TransferToBinCode, TargetPostingSetup)) then
                Error(TargetPostingNotFound, TargetPostingSetup.TableCaption(), TempBinJournalLinesToTransfer.EntryNo);

            //From Bin
            GetDim(ShortcutDim1, ShortcutDim2, DimSetID, TempBinJournalLinesToTransfer.TransferFromBinCode, TempBinJournalLinesToTransfer.ReceiveAtPosUnitCode);

            MakeGenJournalLine(PosPostingProfile."Journal Template Name",
                GetGLAccountType(SourcePostingSetup),
                SourcePostingSetup."Account No.",
                Today(),
                DocumentNo,
                TempBinJournalLinesToTransfer.Description,
                PaymentMethod."Currency Code",
                PaymentMethod."Use Stand. Exc. Rate for Bal.",
                PaymentMethodExchangeRate,
                -TempBinJournalLinesToTransfer.Amount,
                ShortcutDim1, ShortcutDim2, DimSetID,
                SalespersonCode, // Todo
                BinTransferProfile.ReasonCode,
                TempBinJournalLinesToTransfer.ExternalDocumentNo,
                PosPostingProfile."Source Code",
                TempGenJournalLine);

            //To Bin
            GetDim(ShortcutDim1, ShortcutDim2, DimSetID, TempBinJournalLinesToTransfer.TransferToBinCode, TempBinJournalLinesToTransfer.ReceiveAtPosUnitCode);

            MakeGenJournalLine(PosPostingProfile."Journal Template Name",
                GetGLAccountType(TargetPostingSetup),
                TargetPostingSetup."Account No.",
                Today(),
                DocumentNo,
                TempBinJournalLinesToTransfer.Description,
                PaymentMethod."Currency Code",
                PaymentMethod."Use Stand. Exc. Rate for Bal.",
                PaymentMethodExchangeRate,
                TempBinJournalLinesToTransfer.Amount,
                ShortcutDim1, ShortcutDim2, DimSetID,
                SalespersonCode, // Todo
                BinTransferProfile.ReasonCode,
                TempBinJournalLinesToTransfer.ExternalDocumentNo,
                PosPostingProfile."Source Code",
                TempGenJournalLine);

            RegisterBinMovement(TempBinJournalLinesToTransfer, TempGenJournalLine);

            if (TempBinJournalLinesToTransfer.Status = TempBinJournalLinesToTransfer.Status::RECEIVED) then begin
                BinTransferJournal.Get(TempBinJournalLinesToTransfer.EntryNo);
                BinTransferJournal.Delete();
                TempGenJournalLine.Reset();
                IF TempGenJournalLine.FindSet() then
                    repeat
                        GenJnlPostLine.Run(TempGenJournalLine);
                    until TempGenJournalLine.Next() = 0;
            end;

        until (TempBinJournalLinesToTransfer.Next() = 0);

    end;

    local procedure RegisterBinMovement(var TempBinJournalLinesToTransfer: Record "NPR BinTransferJournal" temporary; var TempGenJournalLine: Record "Gen. Journal Line" temporary)
    var
        POSBinEntry: Record "NPR POS Bin Entry";
        PostedTransferEntries: Record "NPR PostedBinTransferEntry";
    begin

        if (PostedTransferEntries.Get(TempBinJournalLinesToTransfer.EntryNo)) then
            exit;

        // Withdraw from source bin
        POSBinEntry."Entry No." := 0;
        POSBinEntry.Type := POSBinEntry.Type::BIN_TRANSFER_OUT;
        POSBinEntry."Payment Bin No." := TempBinJournalLinesToTransfer.TransferFromBinCode;

        POSBinEntry."Created At" := CurrentDateTime();
        POSBinEntry."Payment Method Code" := TempBinJournalLinesToTransfer.PaymentMethod;
        POSBinEntry."Payment Type Code" := TempBinJournalLinesToTransfer.PaymentMethod;
        POSBinEntry."POS Store Code" := TempBinJournalLinesToTransfer.StoreCode;
        POSBinEntry."POS Unit No." := TempBinJournalLinesToTransfer.ReceiveFromPosUnitCode;
        POSBinEntry."Register No." := TempBinJournalLinesToTransfer.ReceiveFromPosUnitCode;

        POSBinEntry."Transaction Amount" := -1 * TempBinJournalLinesToTransfer.Amount;
        POSBinEntry."Transaction Currency Code" := TempGenJournalLine."Currency Code";
        POSBinEntry."Transaction Amount (LCY)" := -1 * TempGenJournalLine."Amount (LCY)";

        POSBinEntry."Transaction Date" := Today();
        POSBinEntry."Transaction Time" := Time();
        POSBinEntry."External Transaction No." := TempGenJournalLine."Document No.";
        POSBinEntry.Comment := 'Transfer';
        POSBinEntry.Insert();

        // Deposit to target bin
        POSBinEntry."Entry No." := 0;
        POSBinEntry.Type := POSBinEntry.Type::BIN_TRANSFER_IN;
        POSBinEntry."Payment Bin No." := TempBinJournalLinesToTransfer.TransferToBinCode;
        POSBinEntry."POS Unit No." := TempBinJournalLinesToTransfer.ReceiveAtPosUnitCode;
        POSBinEntry."Register No." := TempBinJournalLinesToTransfer.ReceiveAtPosUnitCode;

        POSBinEntry."Transaction Amount" := TempBinJournalLinesToTransfer.Amount;
        POSBinEntry."Transaction Currency Code" := TempGenJournalLine."Currency Code";
        POSBinEntry."Transaction Amount (LCY)" := TempGenJournalLine."Amount (LCY)";
        POSBinEntry.Insert();

        // Copy transfer entry to posted transfers
        PostedTransferEntries.TransferFields(TempBinJournalLinesToTransfer, true);
        PostedTransferEntries.DocumentNo := TempGenJournalLine."Document No.";
        PostedTransferEntries.TransferredBy := CopyStr(UserId, 1, MaxStrLen(PostedTransferEntries.TransferredBy));
        PostedTransferEntries.TransferredAt := CurrentDateTime();
        PostedTransferEntries.Insert();
    end;


    local procedure PadOnLeft(NumberToPad: Integer; IntendedLength: Integer) NumberString: Text
    begin
        if (IntendedLength <= 0) then
            Error('Invalid length specified for PadOnLeft.');

        NumberString := Format(NumberToPad, 0, 9);
        if (StrLen(NumberString) > IntendedLength) then
            NumberString := CopyStr(NumberString, StrLen(NumberString) - IntendedLength + 1); // remove the left part of the number 

        while (StrLen(NumberString) < IntendedLength) do
            NumberString := '0' + NumberString;

        exit(NumberString);
    end;

    local procedure GetGLAccountType(POSPostingSetup: Record "NPR POS Posting Setup"): Enum "Gen. Journal Account Type"
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        POSPostingSetup.TestField("Account No.");
        case POSPostingSetup."Account Type" of
            POSPostingSetup."Account Type"::"G/L Account":
                exit(GenJournalLine."Account Type"::"G/L Account");
            POSPostingSetup."Account Type"::"Bank Account":
                exit(GenJournalLine."Account Type"::"Bank Account");
            POSPostingSetup."Account Type"::Customer:
                exit(GenJournalLine."Account Type"::Customer);
        end;
    end;

    local procedure MakeGenJournalLine(JournalTemplateName: Code[10];
                                        AccountType: Enum "Gen. Journal Account Type";
                                        AccountNo: Code[20];
                                        PostingDate: Date;
                                        DocumentNo: Code[20];
                                        PostingDescription: Text;
                                        CurrencyCode: Code[10];
                                        UseStandardExchangeRate: Boolean;
                                        ExchangeRate: Decimal;
                                        Amount: Decimal;
                                        ShortcutDim1: Code[20];
                                        ShortcutDim2: Code[20];
                                        DimSetID: Integer;
                                        SalespersonCode: Code[20];
                                        ReasonCode: Code[10];
                                        ExternalDocNo: Code[35];
                                        SourceCode: Code[10];
                                        var TempGenJournalLine: Record "Gen. Journal Line" temporary
                                      )
    var
        LineNumber: Integer;
    begin
        if (not TempGenJournalLine.FindLast()) then
            TempGenJournalLine."Line No." := 10000;
        LineNumber := TempGenJournalLine."Line No." + 10000;

        TempGenJournalLine.Init();
        TempGenJournalLine."Journal Template Name" := JournalTemplateName;
        TempGenJournalLine."Journal Batch Name" := '';
        TempGenJournalLine."Line No." := LineNumber;

        TempGenJournalLine.Validate("Account Type", AccountType);
        TempGenJournalLine.Validate("Account No.", AccountNo);

        TempGenJournalLine."Posting Date" := PostingDate;
        TempGenJournalLine."Document Date" := TempGenJournalLine."Posting Date";
        TempGenJournalLine."Document No." := DocumentNo;
        TempGenJournalLine."External Document No." := ExternalDocNo;

        TempGenJournalLine.Description := CopyStr(PostingDescription, 1, MaxStrLen(TempGenJournalLine.Description));

        if UseStandardExchangeRate then
            TempGenJournalLine.Validate("Currency Code", CurrencyCode)
        else begin
            TempGenJournalLine."Currency Code" := CurrencyCode;
            TempGenJournalLine.Validate("Currency Factor", ExchangeRate);
        end;

        TempGenJournalLine.Validate(Amount, Amount);

        TempGenJournalLine."Source Currency Code" := CurrencyCode;
        TempGenJournalLine."Source Currency Amount" := Amount;

        TempGenJournalLine.Validate("Shortcut Dimension 1 Code", ShortcutDim1);
        TempGenJournalLine.Validate("Shortcut Dimension 2 Code", ShortcutDim2);
        if DimSetID <> 0 then
            TempGenJournalLine.Validate("Dimension Set ID", DimSetID);
        TempGenJournalLine."Salespers./Purch. Code" := SalespersonCode;
        TempGenJournalLine."Reason Code" := ReasonCode;
        TempGenJournalLine."Source Code" := SourceCode;
        TempGenJournalLine."System-Created Entry" := true;

        TempGenJournalLine.Insert();
    end;

    local procedure GetDim(var ShortcutDim1: Code[20]; var ShortcutDim2: Code[20]; var DimSetID: Integer; BinCode: Code[10]; ReceiveAtPosUnitCode: Code[20])
    var
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        POSPaymentBin: Record "NPR POS Payment Bin";
    begin

        if POSPaymentBin.Get(BinCode) then;
        if POSUnit.Get(POSPaymentBin."Attached to POS Unit No.") then begin
            ShortcutDim1 := POSUnit."Global Dimension 1 Code";
            ShortcutDim2 := POSUnit."Global Dimension 2 Code"
        end else
            if POSSession.IsInitialized() then begin
                POSSession.GetSale(POSSale);
                POSSale.GetCurrentSale(SalePOS);
                ShortcutDim1 := SalePOS."Shortcut Dimension 1 Code";
                ShortcutDim2 := SalePOS."Shortcut Dimension 2 Code";
                DimSetID := SalePOS."Dimension Set ID";
            end else
                if POSUnit.Get(ReceiveAtPosUnitCode) then begin
                    ShortcutDim1 := POSUnit."Global Dimension 1 Code";
                    ShortcutDim2 := POSUnit."Global Dimension 2 Code";
                end;

    end;

    internal procedure ReleasePrint(JournalEntryNo: Integer)
    var
        PrintTemplateMgt: Codeunit "NPR RP Template Mgt.";
        BinTransferSetup: Record "NPR Bin Transfer Profile";
        TransferJournalEntry: Record "NPR BinTransferJournal";
    begin
        if (not BinTransferSetup.Get()) then
            exit;

        if (not (TransferJournalEntry.Get(JournalEntryNo))) then
            exit;

        TransferJournalEntry.SetRecFilter();
        case (BinTransferSetup.ReleasePrintType) of

            BinTransferSetup.ReleasePrintType::CODEUNIT:
                Codeunit.Run(BinTransferSetup.ReleasePrintObjectID, TransferJournalEntry);

            BinTransferSetup.ReleasePrintType::REPORT:
                Report.Run(BinTransferSetup.ReleasePrintObjectID, false, false, TransferJournalEntry);

            BinTransferSetup.ReleasePrintType::TEMPLATE:
                PrintTemplateMgt.PrintTemplate(BinTransferSetup.ReleasePrintTemplateCode, TransferJournalEntry, 0);
        end;
    end;

    internal procedure ReceivePrint(PostedJournalEntryNo: Integer)
    var
        PrintTemplateMgt: Codeunit "NPR RP Template Mgt.";
        BinTransferSetup: Record "NPR Bin Transfer Profile";
        PostedBinTransferEntry: Record "NPR PostedBinTransferEntry";
    begin
        if (not BinTransferSetup.Get()) then
            exit;

        if (not (PostedBinTransferEntry.Get(PostedJournalEntryNo))) then
            exit;

        PostedBinTransferEntry.SetRecFilter();
        case (BinTransferSetup.ReleasePrintType) of

            BinTransferSetup.ReceivePrintType::CODEUNIT:
                Codeunit.Run(BinTransferSetup.ReceivePrintObjectID, PostedBinTransferEntry);

            BinTransferSetup.ReceivePrintType::REPORT:
                Report.Run(BinTransferSetup.ReceivePrintObjectID, false, false, PostedBinTransferEntry);

            BinTransferSetup.ReceivePrintType::TEMPLATE:
                PrintTemplateMgt.PrintTemplate(BinTransferSetup.ReceivePrintTemplateCode, PostedBinTransferEntry, 0);
        end;
    end;

}