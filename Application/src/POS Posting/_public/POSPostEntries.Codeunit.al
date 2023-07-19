﻿codeunit 6150615 "NPR POS Post Entries"
{
    TableNo = "NPR POS Entry";

    trigger OnRun()
    begin
        ShowProgressDialog := GuiAllowed;
        _LineNumber := 0;
        Code(Rec);
    end;

    var
        PostItemEntriesVar, PostPOSEntriesVar, PostCompressedVar, StopOnErrorVar, ShowProgressDialog, PostingDateExists, ReplacePostingDate, ReplaceDocumentDate : Boolean;
        _PostingDate: Date;
        TextErrorMultiple: Label '%3 %1 and %2 cannot be posted together. Only one %3 can be posted at a time.';
        TextErrorSalesTaxCompressed: Label '%1 %2 cannot be posted compressed because it has Sales Tax Lines. Please check the POS posting compression settings.';
        TextErrorBufferLinesnotmade: Label '%1 were not created from Sales and Payment Lines.';
        TextErrorGJLinesnotmade: Label '%1 were not be created from buffer.';
        TextUnknownError: Label 'Unknown Error.';
        PostingDescriptionLbl: Label '%1: %2';
        _LineNumber: Integer;
        TextPaymentDescription: Label '%1 Payments on %2';
        ProgressWindow: Dialog;
        TextNothingToPost: Label 'Nothing to Post.';
        TextAccountTypeNotSupported: Label 'Field %1 contains an unsupported type in table %2.';
        TextImbalance: Label 'Cannot post the lines. %1 %2 on %3 %4 has an imbalance of %5. ';
        PostingPOSEntriesLbl: Label 'Posting POS Entries    #1##########\\';
        CreatingBufferLinesLbl: Label 'Creating Buffer Lines         #2###### @3@@@@@@@@@@@@@\';
        PreparingGenJournalLinesLbl: Label 'Preparing Gen. Journal Lines       #4###### @5@@@@@@@@@@@@@\';
        PostingGenJournalLinesLbl: Label 'Posting Gen Journal lines         #8###### @9@@@@@@@@@@@@@\';
        PostingItemLinesLbl: Label 'Posting Item Lines         #10###### @11@@@@@@@@@@@@@\';
        _POSPostingLogEntryNo, POSItemPostingLogEntryNo : Integer;
        PostingPerPeriodRegister, JobQueuePosting : Boolean;
        ErrorText: Text;
        PostingPOSEntriesOpenDialogLbl: Label 'Posting POS Entries individually\#1######\@2@@@@@@@@@@@@@\';
        TextPostingSetupMissing: Label '%1 is missing for %2 in %3 %4.\\Values [%5].';
        TextClosingEntryFloat: Label 'Float Amount Closing POS Entry %1';
        TextPostingDifference: Label 'POS Posting Difference';
        _GLPostingErrorEntries: List of [Integer];
        _ItemPostingErrorEntries: List of [Integer];
        IsSalesTaxEnabled: Boolean;

    local procedure "Code"(var POSEntry: Record "NPR POS Entry")
    var
    begin

        if ((not PostItemEntriesVar) and (not PostPOSEntriesVar)) or POSEntry.IsEmpty then
            Error(TextNothingToPost);

        if ShowProgressDialog then begin
            if PostItemEntriesVar and PostPOSEntriesVar then
                ProgressWindow.Open(PostingItemLinesLbl + PostingPOSEntriesLbl + CreatingBufferLinesLbl + PreparingGenJournalLinesLbl + PostingGenJournalLinesLbl)
            else
                if PostItemEntriesVar then
                    ProgressWindow.Open(PostingItemLinesLbl + PostingPOSEntriesLbl)
                else
                    if PostPOSEntriesVar then
                        ProgressWindow.Open(PostingPOSEntriesLbl + CreatingBufferLinesLbl + PreparingGenJournalLinesLbl + PostingGenJournalLinesLbl);
        end;

        CheckDimensions(POSEntry);

        if PostItemEntriesVar then begin
            //Item entries are posted first and committed after each POS Entry is posted
            PostItemEntries(POSEntry);
        end;

        if PostPOSEntriesVar then begin
            //POS Entries must belong to the same POS Ledger Register Entry
            _POSPostingLogEntryNo := CreatePOSPostingLogEntry(POSEntry, 0);
            Commit();
            Clear(_GLPostingErrorEntries);
            PostPOSEntries(POSEntry);
        end;

        if POSEntry.FindSet(true) then
            repeat
                OnAfterPostPOSEntry(POSEntry, false);
            until POSEntry.Next() = 0;

        OnAfterPostPOSEntryBatch(POSEntry, false);

        if ShowProgressDialog then
            ProgressWindow.Close();
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure PostPOSEntries(var POSEntry: Record "NPR POS Entry")
    var
        TempPOSPostingBuffer: Record "NPR POS Posting Buffer" temporary;
        TempPOSSalesLineToPost: Record "NPR POS Entry Sales Line" temporary;
        TempPOSPaymentLinetoPost: Record "NPR POS Entry Payment Line" temporary;
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        TempPOSEntry: Record "NPR POS Entry" temporary;
        POSSalesTax: codeunit "NPR POS Sales Tax";
    begin
        CreateTempRecordsToPost(POSEntry, TempPOSSalesLineToPost, TempPOSPaymentLinetoPost);
        IsSalesTaxEnabled := POSSalesTax.NALocalizationEnabled() or POSSalesTax.SalesTaxEnabled(POSEntry."Entry No.");
        if not IsSalesTaxEnabled then
            CreatePostingBufferLinesFromPOSSalesLines(TempPOSSalesLineToPost, TempPOSPostingBuffer)
        else
            POSSalesTax.CreatePostingBufferLinesFromPOSSalesLines(TempPOSSalesLineToPost, TempPOSPostingBuffer, POSEntry);

        CreatePostingBufferLinesFromPOSSPaymentLines(TempPOSPaymentLinetoPost, TempPOSPostingBuffer);

        if ((not TempPOSPaymentLinetoPost.IsEmpty) or (not TempPOSSalesLineToPost.IsEmpty)) and (TempPOSPostingBuffer.IsEmpty) then
            Error(TextErrorBufferLinesnotmade, TempPOSPostingBuffer.TableCaption);

        CreateGenJnlLinesFromPOSPostingBuffer(TempPOSPostingBuffer, TempGenJournalLine);

        if IsSalesTaxEnabled then
            POSSalesTax.CreateGenJournalLinesFromSalesTax(TempPOSPostingBuffer, TempGenJournalLine, POSEntry, _LineNumber);

        if (not TempPOSPostingBuffer.IsEmpty) and (TempGenJournalLine.IsEmpty) then
            Error(TextErrorGJLinesnotmade, TempGenJournalLine.TableCaption);

        CreateGenJnlLinesFromPOSBalancingLines(POSEntry, TempGenJournalLine);

        if (not CheckAndPostGenJournal(TempGenJournalLine, POSEntry, TempPOSEntry)) then begin
            UpdatePOSPostingLogEntry(_POSPostingLogEntryNo, false);
            MarkPOSEntries(1, _POSPostingLogEntryNo, POSEntry, TempPOSEntry);
        end else begin
            UpdatePOSPostingLogEntry(_POSPostingLogEntryNo, false);
            MarkPOSEntries(0, _POSPostingLogEntryNo, POSEntry, TempPOSEntry);
        end;
    end;

    internal procedure PostRangePerPOSEntry(var POSEntry: Record "NPR POS Entry")
    var
        POSEntry2: Record "NPR POS Entry";
        PerEntryDialog: Dialog;
        NoOfRecords: Integer;
        LineCount: Integer;
    begin
        ShowProgressDialog := false;
        if GuiAllowed() then begin
            PerEntryDialog.Open(PostingPOSEntriesOpenDialogLbl);
            NoOfRecords := POSEntry.Count();
        end;
        if POSEntry.FindSet() then
            repeat
                if GuiAllowed() then begin
                    LineCount := LineCount + 1;
                    PerEntryDialog.Update(1, POSEntry."Entry No.");
                    PerEntryDialog.Update(2, Round(LineCount / NoOfRecords * 10000, 1));
                end;
                POSEntry2.SetRange("Entry No.", POSEntry."Entry No.");
                Code(POSEntry2);
                Commit();
            until POSEntry.Next() = 0;
        if GuiAllowed() then
            PerEntryDialog.Close();
    end;

    internal procedure PostFromPOSPostingLog(var POSPostingLog: Record "NPR POS Posting Log")
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
        SetPostPerPeriodRegister(POSPostingLog."Posting Per" = POSPostingLog."Posting Per"::"POS Period Register");
        SetStopOnError(true);
        Code(POSEntry);
    end;

    local procedure CreateTempRecordsToPost(var POSEntry: Record "NPR POS Entry"; var POSSalesLineToPost: Record "NPR POS Entry Sales Line" temporary; var POSPaymentLineToPost: Record "NPR POS Entry Payment Line" temporary)
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
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
            NoOfRecords := POSEntry.Count();
            ProgressWindow.Update(2, NoOfRecords);
        end;

        if POSEntry.FindSet(true) then
            repeat
                if ShowProgressDialog then begin
                    LineCount := LineCount + 1;
                    ProgressWindow.Update(3, Round(LineCount / NoOfRecords * 10000, 1));
                end;
                if (POSEntry."Post Entry Status" in [POSEntry."Post Entry Status"::Unposted, POSEntry."Post Entry Status"::"Error while Posting"]) then begin
                    OnCheckPostingRestrictions(POSEntry, false);
                    OnBeforePostPOSEntry(POSEntry, false);

                    POSEntry.Recalculate();

                    if (POSEntry."POS Period Register No." <> PreviousPOSPeriodRegister) and (PreviousPOSPeriodRegister <> 0) then
                        Error(TextErrorMultiple, POSEntry."POS Period Register No.", PreviousPOSPeriodRegister, POSPeriodRegister.TableCaption);
                    if PostingDateExists then begin
                        if ReplacePostingDate or (POSEntry."Posting Date" = 0D) then begin
                            POSEntry."Posting Date" := _PostingDate;
                            POSEntry.Validate("Currency Code");
                        end;
                        if ReplaceDocumentDate or (POSEntry."Document Date" = 0D) then begin
                            POSEntry.Validate("Document Date", _PostingDate);
                        end;
                    end;

                    POSSalesLine.Reset();
                    POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                    POSSalesLine.SetRange("Exclude from Posting", false);
                    if POSSalesLine.FindSet() then
                        repeat
                            POSSalesLineToPost := POSSalesLine;
                            POSSalesLineToPost.Insert();
                        until POSSalesLine.Next() = 0;

                    POSPaymentLine.Reset();
                    POSPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                    if POSPaymentLine.FindSet() then
                        repeat
                            POSPaymentLineToPost := POSPaymentLine;
                            POSPaymentLineToPost.Insert();
                        until POSPaymentLine.Next() = 0;

                    PreviousPOSPeriodRegister := POSEntry."POS Period Register No.";
                end;
            until POSEntry.Next() = 0;
    end;

    local procedure CreateGenJnlLinesFromPOSPostingBuffer(var POSPostingBuffer: Record "NPR POS Posting Buffer"; var GenJournalLine: Record "Gen. Journal Line")
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        POSPostingSetup: Record "NPR POS Posting Setup";
        Currency: Record Currency;
        POSPaymentMethod: Record "NPR POS Payment Method";
        LineCount: Integer;
        NoOfRecords: Integer;
        GenPostingType: Enum "General Posting Type";
    begin
        SalesReceivablesSetup.Get();
        if ShowProgressDialog then begin
            NoOfRecords := POSPostingBuffer.Count();
            ProgressWindow.Update(4, NoOfRecords);
        end;
        GenJournalLine.SetSuppressCommit(true);

        if POSPostingBuffer.FindSet() then
            repeat
                if ShowProgressDialog then begin
                    LineCount := LineCount + 1;
                    ProgressWindow.Update(5, Round(LineCount / NoOfRecords * 10000, 1));
                end;
                if POSPostingBuffer."Currency Code" <> '' then
                    Currency.Get(POSPostingBuffer."Currency Code")
                else
                    Currency.Init();
                case POSPostingBuffer."Line Type" of
                    POSPostingBuffer."Line Type"::Sales:
                        begin
                            case POSPostingBuffer.Type of
                                POSPostingBuffer.Type::Item:
                                    begin
                                        GeneralPostingSetup.Get(POSPostingBuffer."Gen. Bus. Posting Group", POSPostingBuffer."Gen. Prod. Posting Group");
                                        GeneralPostingSetup.TestField("Sales Account");
                                        case SalesReceivablesSetup."Discount Posting" of
                                            SalesReceivablesSetup."Discount Posting"::"Line Discounts",
                                            SalesReceivablesSetup."Discount Posting"::"All Discounts":
                                                begin
                                                    MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                                      Round(POSPostingBuffer.Amount + POSPostingBuffer."Discount Amount", Currency."Amount Rounding Precision"),
                                                      Round(POSPostingBuffer."Amount (LCY)" + POSPostingBuffer."Discount Amount (LCY)", Currency."Amount Rounding Precision"),
                                                      GenJournalLine."Gen. Posting Type"::Sale,
                                                      GenJournalLine."Account Type"::"G/L Account",
                                                      GeneralPostingSetup."Sales Account",
                                                      Round(POSPostingBuffer."VAT Amount" + POSPostingBuffer."VAT Amount Discount", Currency."Amount Rounding Precision"),
                                                      Round(POSPostingBuffer."VAT Amount (LCY)" + POSPostingBuffer."VAT Amount Discount (LCY)", Currency."Amount Rounding Precision"),
                                                      GenJournalLine);

                                                    if (POSPostingBuffer."Discount Amount" <> 0) or (POSPostingBuffer."Discount Amount (LCY)" <> 0) then begin
                                                        GeneralPostingSetup.TestField("Sales Line Disc. Account");
                                                        MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                                          Round(-POSPostingBuffer."Discount Amount", Currency."Amount Rounding Precision"),
                                                          Round(-POSPostingBuffer."Discount Amount (LCY)", Currency."Amount Rounding Precision"),
                                                          GenJournalLine."Gen. Posting Type"::Sale,
                                                          GenJournalLine."Account Type"::"G/L Account",
                                                          GeneralPostingSetup."Sales Line Disc. Account",
                                                          Round(-POSPostingBuffer."VAT Amount Discount", Currency."Amount Rounding Precision"),
                                                          Round(-POSPostingBuffer."VAT Amount Discount (LCY)", Currency."Amount Rounding Precision"),
                                                          GenJournalLine);
                                                    end;
                                                end;
                                            else begin
                                                MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                                   POSPostingBuffer.Amount,
                                                   POSPostingBuffer."Amount (LCY)",
                                                   GenJournalLine."Gen. Posting Type"::Sale,
                                                   GenJournalLine."Account Type"::"G/L Account",
                                                   GeneralPostingSetup."Sales Account",
                                                   POSPostingBuffer."VAT Amount",
                                                   POSPostingBuffer."VAT Amount (LCY)",
                                                   GenJournalLine);
                                            end;
                                        end;
                                    end;
                                POSPostingBuffer.Type::"G/L Account":
                                    begin
                                        if POSPostingBuffer."Rounding Amount (LCY)" <> 0 then begin
                                            GenPostingType := GenJournalLine."Gen. Posting Type"::" ";
                                            MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                                POSPostingBuffer."Rounding Amount",
                                                POSPostingBuffer."Rounding Amount (LCY)",
                                                GenPostingType,
                                                GenJournalLine."Account Type"::"G/L Account",
                                                POSPostingBuffer."No.",
                                                POSPostingBuffer."VAT Amount",
                                                POSPostingBuffer."VAT Amount (LCY)",
                                                GenJournalLine);
                                        end else begin
                                            MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                                POSPostingBuffer.Amount,
                                                POSPostingBuffer."Amount (LCY)",
                                                GenJournalLine."Gen. Posting Type"::Sale,
                                                GenJournalLine."Account Type"::"G/L Account",
                                                POSPostingBuffer."No.",
                                                POSPostingBuffer."VAT Amount",
                                                POSPostingBuffer."VAT Amount (LCY)",
                                                GenJournalLine);
                                        end;
                                    end;
                                POSPostingBuffer.Type::Voucher:
                                    begin
                                        if POSPostingBuffer."Rounding Amount (LCY)" <> 0 then begin
                                            GenPostingType := GenJournalLine."Gen. Posting Type"::" ";
                                            MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                                POSPostingBuffer."Rounding Amount",
                                                POSPostingBuffer."Rounding Amount (LCY)",
                                                GenPostingType,
                                                GenJournalLine."Account Type"::"G/L Account",
                                                POSPostingBuffer."No.",
                                                POSPostingBuffer."VAT Amount",
                                                POSPostingBuffer."VAT Amount (LCY)",
                                                GenJournalLine);
                                        end else begin
                                            GeneralPostingSetup.Get(POSPostingBuffer."Gen. Bus. Posting Group", POSPostingBuffer."Gen. Prod. Posting Group");
                                            GeneralPostingSetup.TestField("Sales Account");
                                            case SalesReceivablesSetup."Discount Posting" of
                                                SalesReceivablesSetup."Discount Posting"::"Line Discounts",
                                                SalesReceivablesSetup."Discount Posting"::"All Discounts":
                                                    begin
                                                        MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                                            Round(POSPostingBuffer.Amount + POSPostingBuffer."Discount Amount", Currency."Amount Rounding Precision"),
                                                            Round(POSPostingBuffer."Amount (LCY)" + POSPostingBuffer."Discount Amount (LCY)", Currency."Amount Rounding Precision"),
                                                            GenJournalLine."Gen. Posting Type"::Sale,
                                                            GenJournalLine."Account Type"::"G/L Account",
                                                            POSPostingBuffer."No.",
                                                            Round(POSPostingBuffer."VAT Amount" + POSPostingBuffer."VAT Amount Discount", Currency."Amount Rounding Precision"),
                                                            Round(POSPostingBuffer."VAT Amount (LCY)" + POSPostingBuffer."VAT Amount Discount (LCY)", Currency."Amount Rounding Precision"),
                                                            GenJournalLine);

                                                        if (POSPostingBuffer."Discount Amount" <> 0) or (POSPostingBuffer."Discount Amount (LCY)" <> 0) then begin
                                                            GeneralPostingSetup.TestField("Sales Line Disc. Account");
                                                            MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                                              Round(-POSPostingBuffer."Discount Amount", Currency."Amount Rounding Precision"),
                                                              Round(-POSPostingBuffer."Discount Amount (LCY)", Currency."Amount Rounding Precision"),
                                                              GenJournalLine."Gen. Posting Type"::Sale,
                                                              GenJournalLine."Account Type"::"G/L Account",
                                                              GeneralPostingSetup."Sales Line Disc. Account",
                                                              Round(-POSPostingBuffer."VAT Amount Discount", Currency."Amount Rounding Precision"),
                                                              Round(-POSPostingBuffer."VAT Amount Discount (LCY)", Currency."Amount Rounding Precision"),
                                                              GenJournalLine);
                                                        end;
                                                    end;
                                                else begin
                                                    MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                                        POSPostingBuffer.Amount,
                                                        POSPostingBuffer."Amount (LCY)",
                                                        GenJournalLine."Gen. Posting Type"::Sale,
                                                        GenJournalLine."Account Type"::"G/L Account",
                                                        POSPostingBuffer."No.",
                                                        POSPostingBuffer."VAT Amount",
                                                        POSPostingBuffer."VAT Amount (LCY)",
                                                        GenJournalLine);
                                                end;
                                            end
                                        end;
                                    end;
                                POSPostingBuffer.Type::Customer:
                                    begin
                                        MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                            POSPostingBuffer.Amount,
                                            POSPostingBuffer."Amount (LCY)",
                                            GenJournalLine."Gen. Posting Type"::" ",
                                            GenJournalLine."Account Type"::Customer,
                                            POSPostingBuffer."No.",
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
                              POSPostingBuffer."VAT Amount",
                              POSPostingBuffer."VAT Amount (LCY)",
                              GenJournalLine);
                            if POSPostingBuffer."Applies-to Doc. No." <> '' then begin
                                GenJournalLine.Validate("Applies-to Doc. Type", POSPostingBuffer."Applies-to Doc. Type");
                                GenJournalLine.Validate("Applies-to Doc. No.", POSPostingBuffer."Applies-to Doc. No.");
                                GenJournalLine.Modify();
                            end;
                            if POSPostingBuffer."Rounding Amount (LCY)" > 0 then begin
                                POSPaymentMethod.Get(POSPostingBuffer."POS Payment Method Code");
                                POSPaymentMethod.TestField("Rounding Gains Account");
                                MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                                  POSPostingBuffer."Rounding Amount",
                                  POSPostingBuffer."Rounding Amount (LCY)",
                                  GenJournalLine."Gen. Posting Type"::" ",
                                  GenJournalLine."Account Type"::"G/L Account",
                                  POSPaymentMethod."Rounding Gains Account",
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
                                  POSPostingBuffer."VAT Amount",
                                  POSPostingBuffer."VAT Amount (LCY)",
                                  GenJournalLine);
                            end;
                        end;
                end;
            until POSPostingBuffer.Next() = 0;
    end;

    local procedure CreateGenJnlLinesFromPOSBalancingLines(var POSEntryIn: Record "NPR POS Entry"; var GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        POSBalancingLine: Record "NPR POS Balancing Line";
        POSPostingSetup: Record "NPR POS Posting Setup";
        POSPostingSetupNewBin: Record "NPR POS Posting Setup";
        POSBin: Record "NPR POS Payment Bin";
        AmountToPostToAccount: Decimal;
        TotalLineAmountLCY: Decimal;
        PostingSetupNotFoundLbl: Label '%1: %4, %2: %5, %3: %6', Locked = true;
        SuppressPosting: Boolean;
    begin
        POSEntry.Copy(POSEntryIn);
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::Balancing);
        POSEntry.SetFilter(POSEntry."Post Entry Status", '<2');

        if POSEntry.FindSet() then
            repeat
                POSBalancingLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                if POSBalancingLine.FindSet() then
                    repeat

                        SuppressPosting := false;
                        if (POSBin.Get(POSBalancingLine."Deposit-To Bin Code")) then
                            if (POSBin."Bin Type" = POSBin."Bin Type"::VIRTUAL) then
                                SuppressPosting := POSBin."Suppress EOD Posting";

                        if (not SuppressPosting) then begin

                            TotalLineAmountLCY := 0;
                            GetPostingSetupFromBalancingLine(POSBalancingLine, POSPostingSetup);
                            POSPostingSetup.TestField("Account No.");
                            AmountToPostToAccount := 0;
                            if POSBalancingLine."Balanced Diff. Amount" > 0 then begin
                                POSPostingSetup.TestField("Difference Acc. No.");
                                TotalLineAmountLCY += MakeGenJournalFromPOSBalancingLineWithVatOption(
                                        POSEntry, POSBalancingLine, GetDifferenceAccountType(POSPostingSetup), POSPostingSetup."Difference Acc. No.",
                                        POSBalancingLine."Balanced Diff. Amount", POSBalancingLine.Description, GenJournalLine);

                                OnAfterMakeGenJournalForBalancedDifference(POSBalancingLine, GenJournalLine);
                            end;
                            if POSBalancingLine."Balanced Diff. Amount" < 0 then begin
                                POSPostingSetup.TestField("Difference Acc. No. (Neg)");
                                TotalLineAmountLCY += MakeGenJournalFromPOSBalancingLineWithVatOption(
                                        POSEntry, POSBalancingLine, GetDifferenceAccountType(POSPostingSetup), POSPostingSetup."Difference Acc. No. (Neg)",
                                        POSBalancingLine."Balanced Diff. Amount", POSBalancingLine.Description, GenJournalLine);

                                OnAfterMakeGenJournalForBalancedDifference(POSBalancingLine, GenJournalLine);
                            end;

                            AmountToPostToAccount := -POSBalancingLine."Balanced Diff. Amount";
                            if (POSBalancingLine."Move-To Bin Amount" <> 0) then begin
                                POSBalancingLine.TestField("Move-To Bin Code");
                                if not GetPostingSetup(POSBalancingLine."POS Store Code", POSBalancingLine."POS Payment Method Code", POSBalancingLine."Move-To Bin Code", POSPostingSetupNewBin) then
                                    Error(TextPostingSetupMissing, POSPostingSetup.TableCaption, POSBalancingLine.TableCaption, POSBalancingLine.FieldCaption("POS Entry No."), POSBalancingLine."POS Entry No.",
                                        StrSubstNo(PostingSetupNotFoundLbl, POSBalancingLine.FieldCaption("POS Store Code"), POSBalancingLine.FieldCaption("POS Payment Method Code"), POSBalancingLine.FieldCaption("Move-To Bin Code"),
                                        POSBalancingLine."POS Store Code", POSBalancingLine."POS Payment Method Code", POSBalancingLine."Move-To Bin Code"));

                                AmountToPostToAccount := AmountToPostToAccount - POSBalancingLine."Move-To Bin Amount";
                                POSPostingSetupNewBin.TestField("Account No.");
                                TotalLineAmountLCY += MakeGenJournalFromPOSBalancingLineWithVatOption(
                                    POSEntry, POSBalancingLine, GetGLAccountType(POSPostingSetupNewBin), POSPostingSetupNewBin."Account No.",
                                    POSBalancingLine."Move-To Bin Amount", POSBalancingLine."Move-To Reference", GenJournalLine);

                                OnAfterMakeGenJournalForMoveToBin(POSBalancingLine, GenJournalLine);
                            end;

                            if (POSBalancingLine."Deposit-To Bin Amount" <> 0) then begin
                                POSBalancingLine.TestField("Deposit-To Bin Code");
                                if not GetPostingSetup(POSBalancingLine."POS Store Code", POSBalancingLine."POS Payment Method Code", POSBalancingLine."Deposit-To Bin Code", POSPostingSetupNewBin) then
                                    Error(TextPostingSetupMissing, POSPostingSetup.TableCaption, POSBalancingLine.TableCaption, POSBalancingLine.FieldCaption("POS Entry No."), POSBalancingLine."POS Entry No.",
                                        StrSubstNo(PostingSetupNotFoundLbl, POSBalancingLine.FieldCaption("POS Store Code"), POSBalancingLine.FieldCaption("POS Payment Method Code"), POSBalancingLine.FieldCaption("Deposit-To Bin Code"),
                                        POSBalancingLine."POS Store Code", POSBalancingLine."POS Payment Method Code", POSBalancingLine."Deposit-To Bin Code"));

                                AmountToPostToAccount := AmountToPostToAccount - POSBalancingLine."Deposit-To Bin Amount";
                                POSPostingSetupNewBin.TestField("Account No.");
                                TotalLineAmountLCY += MakeGenJournalFromPOSBalancingLineWithVatOption(
                                    POSEntry, POSBalancingLine, GetGLAccountType(POSPostingSetupNewBin), POSPostingSetupNewBin."Account No.",
                                    POSBalancingLine."Deposit-To Bin Amount", POSBalancingLine."Deposit-To Reference", GenJournalLine);

                                OnAfterMakeGenJournalForDepositToBin(POSBalancingLine, GenJournalLine);
                            end;

                            if POSBalancingLine."New Float Amount" <> 0 then begin
                                TotalLineAmountLCY += MakeGenJournalFromPOSBalancingLineWithVatOption(
                                            POSEntry, POSBalancingLine, GetGLAccountType(POSPostingSetup), POSPostingSetup."Account No.",
                                            POSBalancingLine."New Float Amount", StrSubstNo(TextClosingEntryFloat, POSEntry."Entry No."), GenJournalLine);

                                OnAfterMakeGenJournalForNewFloatAmount(POSBalancingLine, GenJournalLine);
                            end;

                            AmountToPostToAccount := AmountToPostToAccount - POSBalancingLine."New Float Amount";
                            if AmountToPostToAccount <> 0 then begin
                                TotalLineAmountLCY += MakeGenJournalFromPOSBalancingLineWithVatOption(
                                                POSEntry, POSBalancingLine, GetGLAccountType(POSPostingSetup), POSPostingSetup."Account No.",
                                                AmountToPostToAccount, POSBalancingLine.Description, GenJournalLine);

                                OnAfterMakeGenJournalForTotalAmount(POSBalancingLine, GenJournalLine);
                            end;

                            // For transaction in currency there can be rounding residue, find the difference account to post to. 
                            // This set of general journal lines need to balance in currency and LCY and rounding error is max 0.01 for each set of +/- entries. With 5 lines, max 0.01 per set => 0.02 should suffice.
                            if ((POSBalancingLine."Currency Code" <> '') and (TotalLineAmountLCY <> 0) and (Abs(TotalLineAmountLCY) <= 0.05)) then begin
                                if (-TotalLineAmountLCY > 0) then begin
                                    POSPostingSetup.TestField("Difference Acc. No.");
                                    MakeGenJournalFromPOSBalancingLineWithVatOption(
                                            POSEntry, POSBalancingLine, GetDifferenceAccountType(POSPostingSetup), POSPostingSetup."Difference Acc. No.",
                                            -TotalLineAmountLCY, POSBalancingLine.Description, GenJournalLine);

                                    OnAfterMakeGenJournalForBalancedDifference(POSBalancingLine, GenJournalLine);
                                end;
                                if (-TotalLineAmountLCY < 0) then begin
                                    POSPostingSetup.TestField("Difference Acc. No. (Neg)");
                                    MakeGenJournalFromPOSBalancingLineWithVatOption(
                                            POSEntry, POSBalancingLine, GetDifferenceAccountType(POSPostingSetup), POSPostingSetup."Difference Acc. No. (Neg)",
                                            -TotalLineAmountLCY, POSBalancingLine.Description, GenJournalLine);

                                    OnAfterMakeGenJournalForBalancedDifference(POSBalancingLine, GenJournalLine);
                                end;
                            end;
                        end;

                    until POSBalancingLine.Next() = 0;
            until POSEntry.Next() = 0;
    end;

    local procedure PostItemEntries(var POSEntry: Record "NPR POS Entry")
    var
        POSEntryToPost: Record "NPR POS Entry";
        POSPostItemEntries: Codeunit "NPR POS Post Item Entries";
        POSPostItemTransaction: Codeunit "NPR POS Post Item Transaction";
        LineCount, LineToProcessCount : Integer;
        NoOfRecords: Integer;
        ItemPostingErrorMsg: Label '%1 error/s occurred. Successfully processed %2.', Comment = '%1-Errors count, %2-Successfully posted count';
        DoSkipProcessing: Boolean;
    begin

        if ShowProgressDialog then begin
            NoOfRecords := POSEntry.Count();
            ProgressWindow.Update(10, NoOfRecords);
        end;

        Clear(_ItemPostingErrorEntries);
        POSItemPostingLogEntryNo := CreatePOSPostingLogEntry(POSEntry, 1);
        Commit();

        if POSEntry.FindSet() then
            repeat
                if ShowProgressDialog then begin
                    LineCount := LineCount + 1;
                    ProgressWindow.Update(11, Round(LineCount / NoOfRecords * 10000, 1));
                end;
                if (POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::Unposted, POSEntry."Post Item Entry Status"::"Error while Posting"]) then begin
                    DoSkipProcessing := JobQueuePosting;
                    if JobQueuePosting then
                        DoSkipProcessing := SkipProcessing(2, POSEntry."Entry No.", 1);
                    if not DoSkipProcessing then begin
                        if PostingDateExists then
                            POSPostItemEntries.SetPostingDate(ReplaceDocumentDate, ReplaceDocumentDate, _PostingDate);

                        POSEntryToPost.Get(POSEntry."Entry No.");
                        LineToProcessCount += 1;
                        if StopOnErrorVar then begin
                            POSPostItemTransaction.Run(POSEntryToPost);
                        end else begin
                            if (not POSPostItemTransaction.Run(POSEntryToPost)) then begin
                                _ItemPostingErrorEntries.Add(POSEntryToPost."Entry No.");
                                CreateErrorPOSPostingLogEntry(POSEntryToPost, 1, GetLastErrorText(), true);
                            end;
                        end;
                    end;
                end;
            until POSEntry.Next() = 0;

        Commit();
        ErrorText := StrSubstNo(ItemPostingErrorMsg, _ItemPostingErrorEntries.Count, LineToProcessCount - _ItemPostingErrorEntries.Count);
        UpdatePOSPostingLogEntry(POSItemPostingLogEntryNo, _ItemPostingErrorEntries.Count > 0);
        ErrorText := '';
    end;

    local procedure CheckAndPostGenJournal(var GenJournalLine: Record "Gen. Journal Line"; var POSEntry: Record "NPR POS Entry"; var POSEntryWithError: Record "NPR POS Entry"): Boolean
    begin
        GenJournalLine.Reset();
        GenJournalLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
        if (not GenJournalLine.FindSet()) then
            exit(false);

        repeat
            if (not TryCheckJournalLine(GenJournalLine)) then begin
                if (StopOnErrorVar) then
                    Error(GetLastErrorText());
                exit(false);
            end;
        until GenJournalLine.Next() = 0;

        if not CheckOrPostGenJnlPerDocument(GenJournalLine, POSEntry, POSEntryWithError, 0) then
            exit(false);
        if not CheckOrPostGenJnlPerDocument(GenJournalLine, POSEntry, POSEntryWithError, 1) then
            exit(false);
        exit(true);
    end;

    [TryFunction]
    local procedure TryCheckJournalLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        GenJnlCheckLine.RunCheck(GenJournalLine);
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
                        until GenJournalLine.Next() = 0;
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
        exit(POSEntryWithError.IsEmpty());
    end;

    local procedure CheckGenJournalDocument(var GenJournalLine: Record "Gen. Journal Line"; var POSEntry: Record "NPR POS Entry"): Boolean
    var
        DifferenceAmount: Decimal;
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        DifferenceAmount := CalculateDifferenceAmount(GenJournalLine);
        if Abs(DifferenceAmount) > 0 then begin
            GetPOSPostingProfile(POSEntry, POSPostingProfile);
            if Abs(DifferenceAmount) > POSPostingProfile."Max. POS Posting Diff. (LCY)" then begin
                POSPostingProfile.TestField("POS Posting Diff. Account");
                ErrorText := StrSubstNo(TextImbalance, GenJournalLine.FieldCaption("Document No."), GenJournalLine."Document No.", GenJournalLine.FieldCaption("Posting Date"), GenJournalLine."Posting Date", DifferenceAmount);
                if (StopOnErrorVar) then
                    Error(ErrorText);
                exit(false);
            end;
        end;
        exit(true);
    end;

    local procedure PostGenJournalDocument(var GenJournalLine: Record "Gen. Journal Line"; var POSEntry: Record "NPR POS Entry"): Boolean

    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        TempPOSPostingProfile: Record "NPR POS Posting Profile" temporary;
        DifferenceAmount: Decimal;
    begin
        DifferenceAmount := CalculateDifferenceAmount(GenJournalLine);

        if (Abs(DifferenceAmount) > 0) then begin
            GetPOSPostingProfile(POSEntry, POSPostingProfile);
            TempPOSPostingProfile.Copy(POSPostingProfile);
            TempPOSPostingProfile."VAT Customer No." := '';
            MakeGenJournalLine(
              Enum::"Gen. Journal Account Type"::"G/L Account",
              POSPostingProfile."POS Posting Diff. Account",
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
              GenJournalLine."Use Tax",
              0,
              0,
              TempPOSPostingProfile,
              "Tax Calculation Type"::"Normal VAT",
              GenJournalLine);
        end;

        exit(PostGenJournalLines(GenJournalLine));
    end;

    local procedure PostGenJournalLines(var GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        if GenJournalLine.FindSet() then
            repeat
                GenJnlPostLine.Run(GenJournalLine);
            until GenJournalLine.Next() = 0;
        exit(true);
    end;

    internal procedure SetPostingDate(NewReplacePostingDate: Boolean; NewReplaceDocumentDate: Boolean; NewPostingDate: Date)
    begin
        PostingDateExists := true;
        ReplaceDocumentDate := NewReplaceDocumentDate;
        ReplaceDocumentDate := NewReplacePostingDate;
        _PostingDate := NewPostingDate;
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

    procedure SetPostPerPeriodRegister(PostingPerPeriodRegisterIn: Boolean)
    begin
        PostingPerPeriodRegister := PostingPerPeriodRegisterIn;
    end;

    procedure SetJobQueuePosting(IsJobQueuePosting: Boolean)
    begin
        JobQueuePosting := IsJobQueuePosting;
    end;

    local procedure CreatePostingBufferLinesFromPOSSalesLines(var POSSalesLineToBeCompressed: Record "NPR POS Entry Sales Line"; var POSPostingBuffer: Record "NPR POS Posting Buffer")
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
        PostingDescription: Text;
        Compressionmethod: Option Uncompressed,"Per POS Entry","Per POS Period Register";
    begin
        if POSSalesLineToBeCompressed.FindSet() then
            repeat
                POSEntry.Get(POSSalesLineToBeCompressed."POS Entry No.");
                if (POSEntry."Post Entry Status" in [POSEntry."Post Entry Status"::Unposted, POSEntry."Post Entry Status"::"Error while Posting"]) then begin
                    POSPeriodRegister.Get(POSEntry."POS Period Register No.");
                    Compressionmethod := GetCompressionMethod(POSPeriodRegister, PostCompressedVar);
                    if Compressionmethod = Compressionmethod::"Per POS Period Register" then
                        if POSSalesLineToBeCompressed."VAT Calculation Type" = POSSalesLineToBeCompressed."VAT Calculation Type"::"Sales Tax" then
                            Error(TextErrorSalesTaxCompressed, POSEntry.TableCaption, POSSalesLineToBeCompressed."POS Entry No.");

                    Clear(POSPostingBuffer);
                    POSPostingBuffer.Init();

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
                                if POSSalesLineToBeCompressed."Copy Description" then
                                    PostingDescription := POSSalesLineToBeCompressed.Description
                                else
                                    PostingDescription := StrSubstNo(PostingDescriptionLbl, POSEntry.TableCaption, POSSalesLineToBeCompressed."POS Entry No.");
                            end;
                        Compressionmethod::"Per POS Period Register":
                            begin
                                POSPeriodRegister.TestField("Document No.");
                                POSPostingBuffer."Document No." := POSPeriodRegister."Document No.";
                                if POSSalesLineToBeCompressed."Copy Description" then
                                    PostingDescription := POSSalesLineToBeCompressed.Description
                                else
                                    PostingDescription := StrSubstNo(PostingDescriptionLbl, POSPeriodRegister.TableCaption, POSSalesLineToBeCompressed."POS Period Register No.");
                            end;
                    end;

                    if not POSPostingBuffer.Find() then begin
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
                        POSPostingBuffer."Rounding Amount" := 0;
                        POSPostingBuffer."Rounding Amount (LCY)" := 0;
                        POSPostingBuffer.Description := CopyStr(PostingDescription, 1, MaxStrLen(POSPostingBuffer.Description));
                        POSPostingBuffer.Insert();
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

                    if POSSalesLineToBeCompressed.Type = POSSalesLineToBeCompressed.Type::Rounding then begin
                        POSPostingBuffer."Rounding Amount" -= POSSalesLineToBeCompressed."Amount Incl. VAT";
                        POSPostingBuffer."Rounding Amount (LCY)" -= POSSalesLineToBeCompressed."Amount Incl. VAT (LCY)";
                    end;

                    OnBeforeModifySalesPOSPostingBufferCreatedFromPOSSalesLines(POSSalesLineToBeCompressed, POSPostingBuffer);

                    POSPostingBuffer.Modify();
                end;
            until POSSalesLineToBeCompressed.Next() = 0;
    end;

    local procedure CreatePostingBufferLinesFromPOSSPaymentLines(var POSPaymentLineToBeCompressed: Record "NPR POS Entry Payment Line"; var POSPostingBuffer: Record "NPR POS Posting Buffer")
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
        POSPaymentMethod: Record "NPR POS Payment Method";
        PostingDescription: Text;
        Compressionmethod: Option Uncompressed,"Per POS Entry","Per POS Period Register";
    begin
        if POSPaymentLineToBeCompressed.FindSet() then
            repeat
                POSEntry.Get(POSPaymentLineToBeCompressed."POS Entry No.");
                if (POSEntry."Post Entry Status" in [POSEntry."Post Entry Status"::Unposted, POSEntry."Post Entry Status"::"Error while Posting"]) then begin
                    POSPeriodRegister.Get(POSEntry."POS Period Register No.");
                    Compressionmethod := GetCompressionMethod(POSPeriodRegister, PostCompressedVar);

                    Clear(POSPostingBuffer);
                    POSPostingBuffer.Init();

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
                    POSPostingBuffer."VAT Calculation Type" := POSPaymentLineToBeCompressed."VAT Calculation Type";
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

                    if not POSPostingBuffer.Find() then begin
                        POSPostingBuffer.Amount := 0;
                        POSPostingBuffer."Amount (LCY)" := 0;
                        POSPostingBuffer."Rounding Amount" := 0;
                        POSPostingBuffer."Rounding Amount (LCY)" := 0;
                        POSPostingBuffer.Description := CopyStr(PostingDescription, 1, MaxStrLen(POSPostingBuffer.Description));
                        POSPostingBuffer."VAT Amount (LCY)" := 0;
                        POSPostingBuffer."VAT Base Amount" := 0;
                        POSPostingBuffer.Insert();
                    end;

                    POSPostingBuffer."Rounding Amount" := POSPostingBuffer."Rounding Amount" + POSPaymentLineToBeCompressed."Rounding Amount";
                    POSPostingBuffer."Rounding Amount (LCY)" := POSPostingBuffer."Rounding Amount" + POSPaymentLineToBeCompressed."Rounding Amount (LCY)";
                    POSPostingBuffer.Amount := POSPostingBuffer.Amount + POSPaymentLineToBeCompressed.Amount - POSPaymentLineToBeCompressed."VAT Amount (LCY)";
                    POSPostingBuffer."Amount (LCY)" := POSPostingBuffer."Amount (LCY)" + POSPaymentLineToBeCompressed."Amount (LCY)" - POSPaymentLineToBeCompressed."VAT Amount (LCY)";

                    POSPostingBuffer."VAT Amount" += POSPaymentLineToBeCompressed."VAT Amount (LCY)"; // VAT reversal in foreign currency not supported.
                    POSPostingBuffer."VAT Amount (LCY)" += POSPaymentLineToBeCompressed."VAT Amount (LCY)";
                    POSPostingBuffer."VAT Base Amount" += POSPaymentLineToBeCompressed."VAT Base Amount (LCY)";

                    OnBeforeModifySalesPOSPostingBufferCreatedFromPOSPaymentLines(POSPaymentLineToBeCompressed, POSPostingBuffer);

                    POSPostingBuffer.Modify();
                end;
            until POSPaymentLineToBeCompressed.Next() = 0;
    end;

    local procedure CreatePOSPostingLogEntry(var POSEntry: Record "NPR POS Entry"; PostingType: Integer): Integer
    var
        POSPostingLog: Record "NPR POS Posting Log";
        LastPOSEntry: Record "NPR POS Entry";
    begin
        LastPOSEntry.Reset();
        LastPOSEntry.FindLast();
        POSPostingLog.Init();
        POSPostingLog."Entry No." := 0;
        POSPostingLog."User ID" := CopyStr(UserId(), 1, MaxStrLen(POSPostingLog."User ID"));
        POSPostingLog."Posting Timestamp" := CurrentDateTime;
        POSPostingLog."With Error" := true;
        POSPostingLog."Error Description" := TextUnknownError;
        POSPostingLog."POS Entry View" := CopyStr(POSEntry.GetView(), 1, MaxStrLen(POSPostingLog."POS Entry View"));
        POSPostingLog."Last POS Entry No. at Posting" := LastPOSEntry."Entry No.";
        POSPostingLog."Posting Type" := PostingType;
        POSPostingLog."Parameter Posting Date" := _PostingDate;
        POSPostingLog."Parameter Replace Posting Date" := ReplacePostingDate;
        POSPostingLog."Parameter Replace Doc. Date" := ReplaceDocumentDate;
        POSPostingLog."Parameter Post Item Entries" := PostItemEntriesVar;
        POSPostingLog."Parameter Post POS Entries" := PostPOSEntriesVar;
        POSPostingLog."Parameter Post Compressed" := PostCompressedVar;
        POSPostingLog."Parameter Stop On Error" := StopOnErrorVar;
        if PostingPerPeriodRegister then begin
            POSPostingLog."Posting Per" := POSPostingLog."Posting Per"::"POS Period Register";
            POSPostingLog."Posting Per Entry No." := POSEntry."POS Period Register No.";
        end;
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

    local procedure CreateErrorPOSPostingLogEntry(POSEntry: Record "NPR POS Entry"; PostingType: Integer; PostingErrorTxt: Text; DoCommit: Boolean)
    var
        POSPostingLog: Record "NPR POS Posting Log";
    begin
        POSPostingLog.Init();
        POSPostingLog."Entry No." := 0;
        POSPostingLog."User ID" := CopyStr(UserId(), 1, MaxStrLen(POSPostingLog."User ID"));
        POSPostingLog."Posting Timestamp" := CurrentDateTime;
        POSPostingLog."With Error" := true;
        POSPostingLog."Error Description" := copystr(PostingErrorTxt, 1, MaxStrLen(POSPostingLog."Error Description"));
        POSPostingLog."POS Entry View" := CopyStr(POSEntry.GetView(), 1, MaxStrLen(POSPostingLog."POS Entry View"));
        POSPostingLog."Posting Type" := PostingType;
        POSPostingLog."Parameter Posting Date" := _PostingDate;
        POSPostingLog."Parameter Replace Posting Date" := ReplacePostingDate;
        POSPostingLog."Parameter Replace Doc. Date" := ReplaceDocumentDate;
        POSPostingLog."Parameter Post Item Entries" := PostItemEntriesVar;
        POSPostingLog."Parameter Post POS Entries" := PostPOSEntriesVar;
        POSPostingLog."Parameter Post Compressed" := PostCompressedVar;
        POSPostingLog."Parameter Stop On Error" := StopOnErrorVar;
        POSPostingLog."Posting Per" := POSPostingLog."Posting Per"::"POS Entry";
        POSPostingLog."Posting Per Entry No." := POSEntry."Entry No.";
        POSPostingLog.Insert(true);
        if DoCommit then
            Commit();
    end;

    local procedure GetCompressionMethod(POSPeriodRegister: Record "NPR POS Period Register"; PostCompressed: Boolean): Integer
    begin
        if (not PostCompressed) then
            if (POSPeriodRegister."Posting Compression" = POSPeriodRegister."Posting Compression"::"Per POS Period") then
                exit(POSPeriodRegister."Posting Compression"::"Per POS Entry");

        exit(POSPeriodRegister."Posting Compression");
    end;

    local procedure GetPostingSetupFromBufferLine(POSPostingBuffer: Record "NPR POS Posting Buffer"; var POSPostingSetup: Record "NPR POS Posting Setup")
    var
        PostingSetupNotFoundLbl: Label '%1: %4, %2: %5, %3: %6', Locked = true;
    begin
        if not GetPostingSetup(POSPostingBuffer."POS Store Code", POSPostingBuffer."POS Payment Method Code", POSPostingBuffer."POS Payment Bin Code", POSPostingSetup) then
            if POSPostingBuffer."POS Entry No." <> 0 then
                Error(TextPostingSetupMissing, POSPostingSetup.TableCaption, POSPostingBuffer."Line Type", POSPostingBuffer.FieldCaption("POS Entry No."), POSPostingBuffer."POS Entry No.",
                    StrSubstNo(PostingSetupNotFoundLbl, POSPostingBuffer.FieldCaption("POS Store Code"), POSPostingBuffer.FieldCaption("POS Payment Method Code"), POSPostingBuffer.FieldCaption("POS Payment Bin Code"),
                    POSPostingBuffer."POS Store Code", POSPostingBuffer."POS Payment Method Code", POSPostingBuffer."POS Payment Bin Code"))
            else
                Error(TextPostingSetupMissing, POSPostingSetup.TableCaption, POSPostingBuffer."Line Type", POSPostingBuffer."POS Period Register", POSPostingBuffer."POS Period Register",
                    StrSubstNo(PostingSetupNotFoundLbl, POSPostingBuffer.FieldCaption("POS Store Code"), POSPostingBuffer.FieldCaption("POS Payment Method Code"), POSPostingBuffer.FieldCaption("POS Payment Bin Code"),
                    POSPostingBuffer."POS Store Code", POSPostingBuffer."POS Payment Method Code", POSPostingBuffer."POS Payment Bin Code"));
    end;

    local procedure GetPostingSetupFromBalancingLine(POSBalancingLine: Record "NPR POS Balancing Line"; var POSPostingSetup: Record "NPR POS Posting Setup")
    var
        PostingSetupNotFoundLbl: Label '%1: %4, %2: %5, %3: %6', Locked = true;
    begin
        if not GetPostingSetup(POSBalancingLine."POS Store Code", POSBalancingLine."POS Payment Method Code", POSBalancingLine."POS Payment Bin Code", POSPostingSetup) then
            if POSBalancingLine."POS Entry No." <> 0 then
                Error(TextPostingSetupMissing, POSPostingSetup.TableCaption, POSBalancingLine.TableCaption, POSBalancingLine.FieldCaption("POS Entry No."), POSBalancingLine."POS Entry No.",
                    StrSubstNo(PostingSetupNotFoundLbl, POSBalancingLine.FieldCaption("POS Store Code"), POSBalancingLine.FieldCaption("POS Payment Method Code"), POSBalancingLine.FieldCaption("POS Payment Bin Code"),
                    POSBalancingLine."POS Store Code", POSBalancingLine."POS Payment Method Code", POSBalancingLine."POS Payment Bin Code"))
            else
                Error(TextPostingSetupMissing, POSPostingSetup.TableCaption, POSBalancingLine.TableCaption, POSBalancingLine.FieldCaption("POS Period Register No."), POSBalancingLine."POS Period Register No.",
                    StrSubstNo(PostingSetupNotFoundLbl, POSBalancingLine.FieldCaption("POS Store Code"), POSBalancingLine.FieldCaption("POS Payment Method Code"), POSBalancingLine.FieldCaption("POS Payment Bin Code"),
                    POSBalancingLine."POS Store Code", POSBalancingLine."POS Payment Method Code", POSBalancingLine."POS Payment Bin Code"));
    end;

    internal procedure GetPostingSetup(POSStoreCode: Code[10]; POSPaymentMethodCode: Code[10]; POSPaymentBinCode: Code[10]; var POSPostingSetup: Record "NPR POS Posting Setup"): Boolean
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

    procedure GetGLPostingErrorEntries(var ListOut: List of [Integer])
    begin
        ListOut := _GLPostingErrorEntries;
    end;

    internal procedure GetItemPostingErrorEntries(var ListOut: List of [Integer])
    begin
        ListOut := _ItemPostingErrorEntries;
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
        if POSEntry.FindSet(true) then
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
                                ProceedWithUpdate := not POSEntryWithError.IsEmpty();
                                if not ProceedWithUpdate then begin
                                    POSEntryWithError.SetRange("Document No.", POSEntry."Document No.");
                                    ProceedWithUpdate := not POSEntryWithError.IsEmpty();
                                end;
                                if ProceedWithUpdate then begin
                                    POSEntry.Validate("Post Entry Status", POSEntry."Post Entry Status"::"Error while Posting");
                                    _GLPostingErrorEntries.Add(POSEntry."Entry No.");
                                end;
                            end;
                    end;
                    POSEntry."POS Posting Log Entry No." := POSPostingLogEntryNo;
                    POSEntry.Modify(true);
                end;
            until POSEntry.Next() = 0;
    end;

    local procedure MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer: Record "NPR POS Posting Buffer"; AmountIn: Decimal; AmountInLCY: Decimal; PostingType: Enum "General Posting Type"; AccountType: Enum "Gen. Journal Account Type";
                                                                                                                                                                    AccountNo: Code[20];
                                                                                                                                                                    VATAmountIn: Decimal;
                                                                                                                                                                    VATAmountInLCY: Decimal; var GenJournalLine: Record "Gen. Journal Line")
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
          POSPostingBuffer."Use Tax",
          VATAmountIn,
          VATAmountInLCY,
          POSPostingProfile,
          POSPostingBuffer."VAT Calculation Type",
          GenJournalLine);

        OnAfterInsertPOSPostingBufferToGenJnl(POSPostingBuffer, GenJournalLine, false);
        OnAfterInsertFromPOSPostingBufferToGenJournal(POSPostingBuffer."POS Unit No.", POSPostingBuffer."Line Type", POSPostingBuffer."POS Payment Method Code", POSPostingBuffer."Posting Date", POSPostingBuffer."POS Payment Bin Code", POSPostingBuffer."POS Period Register", GenJournalLine);
    end;



    local procedure MakeGenJournalLine(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20];
                                                        GenPostingType: Enum "General Posting Type";
                                                        PostingDate: Date;
                                                        DocumentNo: Code[20];
                                                        PostingDescription: Text;
                                                        VATPerc: Decimal;
                                                        PostingCurrencyCode: Code[10];
                                                        PostingAmount: Decimal;
                                                        PostingAmountLCY: Decimal;
                                                        PostingGroup: Code[20];
                                                        GenBusPostingGroup: Code[20];
                                                        GenProdPostingGroup: Code[20];
                                                        VATBusPostingGroup: Code[20];
                                                        VATProdPostingGroup: Code[20];
                                                        ShortcutDim1: Code[20];
                                                        ShortcutDim2: Code[20];
                                                        DimSetID: Integer;
                                                        SalespersonCode: Code[20];
                                                        ReasonCode: Code[10];
                                                        ExternalDocNo: Code[35];
                                                        Usetax: Boolean;
                                                        VATAmount: Decimal;
                                                        VATAmountLCY: Decimal;
                                                        POSPostingProfile: Record "NPR POS Posting Profile";
                                                        TaxCalcType: Enum "Tax Calculation Type"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        _LineNumber := _LineNumber + 10000;
        GenJournalLine.Init();
        GenJournalLine."Journal Template Name" := POSPostingProfile."Journal Template Name";
        GenJournalLine."Journal Batch Name" := '';
        GenJournalLine."Line No." := _LineNumber;
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine."Account Type" := AccountType;
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer then
            if PostingAmount <= 0 then
                GenJournalLine."Document Type" := GenJournalLine."Document Type"::Payment
            else
                GenJournalLine."Document Type" := GenJournalLine."Document Type"::Refund;
        GenJournalLine."Account No." := AccountNo;
        GenJournalLine."Gen. Posting Type" := GenPostingType;
        GenJournalLine.Validate("Posting Date", PostingDate);
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
            if TaxCalcType <> TaxCalcType::"Sales Tax" then begin
                GenJournalLine."VAT %" := VATPerc;
                GenJournalLine."Source Curr. VAT Amount" := VATAmount;
                GenJournalLine."Source Curr. VAT Base Amount" := PostingAmount;
                GenJournalLine."Use Tax" := Usetax;
                GenJournalLine."VAT Amount" := VATAmount;
                GenJournalLine."VAT Amount (LCY)" := VATAmountLCY;

                if GenPostingType = GenJournalLine."Gen. Posting Type"::Sale then
                    GenJournalLine."Bill-to/Pay-to No." := POSPostingProfile."VAT Customer No.";

                GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
                GenJournalLine."VAT Bus. Posting Group" := VATBusPostingGroup;
                GenJournalLine."VAT Prod. Posting Group" := VATProdPostingGroup;
            end;
            GenJournalLine."VAT Calculation Type" := TaxCalcType;
            GenJournalLine."Gen. Bus. Posting Group" := GenBusPostingGroup;
            GenJournalLine."Gen. Prod. Posting Group" := GenProdPostingGroup;
        end;

        GenJournalLine."Posting Group" := PostingGroup;
        GenJournalLine."Shortcut Dimension 1 Code" := ShortcutDim1;
        GenJournalLine."Shortcut Dimension 2 Code" := ShortcutDim2;
        GenJournalLine."Dimension Set ID" := DimSetID;
        GenJournalLine."Salespers./Purch. Code" := SalespersonCode;
        GenJournalLine."Reason Code" := ReasonCode;
        GenJournalLine."Source Code" := POSPostingProfile."Source Code";

        GenJournalLine.Insert();
    end;

    local procedure MakeGenJournalFromPOSBalancingLineWithVatOption(POSEntry: Record "NPR POS Entry"; POSBalancingLine: Record "NPR POS Balancing Line"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; PostingAmount: Decimal; PostingDescription: Text; var GenJournalLine: Record "Gen. Journal Line"): Decimal
    var
        GLAccount: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
        POSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
        DoPostVAT: Boolean;
        TempPosPostingProfile: Record "NPR POS Posting Profile" temporary;
    begin
        DoPostVAT := GetAccountSetup(AccountNo, AccountType, GLAccount, VATPostingSetup);

        POSStore.GetProfile(POSEntry."POS Store Code", POSPostingProfile);
        TempPosPostingProfile.Copy(POSPostingProfile);
        TempPosPostingProfile."VAT Customer No." := '';

        _LineNumber := _LineNumber + 10000;
        GenJournalLine.Init();
        GenJournalLine."Journal Template Name" := POSPostingProfile."Journal Template Name";
        GenJournalLine."Journal Batch Name" := '';
        GenJournalLine."Line No." := _LineNumber;
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine."Account Type" := AccountType;
        GenJournalLine."Account No." := AccountNo;
        if DoPostVAT then
            GenJournalLine."Gen. Posting Type" := GLAccount."Gen. Posting Type";
        GenJournalLine.Validate("Posting Date", POSEntry."Posting Date");
        GenJournalLine."Document Date" := GenJournalLine."Posting Date";
        GenJournalLine."Document No." := POSBalancingLine."Document No.";
        GenJournalLine."External Document No." := '';
        GenJournalLine.Description := CopyStr(PostingDescription, 1, MaxStrLen(GenJournalLine.Description));
        if StrLen(PostingDescription) > MaxStrLen(GenJournalLine.Description) then
            GenJournalLine.Comment := CopyStr(PostingDescription, 1, MaxStrLen(GenJournalLine.Comment));

        GenJournalLine."Currency Code" := POSBalancingLine."Currency Code";
        if (GenJournalLine."Currency Code" <> '') then
            GenJournalLine.Validate("Currency Code");
        if PostingAmount <> 0 then
            GenJournalLine.Validate(Amount, PostingAmount);

        GenJournalLine."Source Currency Code" := POSBalancingLine."Currency Code";
        GenJournalLine."Source Currency Amount" := PostingAmount;

        if DoPostVAT then begin
            GenJournalLine."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
            GenJournalLine."Gen. Bus. Posting Group" := GLAccount."Gen. Bus. Posting Group";
            GenJournalLine."Gen. Prod. Posting Group" := GLAccount."Gen. Prod. Posting Group";
            GenJournalLine."VAT Bus. Posting Group" := GLAccount."VAT Bus. Posting Group";
            GenJournalLine."VAT Prod. Posting Group" := GLAccount."VAT Prod. Posting Group";
        end;

        GenJournalLine."Posting Group" := '';
        GenJournalLine."Shortcut Dimension 1 Code" := POSBalancingLine."Shortcut Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := POSBalancingLine."Shortcut Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := POSBalancingLine."Dimension Set ID";
        GenJournalLine."Salespers./Purch. Code" := '';
        GenJournalLine."Reason Code" := '';
        GenJournalLine."Source Code" := POSPostingProfile."Source Code";
        GenJournalLine.Insert();

        OnAfterInsertPOSBalancingLineToGenJnl(POSBalancingLine, GenJournalLine, false);
        exit(GenJournalLine."Amount (LCY)" + GenJournalLine."VAT Amount (LCY)");
    end;

    local procedure GetAccountSetup(AccountNo: Code[20]; AccountType: Enum "Gen. Journal Account Type"; var GLAccount: Record "G/L Account"; var VATPostingSetup: Record "VAT Posting Setup"): Boolean
    begin
        if AccountNo = '' then
            exit;

        if AccountType <> AccountType::"G/L Account" then
            exit;

        if not GLAccount.Get(AccountNo) then
            exit;

        if (GLAccount."Gen. Bus. Posting Group" = '') or
         (GLAccount."Gen. Prod. Posting Group" = '') or
         (GLAccount."VAT Bus. Posting Group" = '') or
         (GLAccount."VAT Prod. Posting Group" = '') or
         (GLAccount."Gen. Posting Type" = GLAccount."Gen. Posting Type"::" ") then
            exit;

        exit(VATPostingSetup.Get(GLAccount."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group"));
    end;

    local procedure SetAppliesToDocument(var GenJournalLine: Record "Gen. Journal Line"; var POSPostingBuffer: Record "NPR POS Posting Buffer")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLSetup: Record "General Ledger Setup";
    begin
        if POSPostingBuffer."Applies-to Doc. No." = '' then
            exit;
        if POSPostingBuffer.Type <> POSPostingBuffer.Type::Customer then
            exit;

        GLSetup.Get();
        if not (POSPostingBuffer."Currency Code" in [GLSetup."LCY Code", '']) then
            exit;

        CustLedgerEntry.SetAutoCalcFields("Remaining Amount");
        CustLedgerEntry.SetCurrentKey("Document Type", "Customer No.", Open, "Due Date");
        CustLedgerEntry.SetRange("Document Type", POSPostingBuffer."Applies-to Doc. Type");
        CustLedgerEntry.SetRange("Customer No.", POSPostingBuffer."No.");
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange("Document No.", POSPostingBuffer."Applies-to Doc. No.");
        CustLedgerEntry.SetFilter("Currency Code", '=%1|=%2', GLSetup."LCY Code", '');
        if CustLedgerEntry.IsEmpty() then
            exit;

        CustLedgerEntry.FindFirst();
        if CustLedgerEntry.Positive then begin
            if CustLedgerEntry."Remaining Amount" < -POSPostingBuffer.Amount then
                exit;
        end else begin
            if CustLedgerEntry."Remaining Amount" > -POSPostingBuffer.Amount then
                exit;
        end;

        GenJournalLine.Validate("Applies-to Doc. Type", POSPostingBuffer."Applies-to Doc. Type");
        GenJournalLine.Validate("Applies-to Doc. No.", POSPostingBuffer."Applies-to Doc. No.");
        GenJournalLine.Validate("Currency Code", CustLedgerEntry."Currency Code"); //one might be blank while other is LCY
        GenJournalLine.Modify();
    end;

    local procedure CalculateDifferenceAmount(var GenJournalLine: Record "Gen. Journal Line") DifferenceAmount: Decimal
    begin
        if GenJournalLine.FindSet() then
            repeat
                DifferenceAmount := DifferenceAmount + GenJournalLine."Amount (LCY)" + GenJournalLine."VAT Amount (LCY)";
            until GenJournalLine.Next() = 0;
        exit(DifferenceAmount);
    end;

    internal procedure SkipProcessing(PostingPerType: Integer; PostingPerEntryNo: Integer; PostingType: Integer): Boolean
    var
        POSPostingLog: Record "NPR POS Posting Log";
        PostingErrorCount: Integer;
    begin
        POSPostingLog.SetCurrentKey("Posting Per Entry No.", "Posting Per", "Posting Type", "With Error");
        POSPostingLog.SetRange("Posting Per Entry No.", PostingPerEntryNo);
        POSPostingLog.SetRange("Posting Per", PostingPerType);
        POSPostingLog.SetRange("Posting Type", PostingType);
        POSPostingLog.SetRange("With Error", true);

        PostingErrorCount := POSPostingLog.Count;
        if PostingErrorCount <= 1 then
            exit;

        POSPostingLog.FindLast();
        exit(CurrentDateTime < POSPostingLog."Posting Timestamp" + Power(2, PostingErrorCount) * 60000)
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPOSEntry(var POSEntry: Record "NPR POS Entry"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPostingRestrictions(var POSEntry: Record "NPR POS Entry"; PreviewMode: Boolean)
    begin
    end;

    [CommitBehavior(CommitBehavior::Error)]
    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPOSEntry(var POSEntry: Record "NPR POS Entry"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSPostingBufferToGenJnl(var POSPostingBuffer: Record "NPR POS Posting Buffer"; var GenJournalLine: Record "Gen. Journal Line"; PreviewMode: Boolean)
    begin
    end;

    [Obsolete('Replaced by new function OnAfterInsertFromPOSPostingBufferToGenJournal with new additional parameters', 'NPR24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSPostingBufferToGenJournal(POSUnitNo: Code[10]; LineType: Option; POSPaymentMethodCode: Code[10]; PostingDate: Date; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertFromPOSPostingBufferToGenJournal(POSUnitNo: Code[10]; LineType: Option; POSPaymentMethodCode: Code[10]; PostingDate: Date; POSPaymentBinCode: Code[10]; POSPeriodRegister: Integer; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSBalancingLineToGenJnl(var POSBalancingLine: Record "NPR POS Balancing Line"; var GenJournalLine: Record "Gen. Journal Line"; PreviewMode: Boolean)
    begin
    end;

    [CommitBehavior(CommitBehavior::Error)]
    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPOSEntryBatch(var POSEntry: Record "NPR POS Entry"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMakeGenJournalForBalancedDifference(POSBalancingLine: Record "NPR POS Balancing Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMakeGenJournalForMoveToBin(POSBalancingLine: Record "NPR POS Balancing Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMakeGenJournalForDepositToBin(POSBalancingLine: Record "NPR POS Balancing Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMakeGenJournalForNewFloatAmount(POSBalancingLine: Record "NPR POS Balancing Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMakeGenJournalForTotalAmount(POSBalancingLine: Record "NPR POS Balancing Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifySalesPOSPostingBufferCreatedFromPOSSalesLines(var POSSalesLineToBeCompressed: Record "NPR POS Entry Sales Line"; var POSPostingBuffer: Record "NPR POS Posting Buffer")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifySalesPOSPostingBufferCreatedFromPOSPaymentLines(var POSPaymentLineToBeCompressed: Record "NPR POS Entry Payment Line"; var POSPostingBuffer: Record "NPR POS Posting Buffer")
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
        if POSEntry2.FindSet() then
            repeat
                POSPostingControl.CheckGlobalDimAndDimSetConsistency(POSEntry2.RecordId, POSEntry2."Shortcut Dimension 1 Code", POSEntry2."Shortcut Dimension 2 Code", POSEntry2."Dimension Set ID", 0);
            until POSEntry2.Next() = 0;
    end;
}
