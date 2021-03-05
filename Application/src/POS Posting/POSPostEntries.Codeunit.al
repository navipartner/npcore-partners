codeunit 6150615 "NPR POS Post Entries"
{
    TableNo = "NPR POS Entry";

    trigger OnRun()
    begin
        ShowProgressDialog := GuiAllowed;
        Code(Rec);
    end;

    var
        PostItemEntriesVar: Boolean;
        PostPOSEntriesVar: Boolean;
        PostCompressedVar: Boolean;
        StopOnErrorVar: Boolean;
        PostingDate: Date;
        ShowProgressDialog: Boolean;
        PostingDateExists: Boolean;
        ReplacePostingDate: Boolean;
        ReplaceDocumentDate: Boolean;
        TextErrorAllreadyPosted: Label '%1 %2 has already been posted or sent to a journal.';
        TextErrorMultiple: Label '%3 %1 and %2 cannot be posted together. Only one %3 can be posted at a time.';
        TextErrorTaxMismatch: Label 'There is a mismatch between the calculated taxes and the tax lines for Pos Entry %1.';
        TextErrorSalesTaxCompressed: Label '%1 %2 cannot be posted compressed because it has Sales Tax Lines. Please check the POS posting compression settings.';
        TextErrorBufferLinesnotmade: Label '%1 were not created from Sales and Payment Lines.';
        TextErrorGJLinesnotmade: Label '%1 were not be created from buffer.';
        TextUnknownError: Label 'Unknown Error.';
        TextDesc: Label '%1: %2';
        LineNumber: Integer;
        TextPaymentDescription: Label '%1 Payments on %2';
        ProgressWindow: Dialog;
        TextNothingToPost: Label 'Nothing to Post.';
        TextAccountTypeNotSupported: Label 'Field %1 contains an unsupported type in table %2.';
        TextImbalance: Label 'Cannot post the lines. %1 %2 on %3 %4 has an imbalance of %5. ';
        Text001: Label 'Posting POS Entries    #1##########\\';
        Text002: Label 'Creating Buffer Lines         #2###### @3@@@@@@@@@@@@@\';
        Text003: Label 'Preparing Gen. Journal Lines       #4###### @5@@@@@@@@@@@@@\';
        Text004: Label 'Posting Gen Journal lines         #8###### @9@@@@@@@@@@@@@\';
        Text005: Label 'Posting Item Lines         #10###### @11@@@@@@@@@@@@@\';
        POSPostingLogEntryNo: Integer;
        ErrorText: Text;
        Text006: Label 'Posting POS Entries individually\#1######\@2@@@@@@@@@@@@@\';
        FakeDocNoTxt: Label '***';
        TextPostingSetupMissing: Label '%1 is missing for %2 in %3 %4.\\Values [%5].';
        Debug: Boolean;
        TextPostingSetupMissingMovement: Label '%1 is missing for %2 Movement to Bin in %3 %4.';
        TextPostingSetupMissingDeposit: Label '%1 is missing for %2 Deposit to Bin in %3 %4.';
        TextClosingEntryFloat: Label 'Float Amount Closing POS Entry %1';
        TextSalesTaxDiscrepancy: Label 'There is a Sales Tax discrepancy. Sum of %1 on the lines is %2, while the calculated amount is %3.';
        TextPostingDifference: Label 'POS Posting Difference';

    local procedure "Code"(var POSEntry: Record "NPR POS Entry")
    var
        TempPOSPostingBuffer: Record "NPR POS Posting Buffer" temporary;
        TempPOSSalesLineToPost: Record "NPR POS Sales Line" temporary;
        POSSalesLine: Record "NPR POS Sales Line";
        TempPOSPaymentLinetoPost: Record "NPR POS Payment Line" temporary;
        POSPaymentLine: Record "NPR POS Payment Line";
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        POSEntryTemp: Record "NPR POS Entry" temporary;
    begin

        if ((not PostItemEntriesVar) and (not PostPOSEntriesVar)) or POSEntry.IsEmpty then
            Error(TextNothingToPost);

        if ShowProgressDialog then begin
            if PostItemEntriesVar and PostPOSEntriesVar then
                ProgressWindow.Open(Text005 + Text001 + Text002 + Text003 + Text004)
            else
                if PostItemEntriesVar then
                    ProgressWindow.Open(Text005 + Text001)
                else
                    if PostPOSEntriesVar then
                        ProgressWindow.Open(Text001 + Text002 + Text003 + Text004);
        end;

        CheckDimensions(POSEntry);

        if PostItemEntriesVar then begin
            //Item entries are posted first and committed after each POS Entry is posted
            PostItemEntries(POSEntry);
        end;

        if PostPOSEntriesVar then begin
            //POS Entries must belong to the same POS Legder Register Entry
            POSPostingLogEntryNo := CreatePOSPostingLogEntry(POSEntry);

            Commit;

            CreateTempRecordsToPost(POSEntry, TempPOSSalesLineToPost, TempPOSPaymentLinetoPost);
            CreatePostingBufferLinesFromPOSSalesLines(TempPOSSalesLineToPost, TempPOSPostingBuffer, PostCompressedVar);
            CreatePostingBufferLinesFromPOSSPaymentLines(TempPOSPaymentLinetoPost, TempPOSPostingBuffer, PostCompressedVar);

            if ((not TempPOSPaymentLinetoPost.IsEmpty) or (not TempPOSSalesLineToPost.IsEmpty)) and (TempPOSPostingBuffer.IsEmpty) then
                Error(TextErrorBufferLinesnotmade, TempPOSPostingBuffer.TableCaption);

            CreateGenJnlLinesFromPOSPostingBuffer(TempPOSPostingBuffer, TempGenJournalLine);

            if (not TempPOSPostingBuffer.IsEmpty) and (TempGenJournalLine.IsEmpty) then
                Error(TextErrorGJLinesnotmade, TempGenJournalLine.TableCaption);

            CreateGenJnlLinesFromPOSBalancingLines(POSEntry, TempGenJournalLine);
            CreateGenJournalLinesFromSalesTax(POSEntry, TempGenJournalLine);

            if StopOnErrorVar then begin
                CheckandPostGenJournal(TempGenJournalLine, POSEntry, POSEntryTemp);
                UpdatePOSPostingLogEntry(POSPostingLogEntryNo, false);
                MarkPOSEntries(0, POSPostingLogEntryNo, POSEntry, POSEntryTemp);
            end else begin
                Commit;
                if not CheckandPostGenJournal(TempGenJournalLine, POSEntry, POSEntryTemp) then begin
                    UpdatePOSPostingLogEntry(POSPostingLogEntryNo, true);
                    MarkPOSEntries(1, POSPostingLogEntryNo, POSEntry, POSEntryTemp);
                end else begin
                    UpdatePOSPostingLogEntry(POSPostingLogEntryNo, false);
                    MarkPOSEntries(0, POSPostingLogEntryNo, POSEntry, POSEntryTemp);
                end;

            end;
        end;

        if POSEntry.FindSet then
            repeat
                OnAfterPostPOSEntry(POSEntry, false);
            until POSEntry.Next = 0;

        OnAfterPostPOSEntryBatch(POSEntry, false);

        if ShowProgressDialog then
            ProgressWindow.Close;
    end;

    procedure PostRangePerPOSEntry(var POSEntry: Record "NPR POS Entry")
    var
        POSEntry2: Record "NPR POS Entry";
        PerEntryDialog: Dialog;
        NoOfRecords: Integer;
        LineCount: Integer;
    begin
        ShowProgressDialog := false;
        if GuiAllowed then begin
            PerEntryDialog.Open(Text006);
            NoOfRecords := POSEntry.Count;
        end;
        if POSEntry.FindSet then
            repeat
                if GuiAllowed then begin
                    LineCount := LineCount + 1;
                    PerEntryDialog.Update(1, POSEntry."Entry No.");
                    PerEntryDialog.Update(2, Round(LineCount / NoOfRecords * 10000, 1));
                end;
                POSEntry2.SetRange("Entry No.", POSEntry."Entry No.");
                Code(POSEntry2);
                Commit;
            until POSEntry.Next = 0;
        if GuiAllowed then
            PerEntryDialog.Close;
    end;

    procedure PostFromPOSPostingLog(var POSPostingLog: Record "NPR POS Posting Log")
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSPostingLog.TestField("POS Entry View");
        POSEntry.SetView(POSPostingLog."POS Entry View");
        if POSEntry.GetFilter("Entry No.") = '' then
            POSEntry.SetRange("Entry No.", 0, POSPostingLog."Last POS Entry No. at Posting");
        SetPostCompressed(POSPostingLog."Parameter Post Compressed");
        if POSPostingLog."Parameter Posting Date" <> 0D then
            SetPostingDate(POSPostingLog."Parameter Replace Posting Date", POSPostingLog."Parameter Replace Doc. Date", POSPostingLog."Parameter Posting Date");
        SetPostItemEntries(POSPostingLog."Parameter Post Item Entries");
        SetPostPOSEntries(POSPostingLog."Parameter Post POS Entries");
        SetStopOnError(true);
        Code(POSEntry);
    end;

    local procedure CreateTempRecordsToPost(var POSEntry: Record "NPR POS Entry"; var POSSalesLineToPost: Record "NPR POS Sales Line" temporary; var POSPaymentLineToPost: Record "NPR POS Payment Line" temporary)
    var
        POSSalesLine: Record "NPR POS Sales Line";
        POSPaymentLine: Record "NPR POS Payment Line";
        POSPeriodRegister: Record "NPR POS Period Register";
        LineCount: Integer;
        NoOfRecords: Integer;
        PreviousPOSPeriodRegister: Integer;
    begin
        if not POSSalesLineToPost.IsTemporary then
            exit;
        if not POSPaymentLineToPost.IsTemporary then
            exit;
        if ShowProgressDialog then begin
            NoOfRecords := POSEntry.Count;
            ProgressWindow.Update(2, NoOfRecords);
        end;

        if POSEntry.FindFirst then
            repeat
                if ShowProgressDialog then begin
                    LineCount := LineCount + 1;
                    ProgressWindow.Update(3, Round(LineCount / NoOfRecords * 10000, 1));
                end;
                if (POSEntry."Post Entry Status" in [POSEntry."Post Entry Status"::Unposted, POSEntry."Post Entry Status"::"Error while Posting"]) then begin
                    OnCheckPostingRestrictions(POSEntry, false);
                    OnBeforePostPOSEntry(POSEntry, false);

                    POSEntry.Recalculate;
                    if not CheckPOSTaxAmountLines(POSEntry, true) then
                        Error(TextErrorTaxMismatch, POSEntry."Entry No.");

                    if (POSEntry."POS Period Register No." <> PreviousPOSPeriodRegister) and (PreviousPOSPeriodRegister <> 0) then
                        Error(TextErrorMultiple, POSEntry."POS Period Register No.", PreviousPOSPeriodRegister, POSPeriodRegister.TableCaption);
                    if PostingDateExists then begin
                        if ReplacePostingDate or (POSEntry."Posting Date" = 0D) then begin
                            POSEntry."Posting Date" := PostingDate;
                            POSEntry.Validate("Currency Code");
                        end;
                        if ReplaceDocumentDate or (POSEntry."Document Date" = 0D) then begin
                            POSEntry.Validate("Document Date", PostingDate);
                        end;
                    end;

                    POSSalesLine.Reset;
                    POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                    POSSalesLine.SetRange("Exclude from Posting", false);
                    if POSSalesLine.FindSet then
                        repeat
                            POSSalesLineToPost := POSSalesLine;
                            POSSalesLineToPost.Insert;
                        until POSSalesLine.Next = 0;

                    POSPaymentLine.Reset;
                    POSPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                    if POSPaymentLine.FindSet then
                        repeat
                            POSPaymentLineToPost := POSPaymentLine;
                            POSPaymentLineToPost.Insert;
                        until POSPaymentLine.Next = 0;

                    PreviousPOSPeriodRegister := POSEntry."POS Period Register No.";
                end;
            until POSEntry.Next = 0;
    end;

    local procedure CreateGenJnlLinesFromPOSPostingBuffer(var POSPostingBuffer: Record "NPR POS Posting Buffer"; var GenJournalLine: Record "Gen. Journal Line")
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        POSPostingSetup: Record "NPR POS Posting Setup";
        Currency: Record Currency;
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSStore: Record "NPR POS Store";
        LineCount: Integer;
        NoOfRecords: Integer;
        GenPostingType: Enum "General Posting Type";
    begin
        SalesReceivablesSetup.Get;
        if ShowProgressDialog then begin
            NoOfRecords := POSPostingBuffer.Count;
            ProgressWindow.Update(4, NoOfRecords);
        end;

        if POSPostingBuffer.FindSet then
            repeat
                if ShowProgressDialog then begin
                    LineCount := LineCount + 1;
                    ProgressWindow.Update(5, Round(LineCount / NoOfRecords * 10000, 1));
                end;
                if POSPostingBuffer."Currency Code" <> '' then
                    Currency.Get(POSPostingBuffer."Currency Code")
                else
                    Currency.Init;
                case POSPostingBuffer."Line Type" of
                    POSPostingBuffer."Line Type"::Sales:
                        begin
                            case POSPostingBuffer.Type of
                                POSPostingBuffer.Type::Item:
                                    begin
                                        GeneralPostingSetup.Get(POSPostingBuffer."Gen. Bus. Posting Group", POSPostingBuffer."Gen. Prod. Posting Group");
                                        GeneralPostingSetup.TestField("Sales Account");
                                        if SalesReceivablesSetup."Discount Posting" in [SalesReceivablesSetup."Discount Posting"::"Line Discounts", SalesReceivablesSetup."Discount Posting"::"All Discounts"] then begin
                                            MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                              Round(POSPostingBuffer.Amount + POSPostingBuffer."Discount Amount", Currency."Amount Rounding Precision"),
                                              Round(POSPostingBuffer."Amount (LCY)" + POSPostingBuffer."Discount Amount (LCY)", Currency."Amount Rounding Precision"),
                                              GenJournalLine."Gen. Posting Type"::Sale,
                                              GenJournalLine."Account Type"::"G/L Account",
                                              GeneralPostingSetup."Sales Account",
                                              GenJournalLine."Account Type"::"G/L Account",
                                              '',
                                              Round(POSPostingBuffer."VAT Amount" + POSPostingBuffer."VAT Amount Discount", Currency."Amount Rounding Precision"),
                                              Round(POSPostingBuffer."VAT Amount (LCY)" + POSPostingBuffer."VAT Amount Discount (LCY)", Currency."Amount Rounding Precision"),
                                              GenJournalLine);

                                            if (POSPostingBuffer."Discount Amount" <> 0) or (POSPostingBuffer."Discount Amount (LCY)" <> 0) or
                                               (POSPostingBuffer."VAT Amount Discount" <> 0) or (POSPostingBuffer."VAT Amount Discount (LCY)" <> 0) then begin
                                                GeneralPostingSetup.TestField("Sales Line Disc. Account");
                                                MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                                  Round(-POSPostingBuffer."Discount Amount", Currency."Amount Rounding Precision"),
                                                  Round(-POSPostingBuffer."Discount Amount (LCY)", Currency."Amount Rounding Precision"),
                                                  GenJournalLine."Gen. Posting Type"::Sale,
                                                  GenJournalLine."Account Type"::"G/L Account",
                                                  GeneralPostingSetup."Sales Line Disc. Account",
                                                  GenJournalLine."Account Type"::"G/L Account",
                                                  '',
                                                  Round(-POSPostingBuffer."VAT Amount Discount", Currency."Amount Rounding Precision"),
                                                  Round(-POSPostingBuffer."VAT Amount Discount (LCY)", Currency."Amount Rounding Precision"),
                                                  GenJournalLine);
                                            end;
                                        end else begin
                                            MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                               POSPostingBuffer.Amount,
                                               POSPostingBuffer."Amount (LCY)",
                                               GenJournalLine."Gen. Posting Type"::Sale,
                                               GenJournalLine."Account Type"::"G/L Account",
                                               GeneralPostingSetup."Sales Account",
                                               GenJournalLine."Account Type"::"G/L Account",
                                               '',
                                               POSPostingBuffer."VAT Amount",
                                               POSPostingBuffer."VAT Amount (LCY)",
                                               GenJournalLine);
                                        end;
                                    end;
                                POSPostingBuffer.Type::"G/L Account", POSPostingBuffer.Type::Voucher:
                                    begin
                                        MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                            POSPostingBuffer.Amount,
                                            POSPostingBuffer."Amount (LCY)",
                                            GenJournalLine."Gen. Posting Type"::Sale,
                                            GenJournalLine."Account Type"::"G/L Account",
                                            POSPostingBuffer."No.",
                                            GenJournalLine."Account Type"::"G/L Account",
                                            '',
                                            POSPostingBuffer."VAT Amount",
                                            POSPostingBuffer."VAT Amount (LCY)",
                                            GenJournalLine);
                                    end;
                                POSPostingBuffer.Type::Customer:
                                    begin
                                        MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                            POSPostingBuffer.Amount,
                                            POSPostingBuffer."Amount (LCY)",
                                            GenJournalLine."Gen. Posting Type"::" ",
                                            GenJournalLine."Account Type"::Customer,
                                            POSPostingBuffer."No.",
                                            GenJournalLine."Account Type"::"G/L Account",
                                            '',
                                            POSPostingBuffer."VAT Amount",
                                            POSPostingBuffer."VAT Amount (LCY)",
                                            GenJournalLine);
                                        SetAppliesToDocument(GenJournalLine, POSPostingBuffer);
                                    end;
                                POSPostingBuffer.Type::Payout:
                                    begin
                                        MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                            POSPostingBuffer.Amount,
                                            POSPostingBuffer."Amount (LCY)",
                                            GenJournalLine."Gen. Posting Type"::Purchase,
                                            GenJournalLine."Account Type"::"G/L Account",
                                            POSPostingBuffer."No.",
                                            GenJournalLine."Account Type"::"G/L Account",
                                            '',
                                            POSPostingBuffer."VAT Amount",
                                            POSPostingBuffer."VAT Amount (LCY)",
                                            GenJournalLine);
                                    end;
                            end;
                        end;

                    POSPostingBuffer."Line Type"::Payment:
                        begin
                            GenPostingType := GenJournalLine."Gen. Posting Type"::" ";
                            if (POSPostingBuffer."VAT Amount (LCY)" <> 0) then
                                GenPostingType := GenJournalLine."Gen. Posting Type"::Sale;

                            GetPostingSetupFromBufferLine(POSPostingBuffer, POSPostingSetup);
                            MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                              POSPostingBuffer.Amount,
                              POSPostingBuffer."Amount (LCY)",
                              GenPostingType,
                              GetGLAccountType(POSPostingSetup),
                              POSPostingSetup."Account No.",
                              GenJournalLine."Account Type"::"G/L Account",
                              '',
                              POSPostingBuffer."VAT Amount",
                              POSPostingBuffer."VAT Amount (LCY)",
                              GenJournalLine);
                            if POSPostingBuffer."Applies-to Doc. No." <> '' then begin
                                GenJournalLine.Validate("Applies-to Doc. Type", POSPostingBuffer."Applies-to Doc. Type");
                                GenJournalLine.Validate("Applies-to Doc. No.", POSPostingBuffer."Applies-to Doc. No.");
                                GenJournalLine.Modify;
                            end;
                            if POSPostingBuffer."Rounding Amount (LCY)" > 0 then begin
                                POSPaymentMethod.Get(POSPostingBuffer."POS Payment Method Code");
                                POSPaymentMethod.TestField("Rounding Losses Account");
                                MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                  POSPostingBuffer."Rounding Amount",
                                  POSPostingBuffer."Rounding Amount (LCY)",
                                  GenJournalLine."Gen. Posting Type"::" ",
                                  GenJournalLine."Account Type"::"G/L Account",
                                  POSPaymentMethod."Rounding Losses Account",
                                  GenJournalLine."Account Type"::"G/L Account",
                                  '',
                                  POSPostingBuffer."VAT Amount",
                                  POSPostingBuffer."VAT Amount (LCY)",
                                  GenJournalLine);
                            end;
                            if POSPostingBuffer."Rounding Amount (LCY)" < 0 then begin
                                POSPaymentMethod.Get(POSPostingBuffer."POS Payment Method Code");
                                POSPaymentMethod.TestField("Rounding Losses Account");
                                MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                  -POSPostingBuffer."Rounding Amount",
                                  -POSPostingBuffer."Rounding Amount (LCY)",
                                  GenJournalLine."Gen. Posting Type"::" ",
                                  GenJournalLine."Account Type"::"G/L Account",
                                  POSPaymentMethod."Rounding Losses Account",
                                  GenJournalLine."Account Type"::"G/L Account",
                                  '',
                                  POSPostingBuffer."VAT Amount",
                                  POSPostingBuffer."VAT Amount (LCY)",
                                  GenJournalLine);
                            end;
                        end;
                end;
            until POSPostingBuffer.Next = 0;
    end;

    local procedure CreateGenJnlLinesFromPOSBalancingLines(var POSEntryIn: Record "NPR POS Entry"; var GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        POSBalancingLine: Record "NPR POS Balancing Line";
        POSPostingSetup: Record "NPR POS Posting Setup";
        POSPostingSetupNewBin: Record "NPR POS Posting Setup";
        LineCount: Integer;
        NoOfRecords: Integer;
        AmountToPostToAccount: Decimal;
    begin
        POSEntry.Copy(POSEntryIn);
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::Balancing);
        POSEntry.SetFilter(POSEntry."Post Entry Status", '<2');

        if POSEntry.FindSet then
            repeat
                POSBalancingLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                if POSBalancingLine.FindSet then
                    repeat
                        GetPostingSetupFromBalancingLine(POSBalancingLine, POSPostingSetup);
                        POSPostingSetup.TestField("Account No.");
                        AmountToPostToAccount := 0;
                        if POSBalancingLine."Balanced Diff. Amount" > 0 then begin
                            POSPostingSetup.TestField("Difference Acc. No.");
                            MakeGenJournalFromPOSBalancingLine(POSBalancingLine, POSBalancingLine."Balanced Diff. Amount", GetDifferenceAccountType(POSPostingSetup), POSPostingSetup."Difference Acc. No.", POSBalancingLine.Description, GenJournalLine);
                        end;
                        if POSBalancingLine."Balanced Diff. Amount" < 0 then begin
                            POSPostingSetup.TestField("Difference Acc. No. (Neg)");
                            MakeGenJournalFromPOSBalancingLine(POSBalancingLine, POSBalancingLine."Balanced Diff. Amount", GetDifferenceAccountType(POSPostingSetup), POSPostingSetup."Difference Acc. No. (Neg)", POSBalancingLine.Description, GenJournalLine);
                        end;
                        AmountToPostToAccount := -POSBalancingLine."Balanced Diff. Amount";

                        if (POSBalancingLine."Move-To Bin Amount" <> 0) then begin
                            POSBalancingLine.TestField("Move-To Bin Code");
                            if not GetPostingSetup(POSBalancingLine."POS Store Code", POSBalancingLine."POS Payment Method Code", POSBalancingLine."Move-To Bin Code", POSPostingSetupNewBin) then
                                Error(TextPostingSetupMissing, POSPostingSetup.TableCaption, POSBalancingLine.TableCaption, POSBalancingLine.FieldCaption("POS Entry No."), POSBalancingLine."POS Entry No.",
                                    StrSubstNo('%1: %4, %2: %5, %3: %6', POSBalancingLine.FieldCaption("POS Store Code"), POSBalancingLine.FieldCaption("POS Payment Method Code"), POSBalancingLine.FieldCaption("Move-To Bin Code"),
                                    POSBalancingLine."POS Store Code", POSBalancingLine."POS Payment Method Code", POSBalancingLine."Move-To Bin Code"));

                            if (POSPostingSetup."Account Type" <> POSPostingSetupNewBin."Account Type") or (POSPostingSetup."Account No." <> POSPostingSetupNewBin."Account No.") then begin
                                //Make posting only if the account is different for the new Bin
                                AmountToPostToAccount := AmountToPostToAccount - POSBalancingLine."Move-To Bin Amount";
                                POSPostingSetupNewBin.TestField("Account No.");
                                MakeGenJournalFromPOSBalancingLine(POSBalancingLine, POSBalancingLine."Move-To Bin Amount", GetGLAccountType(POSPostingSetupNewBin), POSPostingSetupNewBin."Account No.", POSBalancingLine."Move-To Reference", GenJournalLine);
                            end;
                        end;

                        if (POSBalancingLine."Deposit-To Bin Amount" <> 0) then begin
                            POSBalancingLine.TestField("Deposit-To Bin Code");
                            if not GetPostingSetup(POSBalancingLine."POS Store Code", POSBalancingLine."POS Payment Method Code", POSBalancingLine."Deposit-To Bin Code", POSPostingSetupNewBin) then
                                Error(TextPostingSetupMissing, POSPostingSetup.TableCaption, POSBalancingLine.TableCaption, POSBalancingLine.FieldCaption("POS Entry No."), POSBalancingLine."POS Entry No.",
                                    StrSubstNo('%1: %4, %2: %5, %3: %6', POSBalancingLine.FieldCaption("POS Store Code"), POSBalancingLine.FieldCaption("POS Payment Method Code"), POSBalancingLine.FieldCaption("Deposit-To Bin Code"),
                                    POSBalancingLine."POS Store Code", POSBalancingLine."POS Payment Method Code", POSBalancingLine."Deposit-To Bin Code"));

                            if (POSPostingSetup."Account Type" <> POSPostingSetupNewBin."Account Type") or (POSPostingSetup."Account No." <> POSPostingSetupNewBin."Account No.") then begin
                                AmountToPostToAccount := AmountToPostToAccount - POSBalancingLine."Deposit-To Bin Amount";
                                POSPostingSetupNewBin.TestField("Account No.");
                                MakeGenJournalFromPOSBalancingLine(POSBalancingLine, POSBalancingLine."Deposit-To Bin Amount", GetGLAccountType(POSPostingSetupNewBin), POSPostingSetupNewBin."Account No.", POSBalancingLine."Deposit-To Reference", GenJournalLine);
                            end;
                        end;

                        if POSBalancingLine."New Float Amount" <> 0 then
                            MakeGenJournalFromPOSBalancingLine(POSBalancingLine, POSBalancingLine."New Float Amount", GetGLAccountType(POSPostingSetup), POSPostingSetup."Account No.", StrSubstNo(TextClosingEntryFloat, POSEntry."Entry No."), GenJournalLine);
                        AmountToPostToAccount := AmountToPostToAccount - POSBalancingLine."New Float Amount";

                        if AmountToPostToAccount <> 0 then
                            MakeGenJournalFromPOSBalancingLine(POSBalancingLine, AmountToPostToAccount, GetGLAccountType(POSPostingSetup), POSPostingSetup."Account No.", POSBalancingLine.Description, GenJournalLine);
                    until POSBalancingLine.Next = 0;
            until POSEntry.Next = 0;
    end;

    local procedure PostItemEntries(var POSEntry: Record "NPR POS Entry")
    var
        POSEntryToPost: Record "NPR POS Entry";
        POSPostItemEntries: Codeunit "NPR POS Post Item Entries";
        POSPostItemTransaction: Codeunit "NPR POS Post Item Transaction";
        LineCount: Integer;
        NoOfRecords: Integer;
    begin

        if ShowProgressDialog then begin
            NoOfRecords := POSEntry.Count;
            ProgressWindow.Update(10, NoOfRecords);
        end;

        Commit;

        if POSEntry.FindSet then
            repeat
                if ShowProgressDialog then begin
                    LineCount := LineCount + 1;
                    ProgressWindow.Update(11, Round(LineCount / NoOfRecords * 10000, 1));
                end;
                if (POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::Unposted, POSEntry."Post Item Entry Status"::"Error while Posting"]) then begin
                    if PostingDateExists then
                        POSPostItemEntries.SetPostingDate(ReplaceDocumentDate, ReplaceDocumentDate, PostingDate);

                    POSEntryToPost.Get(POSEntry."Entry No.");
                    if StopOnErrorVar then begin
                        POSPostItemTransaction.Run(POSEntryToPost);
                    end else begin
                        if (not POSPostItemTransaction.Run(POSEntryToPost)) then;
                    end;
                end;
            until POSEntry.Next = 0;
    end;

    local procedure CheckandPostGenJournal(var GenJournalLine: Record "Gen. Journal Line"; var POSEntry: Record "NPR POS Entry"; var POSEntryWithError: Record "NPR POS Entry"): Boolean
    var
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        GenJournalLine.Reset;
        GenJournalLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
        if not StopOnErrorVar then begin
            if GenJournalLine.FindSet then begin
                repeat
                    if not GenJnlCheckLine.Run(GenJournalLine) then begin
                        ErrorText := GetLastErrorText;
                        exit(false);
                    end;
                until GenJournalLine.Next = 0;
            end;
        end;
        if not CheckOrPostGenJnlPerDocument(GenJournalLine, POSEntry, POSEntryWithError, 0) then
            exit(false);
        if not CheckOrPostGenJnlPerDocument(GenJournalLine, POSEntry, POSEntryWithError, 1) then
            exit(false);
        exit(true);
    end;

    local procedure CheckOrPostGenJnlPerDocument(var GenJournalLine: Record "Gen. Journal Line"; var POSEntry: Record "NPR POS Entry"; var POSEntryWithError: Record "NPR POS Entry"; Action: Option Check,Post) Success: Boolean
    begin
        if GenJournalLine.FindSet() then begin
            repeat
                GenJournalLine.SetRange("Posting Date", GenJournalLine."Posting Date");
                GenJournalLine.SetRange("Document No.", GenJournalLine."Document No.");
                case Action of
                    Action::Check:
                        Success := CheckGenJournalDocument(GenJournalLine, POSEntry);
                    Action::Post:
                        Success := PostGenJournalDocument(GenJournalLine, POSEntry);
                end;
                if not Success then begin
                    if GenJournalLine.FindSet() then
                        repeat
                            GenJournalLine.Mark(true); //marking entries that need to be deleted
                        until GenJournalLine.NEXT = 0;
                    POSEntryWithError."Entry No." := POSEntryWithError."Entry No." + 1;
                    POSEntryWithError."Document No." := GenJournalLine."Document No.";
                    POSEntryWithError.Insert();
                end;
                GenJournalLine.FindLast();
                GenJournalLine.SetRange("Posting Date");
                GenJournalLine.SetRange("Document No.");
            until GenJournalLine.Next() = 0;
        end;
        if Action = Action::Check then begin
            GenJournalLine.MarkedOnly(true);
            if GenJournalLine.IsTemporary then
                GenJournalLine.DeleteAll();
            GenJournalLine.MarkedOnly(false);
        end;
        exit(POSEntryWithError.IsEmpty);
    end;

    local procedure CheckGenJournalDocument(var GenJournalLine: Record "Gen. Journal Line"; var POSEntry: Record "NPR POS Entry"): Boolean
    var
        DifferenceAmount: Decimal;
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        DifferenceAmount := CalculateDifferenceAmount(GenJournalLine);
        if ABS(DifferenceAmount) > 0 then begin
            GetPOSPostingProfile(POSEntry, POSPostingProfile);
            if ABS(DifferenceAmount) > POSPostingProfile."Max. POS Posting Diff. (LCY)" then begin
                POSPostingProfile.TestField("POS Posting Diff. Account");
                ErrorText := StrSubstNo(TextImbalance, GenJournalLine.FieldCaption("Document No."), GenJournalLine."Document No.", GenJournalLine.FieldCaption("Posting Date"), GenJournalLine."Posting Date", DifferenceAmount);
                if StopOnErrorVar then
                    Error(ErrorText)
                else
                    exit(FALSE);
            end;
        end;
        exit(true);
    end;

    local procedure PostGenJournalDocument(var GenJournalLine: Record "Gen. Journal Line"; var POSEntry: Record "NPR POS Entry"): Boolean
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DifferenceAmount: Decimal;
    begin
        DifferenceAmount := CalculateDifferenceAmount(GenJournalLine);

        if (Abs(DifferenceAmount) > 0) then begin
            GetPOSPostingProfile(POSEntry, POSPostingProfile);
            MakeGenJournalLine(
              Enum::"Gen. Journal Account Type"::"G/L Account",
              POSPostingProfile."POS Posting Diff. Account",
              Enum::"Gen. Journal Account Type"::"G/L Account",
              '',
              Enum::"General Posting Type"::" ",
              GenJournalLine."Posting Date",
              GenJournalLine."Document No.",
              TextPostingDifference,
              0,
              '',
              -DifferenceAmount,
              -DifferenceAmount,
              '',
              '',
              '',
              '',
              '',
              GenJournalLine."Shortcut Dimension 1 Code",
              GenJournalLine."Shortcut Dimension 2 Code",
              GenJournalLine."Dimension Set ID",
              GenJournalLine."Salespers./Purch. Code",
              GenJournalLine."Reason Code",
              GenJournalLine."External Document No.",
              GenJournalLine."Tax Area Code",
              GenJournalLine."Tax Liable",
              GenJournalLine."Tax Group Code",
              GenJournalLine."Use Tax",
              0,
              0,
              '',
              POSPostingProfile."Source Code",
              GenJournalLine);
        end;

        exit(PostGenJournalLines(GenJournalLine));
    end;

    local procedure PostGenJournalLines(var GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        GenJournalLine2: Record "Gen. Journal Line";
    begin
        if GenJournalLine.FindSet then
            repeat
                GenJnlPostLine.Run(GenJournalLine);
            until GenJournalLine.Next = 0;
        exit(true);
    end;

    procedure SetPostingDate(NewReplacePostingDate: Boolean; NewReplaceDocumentDate: Boolean; NewPostingDate: Date)
    begin
        PostingDateExists := true;
        ReplaceDocumentDate := NewReplaceDocumentDate;
        ReplaceDocumentDate := NewReplacePostingDate;
        PostingDate := NewPostingDate;
    end;

    procedure SetPostCompressed(PostCompressedIn: Boolean)
    begin
        PostCompressedVar := PostCompressedIn;
    end;

    procedure SetPostItemEntries(PostItemEntriesIn: Boolean)
    begin
        PostItemEntriesVar := PostItemEntriesIn;
    end;

    procedure SetPostPOSEntries(PostPOSEntriesIn: Boolean)
    begin
        PostPOSEntriesVar := PostPOSEntriesIn;
    end;

    procedure SetStopOnError(StopOnErrorIn: Boolean)
    begin
        StopOnErrorVar := StopOnErrorIn;
    end;

    procedure CheckPOSTaxAmountLines(var POSEntry: Record "NPR POS Entry"; ThrowError: Boolean) Result: Boolean
    begin
        ClearLastError();
        Result := TryCheckPOSTaxAmountLines(POSEntry);
        if (not Result) and ThrowError then
            Error(GetLastErrorText);
    end;

    [TryFunction]
    local procedure TryCheckPOSTaxAmountLines(var POSEntry: Record "NPR POS Entry")
    var
        POSTaxAmountLine: Record "NPR POS Tax Amount Line";
        TempPOSTaxAmountLine: Record "NPR POS Tax Amount Line" temporary;
        POSSalesLine: Record "NPR POS Sales Line";
        TempPOSSalesLine: Record "NPR POS Sales Line" temporary;
        Currency: Record Currency;
        SalesAmountIncludingTax: Decimal;
        TaxAmountSalesLines: Decimal;
        RemSalesTaxAmt: Decimal;
        TaxJurisdiction: Record "Tax Jurisdiction";
    begin
        if POSEntry."Currency Code" <> '' then
            Currency.Get(POSEntry."Currency Code")
        else
            Currency.Init;
        TaxAmountSalesLines := 0;

        POSTaxAmountLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSTaxAmountLine.FindSet then
            repeat
                if POSTaxAmountLine."Tax Calculation Type" = POSTaxAmountLine."Tax Calculation Type"::"Sales Tax" then begin
                    if POSTaxAmountLine."Tax Jurisdiction Code" <> TaxJurisdiction.Code then begin
                        TaxJurisdiction.Get(POSTaxAmountLine."Tax Jurisdiction Code");
                        RemSalesTaxAmt := 0;
                    end;
                    RemSalesTaxAmt := RemSalesTaxAmt + POSTaxAmountLine."Tax Amount";
                    TempPOSTaxAmountLine."Tax Amount" += Round(RemSalesTaxAmt);
                    RemSalesTaxAmt := RemSalesTaxAmt - Round(RemSalesTaxAmt);
                end else begin
                    TempPOSTaxAmountLine."Tax Amount" += Round(POSTaxAmountLine."Tax Amount", Currency."Amount Rounding Precision");
                    TempPOSTaxAmountLine."Amount Including Tax" += Round(POSTaxAmountLine."Amount Including Tax", Currency."Amount Rounding Precision");
                    TempPOSTaxAmountLine."Tax Base Amount" += Round(POSTaxAmountLine."Tax Base Amount", Currency."Amount Rounding Precision");
                end;
            until POSTaxAmountLine.Next = 0;

        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSSalesLine.SetFilter(Type, '<>%1', POSSalesLine.Type::Rounding);
        POSSalesLine.SetRange("Exclude from Posting", false);
        if POSSalesLine.FindSet then
            repeat
                if POSSalesLine."VAT Calculation Type" = POSSalesLine."VAT Calculation Type"::"Sales Tax" then begin
                    TaxAmountSalesLines := TaxAmountSalesLines + (POSSalesLine."Amount Incl. VAT" - POSSalesLine."Amount Excl. VAT");
                end else begin
                    TaxAmountSalesLines := TaxAmountSalesLines + (POSSalesLine."Amount Incl. VAT" - POSSalesLine."Amount Excl. VAT");
                    TempPOSSalesLine."Amount Incl. VAT" += POSSalesLine."Amount Incl. VAT";
                    TempPOSSalesLine."Amount Excl. VAT" += POSSalesLine."Amount Excl. VAT";
                end;
            until POSSalesLine.Next = 0;

        if TempPOSTaxAmountLine."Tax Amount" <> TaxAmountSalesLines then
            Error(TextSalesTaxDiscrepancy, TempPOSTaxAmountLine.FieldCaption("Tax Amount"), TaxAmountSalesLines, TempPOSTaxAmountLine."Tax Amount");
        if TempPOSTaxAmountLine."Amount Including Tax" <> TempPOSSalesLine."Amount Incl. VAT" then
            Error(TextSalesTaxDiscrepancy, TempPOSTaxAmountLine.FieldCaption("Amount Including Tax"), TempPOSSalesLine."Amount Incl. VAT", TempPOSTaxAmountLine."Amount Including Tax");
        if TempPOSTaxAmountLine."Tax Base Amount" <> TempPOSSalesLine."Amount Excl. VAT" then
            Error(TextSalesTaxDiscrepancy, TempPOSTaxAmountLine.FieldCaption("Tax Base Amount"), TempPOSSalesLine."Amount Excl. VAT", TempPOSTaxAmountLine."Tax Base Amount");
    end;

    local procedure CreatePostingBufferLinesFromPOSSalesLines(var POSSalesLineToBeCompressed: Record "NPR POS Sales Line"; var POSPostingBuffer: Record "NPR POS Posting Buffer"; PostCompressed: Boolean)
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
        PostingDescription: Text;
        Compressionmethod: Option Uncompressed,"Per POS Entry","Per POS Period Register";
        cnt: Integer;
    begin
        if POSSalesLineToBeCompressed.FindSet then
            repeat

                POSEntry.Get(POSSalesLineToBeCompressed."POS Entry No.");
                POSPeriodRegister.Get(POSEntry."POS Period Register No.");
                Compressionmethod := GetCompressionMethod(POSPeriodRegister, PostCompressedVar);
                if Compressionmethod = Compressionmethod::"Per POS Period Register" then
                    if POSSalesLineToBeCompressed."VAT Calculation Type" = POSSalesLineToBeCompressed."VAT Calculation Type"::"Sales Tax" then
                        Error(TextErrorSalesTaxCompressed, POSEntry.TableCaption, POSSalesLineToBeCompressed."POS Entry No.");

                Clear(POSPostingBuffer);
                POSPostingBuffer.Init;

                POSPostingBuffer."Posting Date" := POSEntry."Posting Date";
                POSPostingBuffer."Line Type" := POSPostingBuffer."Line Type"::Sales;
                POSPostingBuffer.Type := POSSalesLineToBeCompressed.Type;
                case POSSalesLineToBeCompressed.Type of
                    POSSalesLineToBeCompressed.Type::Rounding:
                        begin
                            POSPostingBuffer.Type := POSPostingBuffer.Type::"G/L Account";
                            POSPostingBuffer."No." := POSSalesLineToBeCompressed."No.";
                        end;
                    else
                        POSPostingBuffer.Type := POSSalesLineToBeCompressed.Type;
                end;
                if POSSalesLineToBeCompressed.Type in [POSSalesLineToBeCompressed.Type::"G/L Account", POSSalesLineToBeCompressed.Type::Customer] then
                    POSPostingBuffer."No." := POSSalesLineToBeCompressed."No.";
                if POSSalesLineToBeCompressed.Type <> POSSalesLineToBeCompressed.Type::Customer then begin
                    POSPostingBuffer."Gen. Bus. Posting Group" := POSSalesLineToBeCompressed."Gen. Bus. Posting Group";
                    POSPostingBuffer."VAT Bus. Posting Group" := POSSalesLineToBeCompressed."VAT Bus. Posting Group";
                end;
                if POSSalesLineToBeCompressed.Type = POSSalesLineToBeCompressed.Type::Payout then begin
                    POSPostingBuffer."No." := POSSalesLineToBeCompressed."No.";
                    Compressionmethod := Compressionmethod::Uncompressed;
                end;

                if POSSalesLineToBeCompressed.type = POSSalesLineToBeCompressed.Type::Voucher then begin
                    POSPostingBuffer."No." := POSSalesLineToBeCompressed."No.";
                    Compressionmethod := Compressionmethod::Uncompressed;
                end;

                POSPostingBuffer."Applies-to Doc. Type" := POSSalesLineToBeCompressed."Applies-to Doc. Type";
                POSPostingBuffer."Applies-to Doc. No." := POSSalesLineToBeCompressed."Applies-to Doc. No.";
                POSPostingBuffer."Gen. Prod. Posting Group" := POSSalesLineToBeCompressed."Gen. Prod. Posting Group";
                POSPostingBuffer."VAT Prod. Posting Group" := POSSalesLineToBeCompressed."VAT Prod. Posting Group";
                POSPostingBuffer."Global Dimension 1 Code" := POSSalesLineToBeCompressed."Shortcut Dimension 1 Code";
                POSPostingBuffer."Global Dimension 2 Code" := POSSalesLineToBeCompressed."Shortcut Dimension 2 Code";
                POSPostingBuffer."Dimension Set ID" := POSSalesLineToBeCompressed."Dimension Set ID";
                POSPostingBuffer."Salesperson Code" := POSSalesLineToBeCompressed."Salesperson Code";
                POSPostingBuffer."Reason Code" := POSSalesLineToBeCompressed."Reason Code";
                POSPostingBuffer."Currency Code" := POSSalesLineToBeCompressed."Currency Code";
                POSPostingBuffer."VAT Calculation Type" := POSSalesLineToBeCompressed."VAT Calculation Type";
                POSPostingBuffer."Tax Area Code" := POSSalesLineToBeCompressed."Tax Area Code";
                POSPostingBuffer."Tax Liable" := POSSalesLineToBeCompressed."Tax Liable";
                POSPostingBuffer."Tax Group Code" := POSSalesLineToBeCompressed."Tax Group Code";
                POSPostingBuffer."Use Tax" := POSSalesLineToBeCompressed."Use Tax";
                POSPostingBuffer."VAT %" := POSSalesLineToBeCompressed."VAT %";
                POSPostingBuffer."POS Store Code" := POSSalesLineToBeCompressed."POS Store Code";
                POSPostingBuffer."POS Unit No." := POSSalesLineToBeCompressed."POS Unit No.";
                POSPostingBuffer."POS Period Register" := POSSalesLineToBeCompressed."POS Period Register No.";
                case Compressionmethod of
                    Compressionmethod::Uncompressed:
                        begin
                            POSPostingBuffer."POS Entry No." := POSSalesLineToBeCompressed."POS Entry No.";
                            POSPostingBuffer."Line No." := POSSalesLineToBeCompressed."Line No.";
                            POSPostingBuffer."No." := POSSalesLineToBeCompressed."No.";
                            if POSPeriodRegister."Document No." = '' then
                                POSPostingBuffer."Document No." := POSSalesLineToBeCompressed."Document No."
                            else
                                POSPostingBuffer."Document No." := POSPeriodRegister."Document No.";
                            PostingDescription := POSSalesLineToBeCompressed.Description;
                        end;
                    Compressionmethod::"Per POS Entry":
                        begin
                            POSPostingBuffer."POS Entry No." := POSSalesLineToBeCompressed."POS Entry No.";
                            if POSPeriodRegister."Document No." = '' then
                                POSPostingBuffer."Document No." := POSSalesLineToBeCompressed."Document No."
                            else
                                POSPostingBuffer."Document No." := POSPeriodRegister."Document No.";
                            PostingDescription := StrSubstNo(TextDesc, POSEntry.TableCaption, POSSalesLineToBeCompressed."POS Entry No.");
                        end;
                    Compressionmethod::"Per POS Period Register":
                        begin
                            POSPeriodRegister.TestField("Document No.");
                            POSPostingBuffer."Document No." := POSPeriodRegister."Document No.";
                            PostingDescription := StrSubstNo(TextDesc, POSPeriodRegister.TableCaption, POSSalesLineToBeCompressed."POS Period Register No.");
                        end;
                end;

                if not POSPostingBuffer.Find then begin
                    POSPostingBuffer."VAT Base Amount" := 0;
                    POSPostingBuffer.Quantity := 0;
                    POSPostingBuffer."VAT Difference" := 0;
                    POSPostingBuffer."VAT Amount" := 0;
                    POSPostingBuffer."VAT Amount (LCY)" := 0;
                    POSPostingBuffer."Discount Amount" := 0;
                    POSPostingBuffer."Discount Amount (LCY)" := 0;
                    POSPostingBuffer.Amount := 0;
                    POSPostingBuffer."Amount (LCY)" := 0;
                    POSPostingBuffer."VAT Amount Discount" := 0;
                    POSPostingBuffer."VAT Amount Discount (LCY)" := 0;
                    POSPostingBuffer.Description := CopyStr(PostingDescription, 1, MaxStrLen(POSPostingBuffer.Description));
                    POSPostingBuffer.Insert;
                end;
                POSPostingBuffer."VAT Base Amount" := POSPostingBuffer."VAT Base Amount" - POSSalesLineToBeCompressed."VAT Base Amount";
                POSPostingBuffer.Quantity := POSPostingBuffer.Quantity + POSSalesLineToBeCompressed.Quantity;
                POSPostingBuffer."VAT Difference" := POSPostingBuffer."VAT Difference" - POSSalesLineToBeCompressed."VAT Difference";
                POSPostingBuffer."VAT Amount" := POSPostingBuffer."VAT Amount" - (POSSalesLineToBeCompressed."Amount Incl. VAT" - POSSalesLineToBeCompressed."Amount Excl. VAT");
                POSPostingBuffer."VAT Amount (LCY)" := POSPostingBuffer."VAT Amount (LCY)" - (POSSalesLineToBeCompressed."Amount Incl. VAT (LCY)" - POSSalesLineToBeCompressed."Amount Excl. VAT (LCY)");
                POSPostingBuffer."Discount Amount" := POSPostingBuffer."Discount Amount" - POSSalesLineToBeCompressed."Line Discount Amount Excl. VAT";
                POSPostingBuffer."Discount Amount (LCY)" := POSPostingBuffer."Discount Amount (LCY)" - POSSalesLineToBeCompressed."Line Dsc. Amt. Excl. VAT (LCY)";
                POSPostingBuffer.Amount := POSPostingBuffer.Amount - POSSalesLineToBeCompressed."Amount Excl. VAT";
                POSPostingBuffer."Amount (LCY)" := POSPostingBuffer."Amount (LCY)" - POSSalesLineToBeCompressed."Amount Excl. VAT (LCY)";
                POSPostingBuffer."VAT Amount Discount" := POSPostingBuffer."VAT Amount Discount" - (POSSalesLineToBeCompressed."Line Discount Amount Incl. VAT" - POSSalesLineToBeCompressed."Line Discount Amount Excl. VAT");
                POSPostingBuffer."VAT Amount Discount (LCY)" := POSPostingBuffer."VAT Amount Discount (LCY)" - (POSSalesLineToBeCompressed."Line Dsc. Amt. Incl. VAT (LCY)" - POSSalesLineToBeCompressed."Line Dsc. Amt. Excl. VAT (LCY)");
                POSPostingBuffer.Modify;
            until POSSalesLineToBeCompressed.Next = 0;
    end;

    local procedure CreatePostingBufferLinesFromPOSSPaymentLines(var POSPaymentLineToBeCompressed: Record "NPR POS Payment Line"; var POSPostingBuffer: Record "NPR POS Posting Buffer"; PostCompressed: Boolean)
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
        POSPaymentMethod: Record "NPR POS Payment Method";
        PostingDescription: Text;
        Compressionmethod: Option Uncompressed,"Per POS Entry","Per POS Period Register";
    begin
        if POSPaymentLineToBeCompressed.FindSet then
            repeat

                POSEntry.Get(POSPaymentLineToBeCompressed."POS Entry No.");
                POSPeriodRegister.Get(POSEntry."POS Period Register No.");
                Compressionmethod := GetCompressionMethod(POSPeriodRegister, PostCompressedVar);

                Clear(POSPostingBuffer);
                POSPostingBuffer.Init;

                POSPostingBuffer."Posting Date" := POSEntry."Posting Date";
                POSPostingBuffer."Line Type" := POSPostingBuffer."Line Type"::Payment;
                POSPostingBuffer."No." := POSPaymentLineToBeCompressed."POS Payment Method Code";
                POSPostingBuffer."POS Payment Method Code" := POSPaymentLineToBeCompressed."POS Payment Method Code";
                POSPostingBuffer."Global Dimension 1 Code" := POSPaymentLineToBeCompressed."Shortcut Dimension 1 Code";
                POSPostingBuffer."Global Dimension 2 Code" := POSPaymentLineToBeCompressed."Shortcut Dimension 2 Code";
                POSPostingBuffer."Dimension Set ID" := POSPaymentLineToBeCompressed."Dimension Set ID";
                POSPostingBuffer."Salesperson Code" := POSEntry."Salesperson Code";
                POSPostingBuffer."Currency Code" := POSPaymentLineToBeCompressed."Currency Code";
                POSPostingBuffer."POS Store Code" := POSPaymentLineToBeCompressed."POS Store Code";
                POSPostingBuffer."POS Unit No." := POSPaymentLineToBeCompressed."POS Unit No.";
                POSPostingBuffer."POS Period Register" := POSPaymentLineToBeCompressed."POS Period Register No.";
                POSPostingBuffer."POS Payment Bin Code" := POSPaymentLineToBeCompressed."POS Payment Bin Code";
                POSPostingBuffer."Applies-to Doc. Type" := POSPostingBuffer."Applies-to Doc. Type";
                POSPostingBuffer."Applies-to Doc. No." := POSPostingBuffer."Applies-to Doc. No.";
                POSPostingBuffer."VAT Prod. Posting Group" := POSPaymentLineToBeCompressed."VAT Prod. Posting Group";
                POSPostingBuffer."VAT Bus. Posting Group" := POSPaymentLineToBeCompressed."VAT Bus. Posting Group";
                PostingDescription := POSPaymentLineToBeCompressed.Description;
                if POSPaymentMethod.Get(POSPaymentLineToBeCompressed."POS Payment Method Code") then begin
                    if not POSPaymentMethod."Post Condensed" then begin
                        POSPostingBuffer."POS Entry No." := POSPaymentLineToBeCompressed."POS Entry No.";
                        POSPostingBuffer."Line No." := POSPaymentLineToBeCompressed."Line No.";
                        POSPostingBuffer."External Document No." := POSPaymentLineToBeCompressed."External Document No.";
                    end else begin
                        if (POSPaymentMethod."Condensed Posting Description" = '') then
                            case Compressionmethod of
                                Compressionmethod::Uncompressed:
                                    POSPaymentMethod."Condensed Posting Description" := '%6 - %3';
                                Compressionmethod::"Per POS Entry":
                                    POSPaymentMethod."Condensed Posting Description" := '%6 - %3';
                                Compressionmethod::"Per POS Period Register":
                                    POSPaymentMethod."Condensed Posting Description" := '%2/%1/%6 - %4/%3';
                            end;

                        if POSPaymentMethod."Condensed Posting Description" <> '' then
                            PostingDescription := CopyStr(StrSubstNo(POSPaymentMethod."Condensed Posting Description",
                                   POSPaymentLineToBeCompressed."POS Unit No.",
                                   POSPaymentLineToBeCompressed."POS Store Code",
                                   POSEntry."Posting Date",
                                   POSEntry."POS Period Register No.",
                                   POSPaymentLineToBeCompressed."POS Payment Bin Code",
                                   POSPaymentMethod.Code
                                   ), 1, MaxStrLen(POSPostingBuffer.Description))
                        else
                            PostingDescription := CopyStr(StrSubstNo(TextPaymentDescription, POSPaymentMethod.Code, POSEntry."Posting Date"), 1, MaxStrLen(POSPostingBuffer.Description));
                    end;
                end;

                case Compressionmethod of
                    Compressionmethod::Uncompressed:
                        begin
                            POSPostingBuffer."POS Payment Bin Code" := POSPaymentLineToBeCompressed."POS Payment Bin Code";
                            POSPostingBuffer."POS Entry No." := POSPaymentLineToBeCompressed."POS Entry No.";
                            POSPostingBuffer."Line No." := POSPaymentLineToBeCompressed."Line No.";
                            if POSPeriodRegister."Document No." = '' then
                                POSPostingBuffer."Document No." := POSPaymentLineToBeCompressed."Document No."
                            else
                                POSPostingBuffer."Document No." := POSPeriodRegister."Document No.";
                        end;
                    Compressionmethod::"Per POS Entry":
                        begin
                            POSPostingBuffer."POS Entry No." := POSPaymentLineToBeCompressed."POS Entry No.";
                            if POSPeriodRegister."Document No." = '' then
                                POSPostingBuffer."Document No." := POSPaymentLineToBeCompressed."Document No."
                            else
                                POSPostingBuffer."Document No." := POSPeriodRegister."Document No.";
                        end;
                    Compressionmethod::"Per POS Period Register":
                        begin
                            POSPeriodRegister.TestField("Document No.");
                            POSPostingBuffer."Document No." := POSPeriodRegister."Document No.";
                        end;
                end;

                if not POSPostingBuffer.Find then begin
                    POSPostingBuffer.Amount := 0;
                    POSPostingBuffer."Amount (LCY)" := 0;
                    POSPostingBuffer."Rounding Amount" := 0;
                    POSPostingBuffer."Rounding Amount (LCY)" := 0;
                    POSPostingBuffer.Description := CopyStr(PostingDescription, 1, MaxStrLen(POSPostingBuffer.Description));
                    POSPostingBuffer."VAT Amount (LCY)" := 0;
                    POSPostingBuffer."VAT Base Amount" := 0;
                    POSPostingBuffer.Insert;
                end;

                POSPostingBuffer."Rounding Amount" := POSPostingBuffer."Rounding Amount" + POSPaymentLineToBeCompressed."Rounding Amount";
                POSPostingBuffer."Rounding Amount (LCY)" := POSPostingBuffer."Rounding Amount" + POSPaymentLineToBeCompressed."Rounding Amount (LCY)";
                POSPostingBuffer.Amount := POSPostingBuffer.Amount + POSPaymentLineToBeCompressed.Amount - POSPaymentLineToBeCompressed."VAT Amount (LCY)";
                POSPostingBuffer."Amount (LCY)" := POSPostingBuffer."Amount (LCY)" + POSPaymentLineToBeCompressed."Amount (LCY)" - POSPaymentLineToBeCompressed."VAT Amount (LCY)";

                POSPostingBuffer."VAT Amount" += POSPaymentLineToBeCompressed."VAT Amount (LCY)"; // VAT reversal in foreign currency not supported.
                POSPostingBuffer."VAT Amount (LCY)" += POSPaymentLineToBeCompressed."VAT Amount (LCY)";
                POSPostingBuffer."VAT Base Amount" += POSPaymentLineToBeCompressed."VAT Base Amount (LCY)";
                POSPostingBuffer.Modify;
            until POSPaymentLineToBeCompressed.Next = 0;
    end;

    local procedure CreatePOSPostingLogEntry(var POSEntry: Record "NPR POS Entry"): Integer
    var
        POSPostingLog: Record "NPR POS Posting Log";
        LastPOSEntry: Record "NPR POS Entry";
    begin
        LastPOSEntry.Reset;
        LastPOSEntry.FindLast;
        POSPostingLog.Init;
        POSPostingLog."Entry No." := 0;
        POSPostingLog."User ID" := UserId;
        POSPostingLog."Posting Timestamp" := CurrentDateTime;
        POSPostingLog."With Error" := true;
        POSPostingLog."Error Description" := TextUnknownError;
        POSPostingLog."POS Entry View" := CopyStr(POSEntry.GetView, 1, MaxStrLen(POSPostingLog."POS Entry View"));
        POSPostingLog."Last POS Entry No. at Posting" := LastPOSEntry."Entry No.";
        POSPostingLog."Parameter Posting Date" := PostingDate;
        POSPostingLog."Parameter Replace Posting Date" := ReplacePostingDate;
        POSPostingLog."Parameter Replace Doc. Date" := ReplaceDocumentDate;
        POSPostingLog."Parameter Post Item Entries" := PostItemEntriesVar;
        POSPostingLog."Parameter Post POS Entries" := PostPOSEntriesVar;
        POSPostingLog."Parameter Post Compressed" := PostCompressedVar;
        POSPostingLog."Parameter Stop On Error" := StopOnErrorVar;
        POSPostingLog.Insert(true);
        exit(POSPostingLog."Entry No.");
    end;

    local procedure UpdatePOSPostingLogEntry(POSPostingLogEntryNo: Integer; WithError: Boolean)
    var
        POSPostingLog: Record "NPR POS Posting Log";
    begin
        POSPostingLog.Get(POSPostingLogEntryNo);
        if WithError then begin
            POSPostingLog."With Error" := true;
            POSPostingLog."Error Description" := CopyStr(ErrorText, 1, MaxStrLen(POSPostingLog."Error Description"));
        end else begin
            POSPostingLog."With Error" := false;
            POSPostingLog."Error Description" := '';
        end;
        POSPostingLog."Posting Duration" := CurrentDateTime - POSPostingLog."Posting Timestamp";
        POSPostingLog.Modify(true);
    end;

    local procedure GetCompressionMethod(POSPeriodRegister: Record "NPR POS Period Register"; PostCompressed: Boolean): Integer
    begin
        if (not PostCompressed) then
            if (POSPeriodRegister."Posting Compression" = POSPeriodRegister."Posting Compression"::"Per POS Period") then
                exit(POSPeriodRegister."Posting Compression"::"Per POS Entry");

        exit(POSPeriodRegister."Posting Compression");
    end;

    local procedure GetPostingSetupFromBufferLine(POSPostingBuffer: Record "NPR POS Posting Buffer"; var POSPostingSetup: Record "NPR POS Posting Setup")
    begin
        if not GetPostingSetup(POSPostingBuffer."POS Store Code", POSPostingBuffer."POS Payment Method Code", POSPostingBuffer."POS Payment Bin Code", POSPostingSetup) then
            if POSPostingBuffer."POS Entry No." <> 0 then
                Error(TextPostingSetupMissing, POSPostingSetup.TableCaption, POSPostingBuffer."Line Type", POSPostingBuffer.FieldCaption("POS Entry No."), POSPostingBuffer."POS Entry No.",
                    StrSubstNo('%1: %4, %2: %5, %3: %6', POSPostingBuffer.FieldCaption("POS Store Code"), POSPostingBuffer.FieldCaption("POS Payment Method Code"), POSPostingBuffer.FieldCaption("POS Payment Bin Code"),
                    POSPostingBuffer."POS Store Code", POSPostingBuffer."POS Payment Method Code", POSPostingBuffer."POS Payment Bin Code"))
            else
                Error(TextPostingSetupMissing, POSPostingSetup.TableCaption, POSPostingBuffer."Line Type", POSPostingBuffer."POS Period Register", POSPostingBuffer."POS Period Register",
                    StrSubstNo('%1: %4, %2: %5, %3: %6', POSPostingBuffer.FieldCaption("POS Store Code"), POSPostingBuffer.FieldCaption("POS Payment Method Code"), POSPostingBuffer.FieldCaption("POS Payment Bin Code"),
                    POSPostingBuffer."POS Store Code", POSPostingBuffer."POS Payment Method Code", POSPostingBuffer."POS Payment Bin Code"));
    end;

    local procedure GetPostingSetupFromBalancingLine(POSBalancingLine: Record "NPR POS Balancing Line"; var POSPostingSetup: Record "NPR POS Posting Setup")
    begin
        if not GetPostingSetup(POSBalancingLine."POS Store Code", POSBalancingLine."POS Payment Method Code", POSBalancingLine."POS Payment Bin Code", POSPostingSetup) then
            if POSBalancingLine."POS Entry No." <> 0 then
                Error(TextPostingSetupMissing, POSPostingSetup.TableCaption, POSBalancingLine.TableCaption, POSBalancingLine.FieldCaption("POS Entry No."), POSBalancingLine."POS Entry No.",
                    StrSubstNo('%1: %4, %2: %5, %3: %6', POSBalancingLine.FieldCaption("POS Store Code"), POSBalancingLine.FieldCaption("POS Payment Method Code"), POSBalancingLine.FieldCaption("POS Payment Bin Code"),
                    POSBalancingLine."POS Store Code", POSBalancingLine."POS Payment Method Code", POSBalancingLine."POS Payment Bin Code"))
            else
                Error(TextPostingSetupMissing, POSPostingSetup.TableCaption, POSBalancingLine.TableCaption, POSBalancingLine.FieldCaption("POS Period Register No."), POSBalancingLine."POS Period Register No.",
                    StrSubstNo('%1: %4, %2: %5, %3: %6', POSBalancingLine.FieldCaption("POS Store Code"), POSBalancingLine.FieldCaption("POS Payment Method Code"), POSBalancingLine.FieldCaption("POS Payment Bin Code"),
                    POSBalancingLine."POS Store Code", POSBalancingLine."POS Payment Method Code", POSBalancingLine."POS Payment Bin Code"));
    end;

    procedure GetPostingSetup(POSStoreCode: Code[10]; POSPaymentMethodCode: Code[10]; POSPaymentBinCode: Code[10]; var POSPostingSetup: Record "NPR POS Posting Setup"): Boolean
    var
        LocPOSPostingSetup: Record "NPR POS Posting Setup";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
    begin
        //All three match
        if LocPOSPostingSetup.Get(POSStoreCode, POSPaymentMethodCode, POSPaymentBinCode) then begin
            POSEntryManagement.CheckPostingSetupLine(LocPOSPostingSetup);
            POSPostingSetup := LocPOSPostingSetup;
            exit(true);
        end;
        //Store and Method
        if LocPOSPostingSetup.Get(POSStoreCode, POSPaymentMethodCode, '') then begin
            POSEntryManagement.CheckPostingSetupLine(LocPOSPostingSetup);
            POSPostingSetup := LocPOSPostingSetup;
            exit(true);
        end;
        //Store and Bin
        if LocPOSPostingSetup.Get(POSStoreCode, '', POSPaymentBinCode) then begin
            POSEntryManagement.CheckPostingSetupLine(LocPOSPostingSetup);
            POSPostingSetup := LocPOSPostingSetup;
            exit(true);
        end;
        //Method and Bin
        if LocPOSPostingSetup.Get('', POSPaymentMethodCode, POSPaymentBinCode) then begin
            POSEntryManagement.CheckPostingSetupLine(LocPOSPostingSetup);
            POSPostingSetup := LocPOSPostingSetup;
            exit(true);
        end;
        //Method only
        if LocPOSPostingSetup.Get('', POSPaymentMethodCode, '') then begin
            POSEntryManagement.CheckPostingSetupLine(LocPOSPostingSetup);
            POSPostingSetup := LocPOSPostingSetup;
            exit(true);
        end;
        exit(false);
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
        Error(TextAccountTypeNotSupported, POSPostingSetup.FieldCaption("Account Type"), POSPostingSetup.TableCaption);
    end;

    local procedure GetDifferenceAccountType(POSPostingSetup: Record "NPR POS Posting Setup"): Enum "Gen. Journal Account Type"
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        case POSPostingSetup."Difference Account Type" of
            POSPostingSetup."Difference Account Type"::"G/L Account":
                exit(GenJournalLine."Account Type"::"G/L Account");
            POSPostingSetup."Difference Account Type"::"Bank Account":
                exit(GenJournalLine."Account Type"::"Bank Account");
            POSPostingSetup."Difference Account Type"::Customer:
                exit(GenJournalLine."Account Type"::Customer);
        end;
        Error(TextAccountTypeNotSupported, POSPostingSetup.FieldCaption("Account Type"), POSPostingSetup.TableCaption);
    end;

    local procedure GetPOSPostingProfile(var POSEntry: Record "NPR POS Entry"; var POSPostingProfile: Record "NPR POS Posting Profile")
    var
        POSStore: Record "NPR POS Store";
        POSEntry2: Record "NPR POS Entry";
    begin
        POSEntry2.Copy(POSEntry);
        if POSEntry2."POS Unit No." = '' then
            if not POSEntry2.FindFirst() then
                POSEntry2.Init();
        POSStore.GetProfile(POSEntry2."POS Store Code", POSPostingProfile);
    end;

    local procedure MarkPOSEntries(OptStatus: Option Posted,Error; POSPostingLogEntryNo: Integer; var POSEntry: Record "NPR POS Entry"; var POSEntryWithError: Record "NPR POS Entry")
    var
        ProceedWithUpdate: Boolean;
        POSPeriodRegister: Record "NPR POS Period Register";
    begin
        if POSEntry.FindSet then
            repeat
                if (POSEntry."Post Entry Status" in [POSEntry."Post Entry Status"::Unposted, POSEntry."Post Entry Status"::"Error while Posting"]) then begin
                    case OptStatus of
                        OptStatus::Posted:
                            begin
                                POSEntry.Validate("Post Entry Status", POSEntry."Post Entry Status"::Posted);
                            end;
                        OptStatus::Error:
                            begin
                                //if posting is done in compressed state per Register Period, we're updating all the entries as error
                                //if compressed by POS Entry or uncompressed, we're updating that specific pos entry as error
                                POSPeriodRegister.Get(POSEntry."POS Period Register No.");
                                POSEntryWithError.SetRange("Document No.", POSPeriodRegister."Document No.");
                                ProceedWithUpdate := not POSEntryWithError.IsEmpty;
                                if not ProceedWithUpdate then begin
                                    POSEntryWithError.SetRange("Document No.", POSEntry."Document No.");
                                    ProceedWithUpdate := not POSEntryWithError.IsEmpty;
                                end;
                                if ProceedWithUpdate then
                                    POSEntry.Validate("Post Entry Status", POSEntry."Post Entry Status"::"Error while Posting");
                            end;
                    end;
                    POSEntry."POS Posting Log Entry No." := POSPostingLogEntryNo;
                    POSEntry.Modify(true);
                end;
            until POSEntry.Next = 0;
    end;

    local procedure MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer: Record "NPR POS Posting Buffer"; AmountIn: Decimal; AmountInLCY: Decimal; PostingType: Enum "General Posting Type"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; BalancingAccountType: Enum "Gen. Journal Account Type"; BalancingAccountNo: Code[20]; VATAmountIn: Decimal; VATAmountInLCY: Decimal; var GenJournalLine: Record "Gen. Journal Line")
    var
        POSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        if POSPostingBuffer."POS Store Code" = '' then
            POSStore.Init()
        else
            POSStore.Get(POSPostingBuffer."POS Store Code");
        POSStore.GetProfile(POSPostingBuffer."POS Store Code", POSPostingProfile);

        MakeGenJournalLine(
          AccountType,
          AccountNo,
          BalancingAccountType,
          BalancingAccountNo,
          PostingType,
          POSPostingBuffer."Posting Date",
          POSPostingBuffer."Document No.",
          POSPostingBuffer.Description,
          POSPostingBuffer."VAT %",
          POSPostingBuffer."Currency Code",
          AmountIn,
          AmountInLCY,
          '',
          POSPostingBuffer."Gen. Bus. Posting Group",
          POSPostingBuffer."Gen. Prod. Posting Group",
          POSPostingBuffer."VAT Bus. Posting Group",
          POSPostingBuffer."VAT Prod. Posting Group",
          POSPostingBuffer."Global Dimension 1 Code",
          POSPostingBuffer."Global Dimension 2 Code",
          POSPostingBuffer."Dimension Set ID",
          POSPostingBuffer."Salesperson Code",
          POSPostingBuffer."Reason Code",
          POSPostingBuffer."External Document No.",
          POSPostingBuffer."Tax Area Code",
          POSPostingBuffer."Tax Liable",
          POSPostingBuffer."Tax Group Code",
          POSPostingBuffer."Use Tax",
          VATAmountIn,
          VATAmountInLCY,
          POSPostingProfile."VAT Customer No.",
          POSPostingProfile."Source Code",
          GenJournalLine);

        OnAfterInsertPOSPostingBufferToGenJnl(POSPostingBuffer, GenJournalLine, false);
    end;

    local procedure MakeGenJournalFromPOSBalancingLine(POSBalancingLine: Record "NPR POS Balancing Line"; Amount: Decimal; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; PostingDescription: Text; var GenJournalLine: Record "Gen. Journal Line")
    var
        POSEntry: Record "NPR POS Entry";
        POSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        POSEntry.Get(POSBalancingLine."POS Entry No.");
        POSStore.GetProfile(POSEntry."POS Store Code", POSPostingProfile);

        MakeGenJournalLine(
          AccountType,
          AccountNo,
          Enum::"Gen. Journal Account Type"::"G/L Account",
          '',
          Enum::"General Posting Type"::" ",
          POSEntry."Posting Date",
          POSBalancingLine."Document No.",
          PostingDescription,
          0,
          POSBalancingLine."Currency Code",
          Amount,
          0,
          '',
          '',
          '',
          '',
          '',
          POSBalancingLine."Shortcut Dimension 1 Code",
          POSBalancingLine."Shortcut Dimension 2 Code",
          POSBalancingLine."Dimension Set ID",
          '',
          '',
          '',
          '',
          false,
          '',
          false,
          0,
          0,
          '',
          POSPostingProfile."Source Code",
          GenJournalLine);

        OnAfterInsertPOSBalancingLineToGenJnl(POSBalancingLine, GenJournalLine, false);
    end;

    local procedure MakeGenJournalLine(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; BalancingAccountType: Enum "Gen. Journal Account Type"; BalancingAccountNo: Code[20]; GenPostingType: Enum "General Posting Type"; PostingDate: Date; DocumentNo: Code[20]; PostingDescription: Text; VATPerc: Decimal; PostingCurrencyCode: Code[10]; PostingAmount: Decimal; PostingAmountLCY: Decimal; PostingGroup: Code[20]; GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; ShortcutDim1: Code[20]; ShortcutDim2: Code[20]; DimSetID: Integer; SalespersonCode: Code[20]; ReasonCode: Code[10]; ExternalDocNo: Code[35]; TaxAreaCode: Code[20]; TaxLiable: Boolean; TaxGroupCode: Code[35]; Usetax: Boolean; VATAmount: Decimal; VATAmountLCY: Decimal; VATCustomerNo: Code[20]; SourceCode: Code[10]; var GenJournalLine: Record "Gen. Journal Line")
    begin
        LineNumber := LineNumber + 10000;
        GenJournalLine.Init;
        GenJournalLine."Journal Template Name" := '';
        GenJournalLine."Journal Batch Name" := '';
        GenJournalLine."Line No." := LineNumber;
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine."Account Type" := AccountType;
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer then
            if PostingAmount <= 0 then
                GenJournalLine."Document Type" := GenJournalLine."Document Type"::Payment
            else
                GenJournalLine."Document Type" := GenJournalLine."Document Type"::Refund;
        GenJournalLine."Account No." := AccountNo;
        GenJournalLine."Gen. Posting Type" := GenPostingType;
        GenJournalLine."Posting Date" := PostingDate;
        GenJournalLine."Document Date" := GenJournalLine."Posting Date";
        GenJournalLine."Document No." := DocumentNo;
        GenJournalLine."External Document No." := ExternalDocNo;
        GenJournalLine.Description := CopyStr(PostingDescription, 1, MaxStrLen(GenJournalLine.Description));
        if StrLen(PostingDescription) > MaxStrLen(GenJournalLine.Description) then
            GenJournalLine.Comment := CopyStr(PostingDescription, 1, MaxStrLen(GenJournalLine.Comment));

        GenJournalLine."Currency Code" := PostingCurrencyCode;
        if (PostingCurrencyCode <> '') then
            if (PostingAmountLCY <> 0) then
                GenJournalLine.Validate("Currency Factor", PostingAmount / PostingAmountLCY)
            else
                GenJournalLine.Validate("Currency Code");
        if PostingAmount <> 0 then
            GenJournalLine.Validate(Amount, PostingAmount);
        if PostingAmountLCY <> 0 then
            GenJournalLine.Validate("Amount (LCY)", PostingAmountLCY);
        GenJournalLine."Source Currency Code" := PostingCurrencyCode;
        GenJournalLine."Source Currency Amount" := PostingAmount;

        if GenPostingType in [GenJournalLine."Gen. Posting Type"::Sale, GenJournalLine."Gen. Posting Type"::Purchase] then begin
            if TaxAreaCode = '' then begin
                GenJournalLine."VAT %" := VATPerc;
                GenJournalLine."Source Curr. VAT Amount" := VATAmount;
                GenJournalLine."Source Curr. VAT Base Amount" := PostingAmount;
                GenJournalLine."Use Tax" := Usetax;
                GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
                GenJournalLine."VAT Amount" := VATAmount;
                GenJournalLine."VAT Amount (LCY)" := VATAmountLCY;
                GenJournalLine."Tax Area Code" := TaxAreaCode;
                GenJournalLine."Tax Liable" := TaxLiable;
                GenJournalLine."Tax Group Code" := TaxGroupCode;
                GenJournalLine."VAT Bus. Posting Group" := VATBusPostingGroup;
                GenJournalLine."VAT Prod. Posting Group" := VATProdPostingGroup;

                if GenPostingType = GenJournalLine."Gen. Posting Type"::Sale then
                    GenJournalLine."Bill-to/Pay-to No." := VATCustomerNo;

            end else
                GenJournalLine."VAT Calculation Type" := GenJournalLine."VAT Calculation Type"::"Sales Tax";
        end;

        GenJournalLine."Posting Group" := PostingGroup;
        GenJournalLine."Gen. Bus. Posting Group" := GenBusPostingGroup;
        GenJournalLine."Gen. Prod. Posting Group" := GenProdPostingGroup;
        GenJournalLine."Shortcut Dimension 1 Code" := ShortcutDim1;
        GenJournalLine."Shortcut Dimension 2 Code" := ShortcutDim2;
        GenJournalLine."Dimension Set ID" := DimSetID;
        GenJournalLine."Salespers./Purch. Code" := SalespersonCode;
        GenJournalLine."Reason Code" := ReasonCode;
        GenJournalLine."Source Code" := SourceCode;
        GenJournalLine.Insert;
    end;

    local procedure CreateGenJournalLinesFromSalesTax(var POSEntry: Record "NPR POS Entry"; var GenJnlLine: Record "Gen. Journal Line")
    var
        POSEntry2: Record "NPR POS Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        CurrExchRate: Record "Currency Exchange Rate";
        CustPostingGr: Record "Customer Posting Group";
        POSTaxAmountLine: Record "NPR POS Tax Amount Line";
        TempPOSTaxAmountLine: Record "NPR POS Tax Amount Line" temporary;
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSStore: Record "NPR POS Store";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        TaxLineCount: Integer;
        RemSalesTaxAmt: Decimal;
        RemSalesTaxSrcAmt: Decimal;
        RecRef: RecordRef;
        FldRef: FieldRef;
        IsNALocalized: Boolean;
    begin
        GLSetup.Get;
        RecRef.GetTable(GenJnlLine);
        IsNALocalized := RecRef.FieldExist(10011);

        if (TempPOSTaxAmountLine.IsTemporary()) then
            TempPOSTaxAmountLine.DeleteAll;

        POSEntry2.CopyFilters(POSEntry);
        POSEntry2.SetFilter("Post Entry Status", '=%1|=%2', POSEntry2."Post Entry Status"::Unposted, POSEntry2."Post Entry Status"::"Error while Posting");
        if POSEntry2.FindSet then
            repeat
                POSTaxAmountLine.SetFilter("POS Entry No.", '=%1', POSEntry2."Entry No.");
                POSTaxAmountLine.SetRange("Tax Calculation Type", TempPOSTaxAmountLine."Tax Calculation Type"::"Sales Tax");
                if POSTaxAmountLine.FindSet then
                    repeat
                        if IsNALocalized then begin
                            TempPOSTaxAmountLine := POSTaxAmountLine;
                            TempPOSTaxAmountLine.Insert;
                        end else begin
                            //IF Not in NA database, post as one line because of checks in Standard NAV
                            TempPOSTaxAmountLine.Reset;
                            TempPOSTaxAmountLine.SetRange("Tax Calculation Type", POSTaxAmountLine."Tax Calculation Type");
                            TempPOSTaxAmountLine.SetRange("Tax Area Code", POSTaxAmountLine."Tax Area Code");
                            TempPOSTaxAmountLine.SetRange("Tax Group Code", POSTaxAmountLine."Tax Group Code");
                            TempPOSTaxAmountLine.SetRange("Use Tax", POSTaxAmountLine."Use Tax");
                            TempPOSTaxAmountLine.SetRange("Tax Area Code for Key", POSTaxAmountLine."Tax Area Code for Key");
                            if not TempPOSTaxAmountLine.FindFirst then begin
                                TempPOSTaxAmountLine := POSTaxAmountLine;
                                TempPOSTaxAmountLine.Insert;
                            end else begin
                                TempPOSTaxAmountLine.Quantity := TempPOSTaxAmountLine.Quantity + POSTaxAmountLine.Quantity;
                                TempPOSTaxAmountLine."Calculated Tax Amount" := TempPOSTaxAmountLine."Calculated Tax Amount" + POSTaxAmountLine."Calculated Tax Amount";
                                TempPOSTaxAmountLine."Tax Difference" := TempPOSTaxAmountLine."Tax Difference" + POSTaxAmountLine."Tax Difference";
                                TempPOSTaxAmountLine."Invoice Discount Amount" := TempPOSTaxAmountLine."Invoice Discount Amount" + POSTaxAmountLine."Invoice Discount Amount";
                                TempPOSTaxAmountLine."Tax Amount" := TempPOSTaxAmountLine."Tax Amount" + POSTaxAmountLine."Tax Amount";
                                TempPOSTaxAmountLine."Amount Including Tax" := TempPOSTaxAmountLine."Amount Including Tax" + POSTaxAmountLine."Tax Amount";
                                TempPOSTaxAmountLine."Tax Base Amount FCY" := TempPOSTaxAmountLine."Tax Base Amount FCY" + POSTaxAmountLine."Tax Base Amount FCY";
                                TempPOSTaxAmountLine.Modify;
                            end;
                        end;
                    until POSTaxAmountLine.Next = 0;
                TempPOSTaxAmountLine.Reset;
            until (POSEntry2.Next() = 0);

        TempPOSTaxAmountLine.Reset;

        if POSEntry.FindFirst() then
            repeat
                POSStore.GetProfile(POSEntry."POS Store Code", POSPostingProfile);
                TaxLineCount := 0;
                RemSalesTaxAmt := 0;
                RemSalesTaxSrcAmt := 0;
                if POSEntry."Currency Code" <> '' then
                    Currency.Get(POSEntry."Currency Code")
                else
                    Currency.Init;
                TempPOSTaxAmountLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                TempPOSTaxAmountLine.SetRange("Tax Calculation Type", TempPOSTaxAmountLine."Tax Calculation Type"::"Sales Tax");
                if TempPOSTaxAmountLine.FindFirst then begin
                    repeat
                        LineNumber := LineNumber + 10000;
                        TaxLineCount := TaxLineCount + 1;
                        if ((TempPOSTaxAmountLine."Tax Base Amount" <> 0) and
                            (TempPOSTaxAmountLine."Tax Type" = TempPOSTaxAmountLine."Tax Type"::"Sales and Use Tax")) or
                           ((TempPOSTaxAmountLine.Quantity <> 0) and
                            (TempPOSTaxAmountLine."Tax Type" = TempPOSTaxAmountLine."Tax Type"::"Excise Tax"))
                        then begin
                            GenJnlLine.Init;
                            GenJnlLine."Posting Date" := POSEntry."Posting Date";
                            GenJnlLine."Document Date" := POSEntry."Document Date";
                            GenJnlLine.Description := CopyStr(POSEntry.Description, 1, MaxStrLen(GenJnlLine.Description));
                            GenJnlLine."Line No." := LineNumber;
                            GenJnlLine."Reason Code" := POSEntry."Reason Code";
                            GenJnlLine."Document No." := POSEntry."Document No.";
                            GenJnlLine."System-Created Entry" := true;
                            GenJnlLine.Amount := 0;
                            GenJnlLine."Source Currency Code" := POSEntry."Currency Code";
                            GenJnlLine."Source Currency Amount" := 0;
                            GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::Sale;
                            GenJnlLine."Tax Area Code" := TempPOSTaxAmountLine."Tax Area Code";
                            if IsNALocalized then begin
                                RecRef.GetTable(GenJnlLine);
                                FldRef := RecRef.Field(10011);
                                FldRef.Value := TempPOSTaxAmountLine."Tax Jurisdiction Code";
                                FldRef := RecRef.Field(10012);
                                FldRef.Value := TempPOSTaxAmountLine."Tax Type";
                                RecRef.SetTable(GenJnlLine);
                            end;
                            GenJnlLine."Tax Group Code" := TempPOSTaxAmountLine."Tax Group Code";
                            GenJnlLine."Tax Liable" := TempPOSTaxAmountLine."Tax Liable";
                            GenJnlLine.Quantity := TempPOSTaxAmountLine.Quantity;
                            GenJnlLine."VAT Calculation Type" := GenJnlLine."VAT Calculation Type"::"Sales Tax";
                            GenJnlLine."VAT Posting" := GenJnlLine."VAT Posting"::"Manual VAT Entry";
                            GenJnlLine."Shortcut Dimension 1 Code" := POSEntry."Shortcut Dimension 1 Code";
                            GenJnlLine."Shortcut Dimension 2 Code" := POSEntry."Shortcut Dimension 2 Code";
                            GenJnlLine."Dimension Set ID" := POSEntry."Dimension Set ID";
                            GenJnlLine."Source Code" := POSPostingProfile."Source Code";
                            GenJnlLine."Bill-to/Pay-to No." := POSEntry."Customer No.";
                            GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
                            GenJnlLine."Source No." := POSEntry."Customer No.";
                            //GenJnlLine."STE Transaction ID"  //Only in NA Version
                            GenJnlLine."Source Curr. VAT Base Amount" :=
                              CurrExchRate.ExchangeAmtLCYToFCY(
                                POSEntry."Posting Date", POSEntry."Currency Code", TempPOSTaxAmountLine."Tax Base Amount", POSEntry."Currency Factor");
                            GenJnlLine."VAT Base Amount (LCY)" :=
                              Round(TempPOSTaxAmountLine."Tax Base Amount");
                            GenJnlLine."VAT Base Amount" := GenJnlLine."VAT Base Amount (LCY)";

                            if TaxJurisdiction.Code <> TempPOSTaxAmountLine."Tax Jurisdiction Code" then begin
                                TaxJurisdiction.Get(TempPOSTaxAmountLine."Tax Jurisdiction Code");
                                RemSalesTaxAmt := 0;
                                RemSalesTaxSrcAmt := 0;
                            end;
                            if TaxJurisdiction."Unrealized VAT Type" > 0 then begin
                                TaxJurisdiction.TestField("Unreal. Tax Acc. (Sales)");
                                GenJnlLine."Account No." := TaxJurisdiction."Unreal. Tax Acc. (Sales)";
                            end else begin
                                TaxJurisdiction.TestField("Tax Account (Sales)");
                                GenJnlLine."Account No." := TaxJurisdiction."Tax Account (Sales)";
                            end;
                            if TempPOSTaxAmountLine."Tax Amount" <> 0 then begin
                                if IsNALocalized then
                                    RemSalesTaxSrcAmt := RemSalesTaxSrcAmt +
                                      TempPOSTaxAmountLine."Tax Base Amount FCY" * TempPOSTaxAmountLine."Tax %" / 100
                                else
                                    RemSalesTaxSrcAmt := TempPOSTaxAmountLine."Tax Amount";
                                GenJnlLine."Source Curr. VAT Amount" := Round(RemSalesTaxSrcAmt, Currency."Amount Rounding Precision");
                                RemSalesTaxSrcAmt := RemSalesTaxSrcAmt - GenJnlLine."Source Curr. VAT Amount";
                                RemSalesTaxAmt := RemSalesTaxAmt + TempPOSTaxAmountLine."Tax Amount";
                                GenJnlLine."VAT Amount (LCY)" := Round(RemSalesTaxAmt, GLSetup."Amount Rounding Precision");
                                RemSalesTaxAmt := RemSalesTaxAmt - GenJnlLine."VAT Amount (LCY)";
                                GenJnlLine."VAT Amount" := GenJnlLine."VAT Amount (LCY)";
                            end;
                            GenJnlLine."VAT Difference" := TempPOSTaxAmountLine."Tax Difference";
                            GenJnlLine."Source Curr. VAT Base Amount" := -GenJnlLine."Source Curr. VAT Base Amount";
                            GenJnlLine."VAT Base Amount (LCY)" := -GenJnlLine."VAT Base Amount (LCY)";
                            GenJnlLine."VAT Base Amount" := -GenJnlLine."VAT Base Amount";
                            GenJnlLine."Source Curr. VAT Amount" := -GenJnlLine."Source Curr. VAT Amount";
                            GenJnlLine."VAT Amount (LCY)" := -GenJnlLine."VAT Amount (LCY)";
                            GenJnlLine."VAT Amount" := -GenJnlLine."VAT Amount";
                            GenJnlLine.Quantity := -GenJnlLine.Quantity;
                            GenJnlLine."VAT Difference" := -GenJnlLine."VAT Difference";
                            GenJnlLine.Insert;
                        end;
                    until TempPOSTaxAmountLine.Next = 0;
                end;
            until POSEntry.Next = 0;
    end;

    local procedure PostSalesTaxToGL(var POSEntry: Record "NPR POS Entry")
    var
        TaxJurisdiction: Record "Tax Jurisdiction";
        CurrExchRate: Record "Currency Exchange Rate";
        CustPostingGr: Record "Customer Posting Group";
        POSTaxAmountLine: Record "NPR POS Tax Amount Line";
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSStore: Record "NPR POS Store";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        TaxLineCount: Integer;
        RemSalesTaxAmt: Decimal;
        RemSalesTaxSrcAmt: Decimal;
    begin
        POSStore.GetProfile(POSEntry."POS Store Code", POSPostingProfile);
        GLSetup.Get;
        TaxLineCount := 0;
        RemSalesTaxAmt := 0;
        RemSalesTaxSrcAmt := 0;
        if POSEntry."Currency Code" <> '' then
            Currency.Get(POSEntry."Currency Code")
        else
            Currency.Init;
        POSTaxAmountLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSTaxAmountLine.FindFirst then begin
            repeat
                TaxLineCount := TaxLineCount + 1;
                if ((POSTaxAmountLine."Tax Base Amount" <> 0) and
                    (POSTaxAmountLine."Tax Type" = POSTaxAmountLine."Tax Type"::"Sales and Use Tax")) or
                   ((POSTaxAmountLine.Quantity <> 0) and
                    (POSTaxAmountLine."Tax Type" = POSTaxAmountLine."Tax Type"::"Excise Tax"))
                then begin
                    TempGenJnlLine.Init;
                    TempGenJnlLine."Posting Date" := POSEntry."Posting Date";
                    TempGenJnlLine."Document Date" := POSEntry."Document Date";
                    TempGenJnlLine.Description := CopyStr(POSEntry.Description, 1, MaxStrLen(TempGenJnlLine.Description));
                    TempGenJnlLine."Reason Code" := POSEntry."Reason Code";
                    TempGenJnlLine."Document No." := POSEntry."Document No.";
                    TempGenJnlLine."System-Created Entry" := true;
                    TempGenJnlLine.Amount := 0;
                    TempGenJnlLine."Source Currency Code" := POSEntry."Currency Code";
                    TempGenJnlLine."Source Currency Amount" := 0;
                    TempGenJnlLine."Gen. Posting Type" := TempGenJnlLine."Gen. Posting Type"::Sale;
                    TempGenJnlLine."Tax Area Code" := POSTaxAmountLine."Tax Area Code";
                    //TempGenJnlLine."Tax Type" := POSTaxAmountLine."Tax Type"; //Only in NA Version
                    TempGenJnlLine."Tax Group Code" := POSTaxAmountLine."Tax Group Code";
                    TempGenJnlLine."Tax Liable" := POSTaxAmountLine."Tax Liable";
                    TempGenJnlLine.Quantity := POSTaxAmountLine.Quantity;
                    TempGenJnlLine."VAT Calculation Type" := TempGenJnlLine."VAT Calculation Type"::"Sales Tax";
                    TempGenJnlLine."VAT Posting" := TempGenJnlLine."VAT Posting"::"Manual VAT Entry";
                    TempGenJnlLine."Shortcut Dimension 1 Code" := POSEntry."Shortcut Dimension 1 Code";
                    TempGenJnlLine."Shortcut Dimension 2 Code" := POSEntry."Shortcut Dimension 2 Code";
                    TempGenJnlLine."Dimension Set ID" := POSEntry."Dimension Set ID";
                    TempGenJnlLine."Source Code" := POSPostingProfile."Source Code";
                    TempGenJnlLine."Bill-to/Pay-to No." := POSEntry."Customer No.";
                    TempGenJnlLine."Source Type" := TempGenJnlLine."Source Type"::Customer;
                    TempGenJnlLine."Source No." := POSEntry."Customer No.";
                    //TempGenJnlLine."STE Transaction ID"  //Only in NA Version
                    TempGenJnlLine."Source Curr. VAT Base Amount" :=
                      CurrExchRate.ExchangeAmtLCYToFCY(
                        POSEntry."Posting Date", POSEntry."Currency Code", POSTaxAmountLine."Tax Base Amount", POSEntry."Currency Factor");
                    TempGenJnlLine."VAT Base Amount (LCY)" :=
                      Round(POSTaxAmountLine."Tax Base Amount");
                    TempGenJnlLine."VAT Base Amount" := TempGenJnlLine."VAT Base Amount (LCY)";
                    if TaxJurisdiction.Code <> POSTaxAmountLine."Tax Jurisdiction Code" then begin
                        TaxJurisdiction.Get(POSTaxAmountLine."Tax Jurisdiction Code");
                        RemSalesTaxAmt := 0;
                        RemSalesTaxSrcAmt := 0;
                    end;
                    if TaxJurisdiction."Unrealized VAT Type" > 0 then begin
                        TaxJurisdiction.TestField("Unreal. Tax Acc. (Sales)");
                        TempGenJnlLine."Account No." := TaxJurisdiction."Unreal. Tax Acc. (Sales)";
                    end else begin
                        TaxJurisdiction.TestField("Tax Account (Sales)");
                        TempGenJnlLine."Account No." := TaxJurisdiction."Tax Account (Sales)";
                    end;
                    //TempGenJnlLine."Tax Jurisdiction Code" := TempSalesTaxAmtLine."Tax Jurisdiction Code"; //Only in NA Version
                    if POSTaxAmountLine."Tax Amount" <> 0 then begin
                        RemSalesTaxSrcAmt := RemSalesTaxSrcAmt +
                          POSTaxAmountLine."Tax Base Amount FCY" * POSTaxAmountLine."Tax %" / 100;
                        TempGenJnlLine."Source Curr. VAT Amount" := Round(RemSalesTaxSrcAmt, Currency."Amount Rounding Precision");
                        RemSalesTaxSrcAmt := RemSalesTaxSrcAmt - TempGenJnlLine."Source Curr. VAT Amount";
                        RemSalesTaxAmt := RemSalesTaxAmt + POSTaxAmountLine."Tax Amount";
                        TempGenJnlLine."VAT Amount (LCY)" := Round(RemSalesTaxAmt, GLSetup."Amount Rounding Precision");
                        RemSalesTaxAmt := RemSalesTaxAmt - TempGenJnlLine."VAT Amount (LCY)";
                        TempGenJnlLine."VAT Amount" := TempGenJnlLine."VAT Amount (LCY)";
                    end;
                    TempGenJnlLine."VAT Difference" := POSTaxAmountLine."Tax Difference";
                    TempGenJnlLine."Source Curr. VAT Base Amount" := -TempGenJnlLine."Source Curr. VAT Base Amount";
                    TempGenJnlLine."VAT Base Amount (LCY)" := -TempGenJnlLine."VAT Base Amount (LCY)";
                    TempGenJnlLine."VAT Base Amount" := -TempGenJnlLine."VAT Base Amount";
                    TempGenJnlLine."Source Curr. VAT Amount" := -TempGenJnlLine."Source Curr. VAT Amount";
                    TempGenJnlLine."VAT Amount (LCY)" := -TempGenJnlLine."VAT Amount (LCY)";
                    TempGenJnlLine."VAT Amount" := -TempGenJnlLine."VAT Amount";
                    TempGenJnlLine.Quantity := -TempGenJnlLine.Quantity;
                    TempGenJnlLine."VAT Difference" := -TempGenJnlLine."VAT Difference";
                    GenJnlPostLine.RunWithCheck(TempGenJnlLine);
                end;
            until POSTaxAmountLine.Next = 0;
        end;
    end;

    //[Obsolete('This function has been discontinued.', '16.0')]
    procedure Preview(var POSEntry: Record "NPR POS Entry")
    begin
        Error('This function has been discontinued.');
    end;

    //[Obsolete('This function has been discontinued.', '16.0')]
    procedure CompareToAuditRoll(var POSEntry: Record "NPR POS Entry")
    begin
        Error('This function has been discontinued.');
    end;

    local procedure SetAppliesToDocument(var GenJournalLine: Record "Gen. Journal Line"; var POSPostingBuffer: Record "NPR POS Posting Buffer")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if POSPostingBuffer."Applies-to Doc. No." = '' then
            exit;
        if POSPostingBuffer.Type <> POSPostingBuffer.Type::Customer then
            exit;
        if POSPostingBuffer."Applies-to Doc. No." = '' then
            exit;

        CustLedgerEntry.SetAutoCalcFields("Remaining Amount");
        CustLedgerEntry.SetRange("Customer No.", POSPostingBuffer."No.");
        CustLedgerEntry.SetRange("Document No.", POSPostingBuffer."Applies-to Doc. No.");
        CustLedgerEntry.SetRange("Document Type", POSPostingBuffer."Applies-to Doc. Type");
        CustLedgerEntry.SetRange(Open, true);
        if not CustLedgerEntry.FindFirst then
            exit;

        if CustLedgerEntry.Positive then begin
            if CustLedgerEntry."Remaining Amount" < -POSPostingBuffer.Amount then
                exit;
        end else begin
            if CustLedgerEntry."Remaining Amount" > -POSPostingBuffer.Amount then
                exit;
        end;

        GenJournalLine.Validate("Applies-to Doc. Type", POSPostingBuffer."Applies-to Doc. Type");
        GenJournalLine.Validate("Applies-to Doc. No.", POSPostingBuffer."Applies-to Doc. No.");
        GenJournalLine.Modify;
    end;

    local procedure CalculateDifferenceAmount(var GenJournalLine: Record "Gen. Journal Line") DifferenceAmount: Decimal
    begin
        if GenJournalLine.FindSet() then
            repeat
                DifferenceAmount := DifferenceAmount + GenJournalLine."Amount (LCY)" + GenJournalLine."VAT Amount (LCY)";
            until GenJournalLine.Next() = 0;
        exit(DifferenceAmount);
    end;
    //--- Subscribers ---


    //--- Events ---

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPOSEntry(var POSEntry: Record "NPR POS Entry"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPostingRestrictions(var POSEntry: Record "NPR POS Entry"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPOSEntry(var POSEntry: Record "NPR POS Entry"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSPostingBufferToGenJnl(var POSPostingBuffer: Record "NPR POS Posting Buffer"; var GenJournalLine: Record "Gen. Journal Line"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSBalancingLineToGenJnl(var POSBalancingLine: Record "NPR POS Balancing Line"; var GenJournalLine: Record "Gen. Journal Line"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPOSEntryBatch(var POSEntry: Record "NPR POS Entry"; PreviewMode: Boolean)
    begin
    end;

    local procedure CheckDimensions(var POSEntry: Record "NPR POS Entry")
    var
        POSEntry2: Record "NPR POS Entry";
        POSPostingControl: Codeunit "NPR POS Posting Control";
    begin
        POSEntry2.Copy(POSEntry);
        POSEntry2.FilterGroup(-1);
        POSEntry2.SetRange("Post Entry Status", POSEntry2."Post Entry Status"::Unposted, POSEntry2."Post Entry Status"::"Error while Posting");
        POSEntry2.SetRange("Post Item Entry Status", POSEntry2."Post Item Entry Status"::Unposted, POSEntry2."Post Item Entry Status"::"Error while Posting");
        POSEntry2.FilterGroup(0);
        if POSEntry2.FindSet then
            repeat
                POSPostingControl.CheckGlobalDimAndDimSetConsistency(POSEntry2.RecordId, POSEntry2."Shortcut Dimension 1 Code", POSEntry2."Shortcut Dimension 2 Code", POSEntry2."Dimension Set ID", 0);
            until POSEntry2.Next = 0;
    end;
}