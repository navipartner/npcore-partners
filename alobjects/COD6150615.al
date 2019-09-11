codeunit 6150615 "POS Post Entries"
{
    // NPR5.36/BR  /20170615  CASE 279551 Basic functions added
    // NPR5.37/BR  /20171011  CASE 293133 Compare with Audit Roll
    // NPR5.37/BR  /20171012  CASE 293227 Changed Compression option
    // NPR5.38/BR  /20171108  CASE 294718 Added fields Applies-to Doc. Type and Applies-to Doc. No.
    // NPR5.38/BR  /20171108  CASE 294720 Added field External Doc. No.
    // NPR5.38/BR  /20171109  CASE 294722 Added field Condensed Posting Description
    // NPR5.38/BR  /20171214  CASE 299888 Renamed from POSLedgerRegister to POSPeriodRegister
    // NPR5.38/BR  /20180105  CASE 285957 Restructured for non-stoponerror
    // NPR5.38/BR  /20180119  CASE 302791 Log field Posting Duration
    // NPR5.38/BR  /20180122  CASE 302693 Added support for Payout
    // NPR5.38/BR  /20180123  CASE 302777 Implement Balancing posting
    // NPR5.38/BR  /20180125  CASE 302803 Extended Error handling
    // NPR5.39/BR  /20180208  CASE 302803 Bugfix Sales Tax Calculation, handle extra type Rounding
    // NPR5.39/BR  /20180219  CASE 304901 Bugfix NA localized version
    // NPR5.41/TSA /20180226  CASE 306394 Excluded the type::round (rounding line) from sales tax comparison discrepency test
    // NPR5.41/TSA /20180226  CASE 306394 Rounding account was not transfered from the buffer
    // NPR5.41/MMV /20180416  CASE 311309 Refactored CheckPOSTaxAmountLines() so error can be retrieved.
    //                                    Changed rounding in CheckPOSTaxAmountLines()
    // NPR5.42/MMV /20180504  CASE 312858 Allow zero amount GenJnl lines.
    // NPR5.45/TSA /20180720 CASE 322769 Enhanced posting setup error to include the setup params.
    // NPR5.46/TJ  /20180912 CASE 307250 Fixed the dialog texts when posting POS entries and Item entries
    // NPR5.49/TJ  /20190117 CASE 331208 Created new publisher
    // NPR5.49/TSA /20190321 CASE 348458 Changed GetPostingSetup() to public function, used in balancing to check setup
    // NPR5.50/MMV /20190321 CASE 300557 Apply customer deposits
    //                                   Post customer refunds with refund type instead of payment.
    // NPR5.50/TSA /20190520 CASE 354832 Reversal of preliminary VAT when paying with vouchers that included VAT on sales
    // NPR5.51/TSA /20190620 CASE 359403 Corrected a bug in the selection of compression method in GetCompressionMethod();
    // NPR5.51/TSA /20190620 CASE 359403 Added filter to prevent balancing entries to double posted when using the post range function
    // NPR5.51/TSA /20190626 CASE 347057 Include lines of type PAYOUT in tax calculation check sum, since it was only half included
    // NPR5.51/MHA /20190718  CASE 362329 Skip "Exclude from Posting" Sales Lines

    TableNo = "POS Entry";

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
        PreviewMode: Boolean;
        FakeDocNoTxt: Label '***';
        TextPostingSetupMissing: Label '%1 is missing for %2 in %3 %4.\\Values [%5].';
        Debug: Boolean;
        TextPostingSetupMissingMovement: Label '%1 is missing for %2 Movement to Bin in %3 %4.';
        TextPostingSetupMissingDeposit: Label '%1 is missing for %2 Deposit to Bin in %3 %4.';
        TextClosingEntryFloat: Label 'Float Amount Closing POS Entry %1';
        TextSalesTaxDiscrepancy: Label 'There is a Sales Tax discrepancy. Sum of %1 on the lines is %2, while the calculated amount is %3.';
        TextPostingDifference: Label 'POS Posting Difference';

    [TryFunction]
    local procedure "Code"(var POSEntry: Record "POS Entry")
    var
        NPRetailSetup: Record "NP Retail Setup";
        TempPOSPostingBuffer: Record "POS Posting Buffer" temporary;
        TempPOSSalesLineToPost: Record "POS Sales Line" temporary;
        POSSalesLine: Record "POS Sales Line";
        TempPOSPaymentLinetoPost: Record "POS Payment Line" temporary;
        POSPaymentLine: Record "POS Payment Line";
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
    begin
        NPRetailSetup.Get;
        if not NPRetailSetup."Advanced POS Entries Activated" then
          exit;
        if (not NPRetailSetup."Advanced Posting Activated") and (not PreviewMode) then
          exit;

        if ((not PostItemEntriesVar) and (not PostPOSEntriesVar)) or POSEntry.IsEmpty then
          Error(TextNothingToPost);

        if ShowProgressDialog then begin
          //-NPR5.46 [307250]
          //IF PostItemEntriesVar AND PostItemEntriesVar THEN
          if PostItemEntriesVar and PostPOSEntriesVar then
          //+NPR5.46 [307250]
            ProgressWindow.Open(Text005 + Text001 + Text002 + Text003 + Text004 )
          else
            if PostItemEntriesVar then
              ProgressWindow.Open(Text005 + Text001 )
            else
              if PostPOSEntriesVar then
                ProgressWindow.Open(Text001 + Text002 + Text003 + Text004 );
        end;

        if PostItemEntriesVar then begin
          //Item entries are posted first and committed after each POS Entry is posted
          PostItemEntries(POSEntry);
          //-NPR5.38 [302791]
          if (not PreviewMode) and (POSEntry."Post Item Entry Status" = POSEntry."Post Item Entry Status"::"Error while Posting") then begin
            POSPostingLogEntryNo := CreatePOSPostingLogEntry(POSEntry);
            UpdatePOSPostingLogEntry(POSPostingLogEntryNo,true);
            Commit; //Commit the start of the log
          end;
          //+NPR5.38 [302791]
        end;

        if PostPOSEntriesVar then begin
          //POS Entries must belong to the same POS Legder Register Entry
          POSPostingLogEntryNo := CreatePOSPostingLogEntry(POSEntry);
          if not PreviewMode then
            Commit;

          CreateTempRecordsToPost (POSEntry, TempPOSSalesLineToPost, TempPOSPaymentLinetoPost);
          CreatePostingBufferLinesFromPOSSalesLines (TempPOSSalesLineToPost, TempPOSPostingBuffer, PostCompressedVar);
          CreatePostingBufferLinesFromPOSSPaymentLines (TempPOSPaymentLinetoPost, TempPOSPostingBuffer, PostCompressedVar);

        //-NPR5.42 [312858]
          //IF ((TempPOSPaymentLinetoPost.COUNT > 0) OR (TempPOSSalesLineToPost.COUNT > 0)) AND (TempPOSPostingBuffer.COUNT = 0) THEN
          if ((not TempPOSPaymentLinetoPost.IsEmpty) or (not TempPOSSalesLineToPost.IsEmpty)) and (TempPOSPostingBuffer.IsEmpty) then
        //+NPR5.42 [312858]
            Error(TextErrorBufferLinesnotmade,TempPOSPostingBuffer.TableCaption);

          CreateGenJnlLinesFromPOSPostingBuffer(TempPOSPostingBuffer,TempGenJournalLine);

        //-NPR5.42 [312858]
        //  IF (TempPOSPostingBuffer.COUNT > 0) AND (TempGenJournalLine.COUNT = 0) THEN
          if (not TempPOSPostingBuffer.IsEmpty) and (TempGenJournalLine.IsEmpty) then
        //+NPR5.42 [312858]
            Error(TextErrorGJLinesnotmade,TempGenJournalLine.TableCaption);

          CreateGenJnlLinesFromPOSBalancingLines(POSEntry,TempGenJournalLine);
          CreateGenJournalLinesFromSalesTax(POSEntry,TempGenJournalLine);

          if StopOnErrorVar then begin
            CheckandPostGenJournal(TempGenJournalLine);
            UpdatePOSPostingLogEntry(POSPostingLogEntryNo,false);
            MarkPOSEntries(0,POSPostingLogEntryNo,POSEntry);

          end else begin
            if not PreviewMode then
              Commit;

            if not CheckandPostGenJournal(TempGenJournalLine) then begin
              UpdatePOSPostingLogEntry(POSPostingLogEntryNo,true);
              MarkPOSEntries(1,POSPostingLogEntryNo,POSEntry);
            end else begin
              UpdatePOSPostingLogEntry(POSPostingLogEntryNo,false);
              MarkPOSEntries(0,POSPostingLogEntryNo,POSEntry);
            end;

          end;
        end;

        if POSEntry.FindSet then repeat
          OnAfterPostPOSEntry(POSEntry,PreviewMode);
        until POSEntry.Next  = 0;

        //-NPR5.49 [331208]
        OnAfterPostPOSEntryBatch(POSEntry,PreviewMode);
        //+NPR5.49 [331208]

        if ShowProgressDialog then
          ProgressWindow.Close;

        if PreviewMode then begin
          Error('Not supported in 2017 yet');
          //GenJnlPostPreview.Finish;
          //ERROR(GenJnlPostPreview.GetPreviewModeErrMessage);
        end;
    end;

    procedure PostRangePerPOSEntry(var POSEntry: Record "POS Entry")
    var
        POSEntry2: Record "POS Entry";
        PerEntryDialog: Dialog;
        NoOfRecords: Integer;
        LineCount: Integer;
    begin
        ShowProgressDialog := false;
        if GuiAllowed then begin
          PerEntryDialog.Open(Text006);
          NoOfRecords := POSEntry.Count;
        end;
        if POSEntry.FindSet then repeat
          if GuiAllowed then begin
            LineCount := LineCount + 1;
            PerEntryDialog.Update(1,POSEntry."Entry No.");
            PerEntryDialog.Update(2,Round(LineCount / NoOfRecords * 10000,1));
          end;
          POSEntry2.SetRange("Entry No.",POSEntry."Entry No.");
          Code(POSEntry2);
          Commit;
        until POSEntry.Next = 0;
        if GuiAllowed then
          PerEntryDialog.Close;
    end;

    procedure PostFromPOSPostingLog(var POSPostingLog: Record "POS Posting Log")
    var
        POSEntry: Record "POS Entry";
    begin
        POSPostingLog.TestField("POS Entry View");
        POSEntry.SetView(POSPostingLog."POS Entry View");
        if POSEntry.GetFilter("Entry No.")  = '' then
          POSEntry.SetRange("Entry No.",0,POSPostingLog."Last POS Entry No. at Posting");
        SetPostCompressed(POSPostingLog."Parameter Post Compressed");
        if POSPostingLog."Parameter Posting Date" <> 0D then
          SetPostingDate(POSPostingLog."Parameter Replace Posting Date",POSPostingLog."Parameter Replace Doc. Date",POSPostingLog."Parameter Posting Date");
        SetPostItemEntries(POSPostingLog."Parameter Post Item Entries");
        SetPostPOSEntries(POSPostingLog."Parameter Post POS Entries");
        SetStopOnError(true);
        Code(POSEntry);
    end;

    local procedure CreateTempRecordsToPost(var POSEntry: Record "POS Entry";var POSSalesLineToPost: Record "POS Sales Line" temporary;var POSPaymentLineToPost: Record "POS Payment Line" temporary)
    var
        POSSalesLine: Record "POS Sales Line";
        POSPaymentLine: Record "POS Payment Line";
        POSPeriodRegister: Record "POS Period Register";
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
          ProgressWindow.Update(2,NoOfRecords);
        end;

        if POSEntry.FindFirst then repeat
          if ShowProgressDialog then begin
            LineCount := LineCount + 1;
            ProgressWindow.Update(3,Round(LineCount / NoOfRecords * 10000,1));
          end;
          //-NPR5.38 [301600]
          if  (POSEntry."Post Entry Status" in [POSEntry."Post Entry Status"::Unposted,POSEntry."Post Entry Status"::"Error while Posting"]) then begin
          //+NPR5.38 [301600]
            OnCheckPostingRestrictions(POSEntry,PreviewMode);
            OnBeforePostPOSEntry(POSEntry,PreviewMode);

            POSEntry.Recalculate;
            //-NPR5.38 [302803]
            //IF NOT CheckPOSTaxAmountLines(POSEntry) THEN
            if not CheckPOSTaxAmountLines(POSEntry,true) then
            //+NPR5.38 [302803]
              Error(TextErrorTaxMismatch,POSEntry."Entry No.");

            if (POSEntry."POS Period Register No." <> PreviousPOSPeriodRegister) and (PreviousPOSPeriodRegister <> 0) then
              Error(TextErrorMultiple,POSEntry."POS Period Register No.",PreviousPOSPeriodRegister,POSPeriodRegister.TableCaption);
            if PostingDateExists then begin
              if ReplacePostingDate or (POSEntry."Posting Date" = 0D) then begin
                POSEntry."Posting Date" := PostingDate;
                POSEntry.Validate("Currency Code");
              end;
              if ReplaceDocumentDate or (POSEntry."Document Date" = 0D) then begin
                POSEntry.Validate("Document Date",PostingDate);
              end;
            end;

            POSSalesLine.Reset;
            POSSalesLine.SetRange("POS Entry No.",POSEntry."Entry No.");
            //-NPR5.51 [362329]
            POSSalesLine.SetRange("Exclude from Posting",false);
            //+NPR5.51 [362329]
            if POSSalesLine.FindSet then repeat
              POSSalesLineToPost := POSSalesLine;
              POSSalesLineToPost.Insert;
            until POSSalesLine.Next = 0;

            POSPaymentLine.Reset;
            POSPaymentLine.SetRange("POS Entry No.",POSEntry."Entry No.");
            if POSPaymentLine.FindSet then repeat
              POSPaymentLineToPost := POSPaymentLine;
              POSPaymentLineToPost.Insert;
            until POSPaymentLine.Next = 0;

            PreviousPOSPeriodRegister := POSEntry."POS Period Register No.";
          //-NPR5.38 [301600]
          end;
          //+NPR5.38 [301600]
        until POSEntry.Next = 0;
    end;

    local procedure CreateGenJnlLinesFromPOSPostingBuffer(var POSPostingBuffer: Record "POS Posting Buffer";var GenJournalLine: Record "Gen. Journal Line")
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        POSPostingSetup: Record "POS Posting Setup";
        Currency: Record Currency;
        POSPaymentMethod: Record "POS Payment Method";
        POSStore: Record "POS Store";
        LineCount: Integer;
        NoOfRecords: Integer;
        GenPostingType: Option;
    begin
        SalesReceivablesSetup.Get;
        if ShowProgressDialog then begin
          NoOfRecords := POSPostingBuffer.Count;
          ProgressWindow.Update(4,NoOfRecords);
        end;

        if POSPostingBuffer.FindSet then repeat
          if ShowProgressDialog then begin
            LineCount := LineCount + 1;
            ProgressWindow.Update(5,Round(LineCount / NoOfRecords * 10000,1));
          end;
          if POSPostingBuffer."Currency Code" <> '' then
            Currency.Get(POSPostingBuffer."Currency Code")
          else
            Currency.Init;
          case POSPostingBuffer."Line Type" of
            POSPostingBuffer."Line Type"::Sales :
              begin
                case POSPostingBuffer.Type of
                  POSPostingBuffer.Type::Item :
                    begin
                      GeneralPostingSetup.Get(POSPostingBuffer."Gen. Bus. Posting Group",POSPostingBuffer."Gen. Prod. Posting Group");
                      GeneralPostingSetup.TestField("Sales Account");
                      if SalesReceivablesSetup."Discount Posting" in [SalesReceivablesSetup."Discount Posting"::"Line Discounts",SalesReceivablesSetup."Discount Posting"::"All Discounts"] then begin
                        MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                          Round(POSPostingBuffer.Amount + POSPostingBuffer."Discount Amount",Currency."Amount Rounding Precision"),
                          Round(POSPostingBuffer."Amount (LCY)" + POSPostingBuffer."Discount Amount (LCY)",Currency."Amount Rounding Precision"),
                          GenJournalLine."Gen. Posting Type"::Sale,
                          GenJournalLine."Account Type"::"G/L Account",
                          GeneralPostingSetup."Sales Account",
                          0,
                          '',
                          Round(POSPostingBuffer."VAT Amount" + POSPostingBuffer."VAT Amount Discount",Currency."Amount Rounding Precision"),
                          Round(POSPostingBuffer."VAT Amount (LCY)" + POSPostingBuffer."VAT Amount Discount (LCY)",Currency."Amount Rounding Precision"),
                          GenJournalLine);

                        //IF (POSPostingBuffer."Discount Amount" <> 0) OR (POSPostingBuffer."Discount Amount (LCY)" <> 0) THEN BEGIN
                        if (POSPostingBuffer."Discount Amount" <> 0) or (POSPostingBuffer."Discount Amount (LCY)" <> 0) or
                           (POSPostingBuffer."VAT Amount Discount" <> 0) or (POSPostingBuffer."VAT Amount Discount (LCY)" <> 0) then begin
                        //+NPR5.39 [302803]
                          GeneralPostingSetup.TestField("Sales Line Disc. Account");
                          MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                            Round(-POSPostingBuffer."Discount Amount",Currency."Amount Rounding Precision"),
                            Round(-POSPostingBuffer."Discount Amount (LCY)",Currency."Amount Rounding Precision"),
                            GenJournalLine."Gen. Posting Type"::Sale,
                            GenJournalLine."Account Type"::"G/L Account",
                            GeneralPostingSetup."Sales Line Disc. Account",
                            0,
                            '',
                            Round(-POSPostingBuffer."VAT Amount Discount",Currency."Amount Rounding Precision"),
                            Round(-POSPostingBuffer."VAT Amount Discount (LCY)",Currency."Amount Rounding Precision"),
                            GenJournalLine);
                        end;
                      end else begin
                        MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                           POSPostingBuffer.Amount,
                           POSPostingBuffer."Amount (LCY)" ,
                           GenJournalLine."Gen. Posting Type"::Sale,
                           GenJournalLine."Account Type"::"G/L Account",
                           GeneralPostingSetup."Sales Account",
                           0,
                           '',
                           POSPostingBuffer."VAT Amount",
                           POSPostingBuffer."VAT Amount (LCY)",
                           GenJournalLine);
                      end;
                    end;
                  POSPostingBuffer.Type::"G/L Account",POSPostingBuffer.Type::Voucher:
                    begin
                      MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                          POSPostingBuffer.Amount,
                          POSPostingBuffer."Amount (LCY)",
                          GenJournalLine."Gen. Posting Type"::Sale,
                          GenJournalLine."Account Type"::"G/L Account",
                          POSPostingBuffer."No.",
                          0,
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
                          0,
                          '',
                          POSPostingBuffer."VAT Amount",
                          POSPostingBuffer."VAT Amount (LCY)",
                          GenJournalLine);
                      //-NPR5.50 [300557]
                      SetAppliesToDocument(GenJournalLine, POSPostingBuffer);
                      //+NPR5.50 [300557]
                    end;
                  POSPostingBuffer.Type::Payout:
                    begin
                      MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                          POSPostingBuffer.Amount,
                          POSPostingBuffer."Amount (LCY)",
                          GenJournalLine."Gen. Posting Type"::Purchase,
                          GenJournalLine."Account Type"::"G/L Account",
                          POSPostingBuffer."No.",
                          0,
                          '',
                          POSPostingBuffer."VAT Amount",
                          POSPostingBuffer."VAT Amount (LCY)",
                          GenJournalLine);
                    end;
                end;
              end;

            POSPostingBuffer."Line Type"::Payment :
              begin
                //-NPR5.50 [354832]
                GenPostingType := GenJournalLine."Gen. Posting Type"::" ";
                if (POSPostingBuffer."VAT Amount (LCY)" <> 0) then
                  GenPostingType := GenJournalLine."Gen. Posting Type"::Sale;
                //+NPR5.50 [354832]

                GetPostingSetupFromBufferLine(POSPostingBuffer,POSPostingSetup);
                MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                  POSPostingBuffer.Amount,
                  POSPostingBuffer."Amount (LCY)",
                  GenPostingType, //-+NPR5.50 [354832] GenJournalLine."Gen. Posting Type"::" ",
                  GetGLAccountType(POSPostingSetup),
                  POSPostingSetup."Account No.",
                  0,
                  '',
                  POSPostingBuffer."VAT Amount",
                  POSPostingBuffer."VAT Amount (LCY)",
                  GenJournalLine);
                //-NPR5.38 [294718]
                if POSPostingBuffer."Applies-to Doc. No." <> '' then begin
                  GenJournalLine.Validate("Applies-to Doc. Type",POSPostingBuffer."Applies-to Doc. Type");
                  GenJournalLine.Validate("Applies-to Doc. No.",POSPostingBuffer."Applies-to Doc. No.");
                  GenJournalLine.Modify;
                end;
                //+NPR5.38 [294718]
                if POSPostingBuffer."Rounding Amount (LCY)" > 0 then begin
                  POSPaymentMethod.Get(POSPostingBuffer."POS Payment Method Code");
                  POSPaymentMethod.TestField("Rounding Losses Account");
                  MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                    POSPostingBuffer."Rounding Amount",
                    POSPostingBuffer."Rounding Amount (LCY)",
                    GenJournalLine."Gen. Posting Type"::" ",
                    GenJournalLine."Account Type"::"G/L Account",
                    POSPaymentMethod."Rounding Losses Account",
                    0,
                    '',
                    POSPostingBuffer."VAT Amount",
                    POSPostingBuffer."VAT Amount (LCY)",
                    GenJournalLine);
                end;
                if POSPostingBuffer."Rounding Amount (LCY)" < 0 then begin
                  POSPaymentMethod.Get(POSPostingBuffer."POS Payment Method Code");
                  POSPaymentMethod.TestField("Rounding Losses Account");
                  MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer,
                    - POSPostingBuffer."Rounding Amount",
                    - POSPostingBuffer."Rounding Amount (LCY)",
                    GenJournalLine."Gen. Posting Type"::" ",
                    GenJournalLine."Account Type"::"G/L Account",
                    POSPaymentMethod."Rounding Losses Account",
                    0,
                    '',
                    POSPostingBuffer."VAT Amount",
                    POSPostingBuffer."VAT Amount (LCY)",
                    GenJournalLine);
                end;
              end;
          end;
        until POSPostingBuffer.Next = 0;
    end;

    local procedure CreateGenJnlLinesFromPOSBalancingLines(var POSEntryIn: Record "POS Entry";var GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        POSEntry: Record "POS Entry";
        POSBalancingLine: Record "POS Balancing Line";
        POSPostingSetup: Record "POS Posting Setup";
        POSPostingSetupNewBin: Record "POS Posting Setup";
        LineCount: Integer;
        NoOfRecords: Integer;
        AmountToPostToAccount: Decimal;
    begin
        POSEntry.Copy(POSEntryIn);
        //-NPR5.38 [302777]
        //POSEntry.SETRANGE("Entry Type",POSEntry."Entry Type"::Other);
        POSEntry.SetRange("Entry Type",POSEntry."Entry Type"::Balancing);
        //+NPR5.38 [302777]

        //-NPR5.51 [359403]
        POSEntry.SetFilter (POSEntry."Post Entry Status", '<2');
        //+NPR5.51 [359403]

        if POSEntry.FindSet then repeat
          POSBalancingLine.SetRange("POS Entry No.",POSEntry."Entry No.");
          if POSBalancingLine.FindSet then repeat
            GetPostingSetupFromBalancingLine(POSBalancingLine,POSPostingSetup);

            //-NPR5.38 [302777]
            // IF POSBalancingLine."Balanced Diff. Amount" > 0 THEN BEGIN
            //  MakeGenJournalFromPOSBalancingLine(POSBalancingLine,POSBalancingLine."Balanced Diff. Amount",GetDifferenceAccountType(POSPostingSetup),POSPostingSetup."Difference Acc. No.",GenJournalLine);
            //  MakeGenJournalFromPOSBalancingLine(POSBalancingLine,-POSBalancingLine."Balanced Diff. Amount",GetGLAccountType(POSPostingSetup),POSPostingSetup."Account No.",GenJournalLine);
            // END;
            //
            // IF POSBalancingLine."Balanced Diff. Amount" < 0 THEN BEGIN
            //  MakeGenJournalFromPOSBalancingLine(POSBalancingLine,POSBalancingLine."Balanced Diff. Amount",GetDifferenceAccountType(POSPostingSetup),POSPostingSetup."Difference Acc. No. (Neg)",GenJournalLine);
            //  MakeGenJournalFromPOSBalancingLine(POSBalancingLine,-POSBalancingLine."Balanced Diff. Amount",GetGLAccountType(POSPostingSetup),POSPostingSetup."Account No.",GenJournalLine);
            // END;
            //
            // IF POSBalancingLine."Move-To Bin Amount" > 0 THEN BEGIN
            //  POSBalancingLine.TESTFIELD("Move-To Bin Code");
            //  GetPostingSetup(POSBalancingLine."POS Store Code",POSBalancingLine."POS Payment Method Code",POSBalancingLine."Move-To Bin Code",POSPostingSetupNewBin);
            //  IF (POSPostingSetup."Account Type" <> POSPostingSetupNewBin."Account Type") OR (POSPostingSetup."Account No." <> POSPostingSetupNewBin."Account No.") THEN BEGIN
            //    //Make posting only if the account is different for the new Bin
            //    MakeGenJournalFromPOSBalancingLine(POSBalancingLine,-POSBalancingLine."Move-To Bin Amount",GetGLAccountType(POSPostingSetup),POSPostingSetup."Account No.",GenJournalLine);
            //    MakeGenJournalFromPOSBalancingLine(POSBalancingLine,POSBalancingLine."Move-To Bin Amount",GetGLAccountType(POSPostingSetupNewBin),POSPostingSetupNewBin."Account No.",GenJournalLine);
            //  END;
            // END;
            //
            // IF POSBalancingLine."Deposit-To Bin Amount" > 0 THEN BEGIN
            //  POSBalancingLine.TESTFIELD("Deposit-To Bin Code");
            //  GetPostingSetup(POSBalancingLine."POS Store Code",POSBalancingLine."POS Payment Method Code",POSBalancingLine."Deposit-To Bin Code",POSPostingSetupNewBin);
            //  IF (POSPostingSetup."Account Type" <> POSPostingSetupNewBin."Account Type") OR (POSPostingSetup."Account No." <> POSPostingSetupNewBin."Account No.") THEN BEGIN
            //    MakeGenJournalFromPOSBalancingLine(POSBalancingLine,-POSBalancingLine."Deposit-To Bin Amount",GetGLAccountType(POSPostingSetup),POSPostingSetup."Account No.",GenJournalLine);
            //    MakeGenJournalFromPOSBalancingLine(POSBalancingLine,POSBalancingLine."Deposit-To Bin Amount",GetGLAccountType(POSPostingSetupNewBin),POSPostingSetupNewBin."Account No.",GenJournalLine);
            //  END;
            // END;
            POSPostingSetup.TestField("Account No.");
            AmountToPostToAccount := 0;
            if POSBalancingLine."Balanced Diff. Amount" > 0 then begin
              POSPostingSetup.TestField("Difference Acc. No.");
              MakeGenJournalFromPOSBalancingLine(POSBalancingLine,POSBalancingLine."Balanced Diff. Amount",GetDifferenceAccountType(POSPostingSetup),POSPostingSetup."Difference Acc. No.",POSBalancingLine.Description,GenJournalLine);
            end;
            if POSBalancingLine."Balanced Diff. Amount" < 0 then begin
              POSPostingSetup.TestField("Difference Acc. No. (Neg)");
              MakeGenJournalFromPOSBalancingLine(POSBalancingLine,POSBalancingLine."Balanced Diff. Amount",GetDifferenceAccountType(POSPostingSetup),POSPostingSetup."Difference Acc. No. (Neg)",POSBalancingLine.Description,GenJournalLine);
            end;
            AmountToPostToAccount := - POSBalancingLine."Balanced Diff. Amount";

            if POSBalancingLine."Move-To Bin Amount" > 0 then begin
              POSBalancingLine.TestField("Move-To Bin Code");
              if not GetPostingSetup(POSBalancingLine."POS Store Code",POSBalancingLine."POS Payment Method Code",POSBalancingLine."Move-To Bin Code",POSPostingSetupNewBin) then
                //-+NPR5.45 [322769] ERROR(TextPostingSetupMissing,POSPostingSetup.TABLECAPTION,POSBalancingLine.TABLECAPTION,POSBalancingLine.FIELDCAPTION("POS Entry No."),POSBalancingLine."POS Entry No.");
                Error(TextPostingSetupMissing,POSPostingSetup.TableCaption,POSBalancingLine.TableCaption,POSBalancingLine.FieldCaption("POS Entry No."),POSBalancingLine."POS Entry No.",
                  StrSubstNo ('%1: %4, %2: %5, %3: %6',POSBalancingLine.FieldCaption ("POS Store Code"),POSBalancingLine.FieldCaption ("POS Payment Method Code"),POSBalancingLine.FieldCaption ("Move-To Bin Code"),
                                                       POSBalancingLine."POS Store Code", POSBalancingLine."POS Payment Method Code", POSBalancingLine."Move-To Bin Code"));

              if (POSPostingSetup."Account Type" <> POSPostingSetupNewBin."Account Type") or (POSPostingSetup."Account No." <> POSPostingSetupNewBin."Account No.") then begin
                //Make posting only if the account is different for the new Bin
                AmountToPostToAccount := AmountToPostToAccount - POSBalancingLine."Move-To Bin Amount";
                POSPostingSetupNewBin.TestField("Account No.");
                MakeGenJournalFromPOSBalancingLine(POSBalancingLine,POSBalancingLine."Move-To Bin Amount",GetGLAccountType(POSPostingSetupNewBin),POSPostingSetupNewBin."Account No.",POSBalancingLine."Move-To Reference",GenJournalLine);
              end;
            end;

            if POSBalancingLine."Deposit-To Bin Amount" > 0 then begin
              POSBalancingLine.TestField("Deposit-To Bin Code");
              if not GetPostingSetup(POSBalancingLine."POS Store Code",POSBalancingLine."POS Payment Method Code",POSBalancingLine."Deposit-To Bin Code",POSPostingSetupNewBin) then
                //-+NPR5.45 [322769] ERROR(TextPostingSetupMissing,POSPostingSetup.TABLECAPTION,POSBalancingLine.TABLECAPTION,POSBalancingLine.FIELDCAPTION("POS Entry No."),POSBalancingLine."POS Entry No.");
                Error(TextPostingSetupMissing,POSPostingSetup.TableCaption,POSBalancingLine.TableCaption,POSBalancingLine.FieldCaption("POS Entry No."),POSBalancingLine."POS Entry No.",
                  StrSubstNo ('%1: %4, %2: %5, %3: %6',POSBalancingLine.FieldCaption ("POS Store Code"),POSBalancingLine.FieldCaption ("POS Payment Method Code"),POSBalancingLine.FieldCaption ("Deposit-To Bin Code"),
                                                       POSBalancingLine."POS Store Code", POSBalancingLine."POS Payment Method Code", POSBalancingLine."Deposit-To Bin Code"));

              if (POSPostingSetup."Account Type" <> POSPostingSetupNewBin."Account Type") or (POSPostingSetup."Account No." <> POSPostingSetupNewBin."Account No.") then begin
                AmountToPostToAccount := AmountToPostToAccount - POSBalancingLine."Deposit-To Bin Amount";
                POSPostingSetupNewBin.TestField("Account No.");
                MakeGenJournalFromPOSBalancingLine(POSBalancingLine,POSBalancingLine."Deposit-To Bin Amount",GetGLAccountType(POSPostingSetupNewBin),POSPostingSetupNewBin."Account No.",POSBalancingLine."Deposit-To Reference",GenJournalLine);
              end;
            end;

            if POSBalancingLine."New Float Amount" <> 0 then
              MakeGenJournalFromPOSBalancingLine(POSBalancingLine,POSBalancingLine."New Float Amount",GetGLAccountType(POSPostingSetup),POSPostingSetup."Account No.",StrSubstNo(TextClosingEntryFloat,POSEntry."Entry No."),GenJournalLine);
            AmountToPostToAccount := AmountToPostToAccount - POSBalancingLine."New Float Amount";

            if AmountToPostToAccount <> 0 then
              MakeGenJournalFromPOSBalancingLine(POSBalancingLine,AmountToPostToAccount,GetGLAccountType(POSPostingSetup),POSPostingSetup."Account No.",POSBalancingLine.Description,GenJournalLine);
            //+NPR5.38 [302777]
          until POSBalancingLine.Next = 0;
        until POSEntry.Next = 0;
    end;

    local procedure PostItemEntries(var POSEntry: Record "POS Entry")
    var
        POSPostItemEntries: Codeunit "POS Post Item Entries";
        POSAuditRollIntegration: Codeunit "POS-Audit Roll Integration";
        LineCount: Integer;
        NoOfRecords: Integer;
    begin
        if ShowProgressDialog then begin
          NoOfRecords := POSEntry.Count;
          ProgressWindow.Update(10,NoOfRecords);
        end;
        if POSEntry.FindSet then repeat
          if ShowProgressDialog then begin
            LineCount := LineCount + 1;
            ProgressWindow.Update(11,Round(LineCount / NoOfRecords * 10000,1));
          end;
          if  (POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::Unposted,POSEntry."Post Item Entry Status"::"Error while Posting"]) then begin
            //-NPR5.38 [301600]
            POSAuditRollIntegration.CheckPostingStatusFromPOSEntry(POSEntry,true,false);
            //+NPR5.38 [301600]
            if PostingDateExists then
              POSPostItemEntries.SetPostingDate(ReplaceDocumentDate,ReplaceDocumentDate,PostingDate);

            if StopOnErrorVar then begin
              POSPostItemEntries.Run(POSEntry);
              POSEntry.Validate("Post Item Entry Status",POSEntry."Post Item Entry Status"::Posted);
              POSEntry.Modify;
            end else begin
              if POSPostItemEntries.Run(POSEntry) then begin
                POSEntry.Validate("Post Item Entry Status",POSEntry."Post Item Entry Status"::Posted);
              end else begin
                POSEntry.Validate("Post Item Entry Status",POSEntry."Post Item Entry Status"::"Error while Posting");
              end;
              POSEntry.Modify;
              Commit;
            end;
          end;
        until POSEntry.Next = 0;
    end;

    local procedure CheckandPostGenJournal(var GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        GenJournalLine.Reset;
        GenJournalLine.SetCurrentKey("Journal Template Name","Journal Batch Name","Posting Date","Document No.");
        //-NPR5.38 [285957]
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
          //+NPR5.38 [285957]
        if GenJournalLine.FindSet then begin
          repeat
            GenJournalLine.SetRange("Posting Date",GenJournalLine."Posting Date");
            GenJournalLine.SetRange("Document No.",GenJournalLine."Document No.");
            if not CheckandPostGenJournalDocument(GenJournalLine) then
              exit(false);
            GenJournalLine.FindLast;
            GenJournalLine.SetRange("Posting Date");
            GenJournalLine.SetRange("Document No.");
          until GenJournalLine.Next = 0;
        end;
        exit(true);
    end;

    local procedure CheckandPostGenJournalDocument(var GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        TempGenJournalLine2: Record "Gen. Journal Line" temporary;
        NPRetailSetup: Record "NP Retail Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DifferenceAmount: Decimal;
    begin
        DifferenceAmount := 0;
        if GenJournalLine.FindSet then repeat
          DifferenceAmount := DifferenceAmount + GenJournalLine."Amount (LCY)" + GenJournalLine."VAT Amount (LCY)";
        until GenJournalLine.Next = 0;

        if (Abs(DifferenceAmount) > 0) then begin
          NPRetailSetup.Get;
          if (Abs(DifferenceAmount) > NPRetailSetup."Max. POS Posting Diff. (LCY)") then begin
            ErrorText := StrSubstNo(TextImbalance,GenJournalLine.FieldCaption("Document No."),GenJournalLine."Document No.",GenJournalLine.FieldCaption("Posting Date"),GenJournalLine."Posting Date",DifferenceAmount);
            if StopOnErrorVar then
              Error(ErrorText)
            else
              exit(false);
          end;
          NPRetailSetup.TestField("POS Posting Diff. Account");
          MakeGenJournalLine(
            0,
            NPRetailSetup."POS Posting Diff. Account",
            0,
            '',
            0,
            GenJournalLine."Posting Date",
            GenJournalLine."Document No.",
            //-NPR5.39 [304739]
            //'',
            TextPostingDifference,
            //+NPR5.39 [304739]
            0,
            '',
            - DifferenceAmount,
            - DifferenceAmount,
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
        //  COMMIT;//TEMP Debugging
        //  PAGE.RUNMODAL(50121,GenJournalLine);//TEMP Debugging
        if GenJournalLine.FindSet then repeat
          //IF GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::Sale THEN
          //   ERROR('Remove');
          //REMOVE
          //GenJournalLine2 := GenJournalLine;
          //GenJournalLine2.INSERT;
          //REMOVE
          //-NPR5.38 [285957]

          GenJnlPostLine.Run(GenJournalLine);
          //IF StopOnErrorVar THEN BEGIN
          //  GenJnlPostLine.RUN(GenJournalLine);
          //END ELSE BEGIN
          //  IF NOT GenJnlPostLine.RUN(GenJournalLine) THEN BEGIN
          //    ErrorText := GETLASTERRORTEXT;
          //    EXIT(FALSE);
          //  END;
          //END;
          //+NPR5.38 [285957]
        until GenJournalLine.Next = 0;
        exit(true);
    end;

    procedure SetPostingDate(NewReplacePostingDate: Boolean;NewReplaceDocumentDate: Boolean;NewPostingDate: Date)
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

    procedure CheckPOSTaxAmountLines(var POSEntry: Record "POS Entry";ThrowError: Boolean) Result: Boolean
    begin
        //-NPR5.41 [311309]
        ClearLastError();
        Result := TryCheckPOSTaxAmountLines(POSEntry);
        if (not Result) and ThrowError then
          Error(GetLastErrorText);
        //+NPR5.41 [311309]
    end;

    [TryFunction]
    local procedure TryCheckPOSTaxAmountLines(var POSEntry: Record "POS Entry")
    var
        POSTaxAmountLine: Record "POS Tax Amount Line";
        TempPOSTaxAmountLine: Record "POS Tax Amount Line" temporary;
        POSSalesLine: Record "POS Sales Line";
        TempPOSSalesLine: Record "POS Sales Line" temporary;
        Currency: Record Currency;
        SalesAmountIncludingTax: Decimal;
        TaxAmountSalesLines: Decimal;
        RemSalesTaxAmt: Decimal;
        TaxJurisdiction: Record "Tax Jurisdiction";
    begin
        if POSEntry."Currency Code" <>  '' then
          Currency.Get(POSEntry."Currency Code")
        else
          Currency.Init;
        TaxAmountSalesLines := 0;
        
        POSTaxAmountLine.SetRange("POS Entry No.",POSEntry."Entry No.");
        if POSTaxAmountLine.FindSet then repeat
          if POSTaxAmountLine."Tax Calculation Type" = POSTaxAmountLine."Tax Calculation Type"::"Sales Tax" then begin
        //-NPR5.41 [311309]
        //    TempPOSTaxAmountLine."Tax Amount" += POSTaxAmountLine."Tax Amount";
        //  END ELSE BEGIN
        //    TempPOSTaxAmountLine."Tax Amount" += POSTaxAmountLine."Tax Amount";
        //    TempPOSTaxAmountLine."Amount Including Tax" += POSTaxAmountLine."Amount Including Tax";
        //    TempPOSTaxAmountLine."Tax Base Amount" += POSTaxAmountLine."Tax Base Amount";
            if POSTaxAmountLine."Tax Jurisdiction Code" <> TaxJurisdiction.Code then begin
              TaxJurisdiction.Get(POSTaxAmountLine."Tax Jurisdiction Code");
              //IF SalesTaxCountry = SalesTaxCountry::CA THEN BEGIN
                RemSalesTaxAmt := 0;
              //END;
            end;
            RemSalesTaxAmt := RemSalesTaxAmt + POSTaxAmountLine."Tax Amount";
            TempPOSTaxAmountLine."Tax Amount" += Round(RemSalesTaxAmt);
            RemSalesTaxAmt := RemSalesTaxAmt - Round(RemSalesTaxAmt);
          end else begin
            TempPOSTaxAmountLine."Tax Amount" += Round(POSTaxAmountLine."Tax Amount", Currency."Amount Rounding Precision");
            TempPOSTaxAmountLine."Amount Including Tax" += Round(POSTaxAmountLine."Amount Including Tax", Currency."Amount Rounding Precision");
            TempPOSTaxAmountLine."Tax Base Amount" += Round(POSTaxAmountLine."Tax Base Amount", Currency."Amount Rounding Precision");
        //+NPR5.41 [311309]
          end;
        until POSTaxAmountLine.Next = 0;
        //-NPR5.41 [311309]
        // TempPOSTaxAmountLine."Amount Including Tax" := ROUND(TempPOSTaxAmountLine."Amount Including Tax",Currency."Amount Rounding Precision");
        // TempPOSTaxAmountLine."Tax Base Amount" := ROUND(TempPOSTaxAmountLine."Tax Base Amount",Currency."Amount Rounding Precision");
        // TempPOSTaxAmountLine."Tax Amount" := ROUND(TempPOSTaxAmountLine."Tax Amount",Currency."Amount Rounding Precision");
        //+NPR5.41 [311309]
        
        /*
        IF TempSalesTaxAmtLine."Tax Amount" <> 0 THEN BEGIN
          RemSalesTaxAmt := RemSalesTaxAmt + TempSalesTaxAmtLine."Tax Amount";
          GenJnlLine."VAT Amount (LCY)" := ROUND(RemSalesTaxAmt,GLSetup."Amount Rounding Precision");
          RemSalesTaxAmt := RemSalesTaxAmt - GenJnlLine."VAT Amount (LCY)";
          GenJnlLine."VAT Amount" := GenJnlLine."VAT Amount (LCY)";
        END;
        */
        
        POSSalesLine.SetRange("POS Entry No.",POSEntry."Entry No.");
        //-NPR5.38 [302803]
        
        //-NPR5.51 [347057]
        // //-NPR5.41 [306394]
        // // POSSalesLine.SETFILTER(Type,'<>%1',POSSalesLine.Type::Payout);
        // POSSalesLine.SETFILTER(Type,'<>%1&<>%2',POSSalesLine.Type::Payout, POSSalesLine.Type::Rounding);
        // //+NPR5.41 [306394]
        POSSalesLine.SetFilter(Type,'<>%1', POSSalesLine.Type::Rounding);
        //+NPR5.51 [347057]
        
        //+NPR5.38 [302803]
        //-NPR5.51 [362329]
        POSSalesLine.SetRange("Exclude from Posting",false);
        //+NPR5.51 [362329]
        if POSSalesLine.FindSet then repeat
          if POSSalesLine."VAT Calculation Type" = POSSalesLine."VAT Calculation Type"::"Sales Tax" then begin
            TaxAmountSalesLines := TaxAmountSalesLines + (POSSalesLine."Amount Incl. VAT" -POSSalesLine."Amount Excl. VAT");
          end else begin
            TaxAmountSalesLines := TaxAmountSalesLines + (POSSalesLine."Amount Incl. VAT" -POSSalesLine."Amount Excl. VAT");
            TempPOSSalesLine."Amount Incl. VAT" += POSSalesLine."Amount Incl. VAT";
            TempPOSSalesLine."Amount Excl. VAT" += POSSalesLine."Amount Excl. VAT";
          end;
        until POSSalesLine.Next = 0;
        
        //-NPR5.41 [311309]
        // TempPOSSalesLine."Amount Incl. VAT" := ROUND(TempPOSSalesLine."Amount Incl. VAT",Currency."Amount Rounding Precision");
        // TempPOSSalesLine."Amount Excl. VAT" := ROUND(TempPOSSalesLine."Amount Excl. VAT",Currency."Amount Rounding Precision");
        // TaxAmountSalesLines := ROUND(TaxAmountSalesLines,Currency."Amount Rounding Precision");
        //
        // IF TempPOSTaxAmountLine."Tax Amount" <> TaxAmountSalesLines THEN
        //  IF ShowError THEN
        //    ERROR(TextSalesTaxDiscrepancy,TempPOSTaxAmountLine.FIELDCAPTION("Tax Amount"),TaxAmountSalesLines,TempPOSTaxAmountLine."Tax Amount")
        //  ELSE
        //    EXIT(FALSE);
        // IF TempPOSTaxAmountLine."Amount Including Tax" <> TempPOSSalesLine."Amount Incl. VAT"  THEN
        //  IF ShowError THEN
        //    ERROR(TextSalesTaxDiscrepancy,TempPOSTaxAmountLine.FIELDCAPTION("Amount Including Tax"),TempPOSSalesLine."Amount Incl. VAT",TempPOSTaxAmountLine."Amount Including Tax")
        //  ELSE
        //    EXIT(FALSE);
        //
        // IF TempPOSTaxAmountLine."Tax Base Amount" <> TempPOSSalesLine."Amount Excl. VAT" THEN
        //  IF ShowError THEN
        //    ERROR(TextSalesTaxDiscrepancy,TempPOSTaxAmountLine.FIELDCAPTION("Tax Base Amount"),TempPOSSalesLine."Amount Excl. VAT",TempPOSTaxAmountLine."Tax Base Amount")
        //  ELSE
        //    EXIT(FALSE);
        //
        //  EXIT(TRUE);
        
        if TempPOSTaxAmountLine."Tax Amount" <> TaxAmountSalesLines then
          Error(TextSalesTaxDiscrepancy,TempPOSTaxAmountLine.FieldCaption("Tax Amount"),TaxAmountSalesLines,TempPOSTaxAmountLine."Tax Amount");
        if TempPOSTaxAmountLine."Amount Including Tax" <> TempPOSSalesLine."Amount Incl. VAT"  then
          Error(TextSalesTaxDiscrepancy,TempPOSTaxAmountLine.FieldCaption("Amount Including Tax"),TempPOSSalesLine."Amount Incl. VAT",TempPOSTaxAmountLine."Amount Including Tax");
        if TempPOSTaxAmountLine."Tax Base Amount" <> TempPOSSalesLine."Amount Excl. VAT" then
          Error(TextSalesTaxDiscrepancy,TempPOSTaxAmountLine.FieldCaption("Tax Base Amount"),TempPOSSalesLine."Amount Excl. VAT",TempPOSTaxAmountLine."Tax Base Amount");
        //+NPR5.41 [311309]

    end;

    local procedure CreatePostingBufferLinesFromPOSSalesLines(var POSSalesLineToBeCompressed: Record "POS Sales Line";var POSPostingBuffer: Record "POS Posting Buffer";PostCompressed: Boolean)
    var
        POSPeriodRegister: Record "POS Period Register";
        POSEntry: Record "POS Entry";
        PostingDescription: Text;
        Compressionmethod: Option Uncompressed,"Per POS Entry","Per POS Period Register";
        cnt: Integer;
    begin
        if POSSalesLineToBeCompressed.FindSet then repeat

          POSEntry.Get(POSSalesLineToBeCompressed."POS Entry No.");
          POSPeriodRegister.Get(POSEntry."POS Period Register No.");
          Compressionmethod := GetCompressionMethod(POSPeriodRegister,PostCompressedVar);
          //-NPR5.39 [304901]
          //IF Compressionmethod <>  Compressionmethod::Uncompressed THEN
          if Compressionmethod = Compressionmethod::"Per POS Period Register" then
          //+NPR5.39 [304901]
            if POSSalesLineToBeCompressed."VAT Calculation Type" = POSSalesLineToBeCompressed."VAT Calculation Type"::"Sales Tax" then
              Error(TextErrorSalesTaxCompressed,POSEntry.TableCaption,POSSalesLineToBeCompressed."POS Entry No.");

          Clear(POSPostingBuffer);
          POSPostingBuffer.Init;

          POSPostingBuffer."Posting Date" := POSEntry."Posting Date";
          POSPostingBuffer."Line Type" := POSPostingBuffer."Line Type"::Sales;
          POSPostingBuffer.Type := POSSalesLineToBeCompressed.Type;
          //-NPR5.39 [302803]
          //POSPostingBuffer.Type := POSSalesLineToBeCompressed.Type;
          case POSSalesLineToBeCompressed.Type of
            POSSalesLineToBeCompressed.Type::Rounding :
              //-NPR5.41 [306394]
              // POSPostingBuffer.Type := POSPostingBuffer.Type::"G/L Account";
                begin
                  POSPostingBuffer.Type := POSPostingBuffer.Type::"G/L Account";
                  POSPostingBuffer."No." := POSSalesLineToBeCompressed."No.";
                end;
                //+NPR5.41 [306394]
            else
              POSPostingBuffer.Type := POSSalesLineToBeCompressed.Type;
          end;
          //+NPR5.39 [302803]
          if POSSalesLineToBeCompressed.Type in [POSSalesLineToBeCompressed.Type::"G/L Account",POSSalesLineToBeCompressed.Type::Customer,POSSalesLineToBeCompressed.Type::Voucher] then
            POSPostingBuffer."No." := POSSalesLineToBeCompressed."No.";
          if POSSalesLineToBeCompressed.Type <> POSSalesLineToBeCompressed.Type::Customer then begin
            POSPostingBuffer."Gen. Bus. Posting Group" := POSSalesLineToBeCompressed."Gen. Bus. Posting Group";
            POSPostingBuffer."VAT Bus. Posting Group" := POSSalesLineToBeCompressed."VAT Bus. Posting Group";
          end;
          //-NPR5.38 [302693]
          if POSSalesLineToBeCompressed.Type = POSSalesLineToBeCompressed.Type::Payout then begin
            POSPostingBuffer."No." := POSSalesLineToBeCompressed."No.";
          end;
          //+NPR5.38 [302693]
          //-NPR5.50 [300557]
          POSPostingBuffer."Applies-to Doc. Type" := POSSalesLineToBeCompressed."Applies-to Doc. Type";
          POSPostingBuffer."Applies-to Doc. No." := POSSalesLineToBeCompressed."Applies-to Doc. No.";
          //+NPR5.50 [300557]
          POSPostingBuffer."Gen. Prod. Posting Group" := POSSalesLineToBeCompressed."Gen. Prod. Posting Group";
          POSPostingBuffer."VAT Prod. Posting Group" := POSSalesLineToBeCompressed."VAT Prod. Posting Group";
          POSPostingBuffer."Global Dimension 1 Code" := POSSalesLineToBeCompressed."Shortcut Dimension 1 Code";
          POSPostingBuffer."Global Dimension 2 Code" := POSSalesLineToBeCompressed."Shortcut Dimension 2 Code";
          POSPostingBuffer."Dimension Set ID" := POSSalesLineToBeCompressed."Dimension Set ID" ;
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
            Compressionmethod::Uncompressed :
              begin
                POSPostingBuffer."POS Entry No." := POSSalesLineToBeCompressed."POS Entry No.";
                POSPostingBuffer."Line No." := POSSalesLineToBeCompressed."Line No.";
                POSPostingBuffer."No." := POSSalesLineToBeCompressed."No.";
                if POSPeriodRegister."Document No." = '' then
                  POSPostingBuffer."Document No."  := POSSalesLineToBeCompressed."Document No."
                else
                  POSPostingBuffer."Document No."  := POSPeriodRegister."Document No.";
                PostingDescription := POSSalesLineToBeCompressed.Description;
              end;
            Compressionmethod::"Per POS Entry" :
              begin
                POSPostingBuffer."POS Entry No." := POSSalesLineToBeCompressed."POS Entry No.";
                if POSPeriodRegister."Document No." = '' then
                  POSPostingBuffer."Document No."  := POSSalesLineToBeCompressed."Document No."
                else
                  POSPostingBuffer."Document No."  := POSPeriodRegister."Document No.";
                PostingDescription := StrSubstNo(TextDesc,POSEntry.TableCaption,POSSalesLineToBeCompressed."POS Entry No.");
              end;
            Compressionmethod::"Per POS Period Register" :
              begin
                POSPeriodRegister.TestField("Document No.");
                POSPostingBuffer."Document No." := POSPeriodRegister."Document No.";
                PostingDescription := StrSubstNo(TextDesc,POSPeriodRegister.TableCaption,POSSalesLineToBeCompressed."POS Period Register No.");
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
            POSPostingBuffer.Description := CopyStr(PostingDescription,1,MaxStrLen(POSPostingBuffer.Description));
            POSPostingBuffer.Insert;
          end;
          POSPostingBuffer."VAT Base Amount" := POSPostingBuffer."VAT Base Amount" - POSSalesLineToBeCompressed."VAT Base Amount";
          POSPostingBuffer.Quantity := POSPostingBuffer.Quantity + POSSalesLineToBeCompressed.Quantity;
          POSPostingBuffer."VAT Difference" := POSPostingBuffer."VAT Difference" - POSSalesLineToBeCompressed."VAT Difference";
          POSPostingBuffer."VAT Amount" := POSPostingBuffer."VAT Amount" - (POSSalesLineToBeCompressed."Amount Incl. VAT" - POSSalesLineToBeCompressed."Amount Excl. VAT");
          POSPostingBuffer."VAT Amount (LCY)" := POSPostingBuffer."VAT Amount (LCY)" - (POSSalesLineToBeCompressed."Amount Incl. VAT (LCY)" - POSSalesLineToBeCompressed."Amount Excl. VAT (LCY)");
          //POSPostingBuffer."Discount Amount" := POSPostingBuffer."Discount Amount" - POSSalesLineToBeCompressed."Line Discount Amount Incl. VAT";
          //POSPostingBuffer."Discount Amount (LCY)" := POSPostingBuffer."Discount Amount (LCY)" - POSSalesLineToBeCompressed."Line Dsc. Amt. Incl. VAT (LCY)";
          POSPostingBuffer."Discount Amount" := POSPostingBuffer."Discount Amount" - POSSalesLineToBeCompressed."Line Discount Amount Excl. VAT";
          POSPostingBuffer."Discount Amount (LCY)" := POSPostingBuffer."Discount Amount (LCY)" - POSSalesLineToBeCompressed."Line Dsc. Amt. Excl. VAT (LCY)";
          POSPostingBuffer.Amount := POSPostingBuffer.Amount - POSSalesLineToBeCompressed."Amount Excl. VAT";
          POSPostingBuffer."Amount (LCY)" := POSPostingBuffer."Amount (LCY)" - POSSalesLineToBeCompressed."Amount Excl. VAT (LCY)";
          POSPostingBuffer."VAT Amount Discount" := POSPostingBuffer."VAT Amount Discount" - (POSSalesLineToBeCompressed."Line Discount Amount Incl. VAT" - POSSalesLineToBeCompressed."Line Discount Amount Excl. VAT");
          POSPostingBuffer."VAT Amount Discount (LCY)" := POSPostingBuffer."VAT Amount Discount (LCY)" - (POSSalesLineToBeCompressed."Line Dsc. Amt. Incl. VAT (LCY)" - POSSalesLineToBeCompressed."Line Dsc. Amt. Excl. VAT (LCY)");
          POSPostingBuffer.Modify;
        until POSSalesLineToBeCompressed.Next = 0;
    end;

    local procedure CreatePostingBufferLinesFromPOSSPaymentLines(var POSPaymentLineToBeCompressed: Record "POS Payment Line";var POSPostingBuffer: Record "POS Posting Buffer";PostCompressed: Boolean)
    var
        POSPeriodRegister: Record "POS Period Register";
        POSEntry: Record "POS Entry";
        POSPaymentMethod: Record "POS Payment Method";
        PostingDescription: Text;
        Compressionmethod: Option Uncompressed,"Per POS Entry","Per POS Period Register";
    begin
        if POSPaymentLineToBeCompressed.FindSet then repeat

          POSEntry.Get(POSPaymentLineToBeCompressed."POS Entry No.");
          POSPeriodRegister.Get(POSEntry."POS Period Register No.");
          Compressionmethod := GetCompressionMethod(POSPeriodRegister,PostCompressedVar);

          Clear(POSPostingBuffer);
          POSPostingBuffer.Init;

          POSPostingBuffer."Posting Date" := POSEntry."Posting Date";
          POSPostingBuffer."Line Type" := POSPostingBuffer."Line Type"::Payment;
          POSPostingBuffer."No." := POSPaymentLineToBeCompressed."POS Payment Method Code";
          POSPostingBuffer."POS Payment Method Code" := POSPaymentLineToBeCompressed."POS Payment Method Code";
          POSPostingBuffer."Global Dimension 1 Code" := POSPaymentLineToBeCompressed."Shortcut Dimension 1 Code";
          POSPostingBuffer."Global Dimension 2 Code" := POSPaymentLineToBeCompressed."Shortcut Dimension 2 Code";
          POSPostingBuffer."Dimension Set ID" := POSPaymentLineToBeCompressed."Dimension Set ID" ;
          POSPostingBuffer."Salesperson Code" := POSEntry."Salesperson Code";
          POSPostingBuffer."Currency Code" := POSPaymentLineToBeCompressed."Currency Code";
          POSPostingBuffer."POS Store Code" := POSPaymentLineToBeCompressed."POS Store Code";
          POSPostingBuffer."POS Unit No." := POSPaymentLineToBeCompressed."POS Unit No.";
          POSPostingBuffer."POS Period Register" := POSPaymentLineToBeCompressed."POS Period Register No.";
          POSPostingBuffer."POS Payment Bin Code" := POSPaymentLineToBeCompressed."POS Payment Bin Code";

          //-NPR5.38 [294718]
          POSPostingBuffer."Applies-to Doc. Type" := POSPostingBuffer."Applies-to Doc. Type";
          POSPostingBuffer."Applies-to Doc. No." := POSPostingBuffer."Applies-to Doc. No.";
          //+NPR5.38 [294718]

          //-NPR5.50 [354832]
          POSPostingBuffer."VAT Prod. Posting Group" := POSPaymentLineToBeCompressed."VAT Prod. Posting Group";
          POSPostingBuffer."VAT Bus. Posting Group" := POSPaymentLineToBeCompressed."VAT Bus. Posting Group";
          //+NPR5.50 [354832]

          PostingDescription := '';
          if POSPaymentMethod.Get(POSPaymentLineToBeCompressed."POS Payment Method Code") then begin
            if not POSPaymentMethod."Post Condensed" then begin
              POSPostingBuffer."POS Entry No." := POSPaymentLineToBeCompressed."POS Entry No.";
              POSPostingBuffer."Line No." := POSPaymentLineToBeCompressed."Line No.";
              //-NPR5.38 [294720]
              POSPostingBuffer."External Document No." := POSPaymentLineToBeCompressed."External Document No.";
              //+NPR5.38 [294720]

              //-NPR5.51 [359403]
              // PostingDescription := POSPaymentLineToBeCompressed.Description;
              //+NPR5.51 [359403]

            end else begin
              //-NPR5.38 [294722]
              if POSPaymentMethod."Condensed Posting Description" <> '' then
                PostingDescription := CopyStr(StrSubstNo(POSPaymentMethod."Condensed Posting Description",
                       POSPaymentLineToBeCompressed."POS Unit No.",
                       POSPaymentLineToBeCompressed."POS Store Code",
                       POSEntry."Posting Date",
                       POSEntry."POS Period Register No.",
                       POSPaymentLineToBeCompressed."POS Payment Bin Code"
                       ),1,MaxStrLen(POSPostingBuffer.Description))
              else
              //+NPR5.38 [294722]
                PostingDescription := CopyStr(StrSubstNo(TextPaymentDescription,POSPaymentMethod.Code,POSEntry."Posting Date"),1,MaxStrLen(POSPostingBuffer.Description));
            end;
          end;

          case Compressionmethod of
            Compressionmethod::Uncompressed :
              begin
                POSPostingBuffer."POS Payment Bin Code" := POSPaymentLineToBeCompressed."POS Payment Bin Code";
                POSPostingBuffer."POS Entry No." := POSPaymentLineToBeCompressed."POS Entry No.";
                POSPostingBuffer."Line No." := POSPaymentLineToBeCompressed."Line No.";
                if POSPeriodRegister."Document No." = '' then
                  POSPostingBuffer."Document No." := POSPaymentLineToBeCompressed."Document No."
                else
                  POSPostingBuffer."Document No."  := POSPeriodRegister."Document No.";
                if (PostingDescription = '') then //-+NPR5.51 [359403]
                  PostingDescription := POSPaymentLineToBeCompressed.Description;
              end;
            Compressionmethod::"Per POS Entry":
              begin
                POSPostingBuffer."POS Entry No." := POSPaymentLineToBeCompressed."POS Entry No.";
                if POSPeriodRegister."Document No." = '' then
                  POSPostingBuffer."Document No." := POSPaymentLineToBeCompressed."Document No."
                else
                  POSPostingBuffer."Document No."  := POSPeriodRegister."Document No.";
                if (PostingDescription = '') then //-+NPR5.51 [359403]
                  PostingDescription := StrSubstNo(TextDesc,POSEntry.TableCaption,POSPaymentLineToBeCompressed."POS Entry No.");
              end;
            Compressionmethod::"Per POS Period Register":
              begin
                POSPeriodRegister.TestField("Document No.");
                POSPostingBuffer."Document No." := POSPeriodRegister."Document No.";
                if (PostingDescription = '') then //-+NPR5.51 [359403]
                  PostingDescription := StrSubstNo(TextDesc,POSPeriodRegister.TableCaption,POSPaymentLineToBeCompressed."POS Period Register No.");
              end;
          end;

          if not POSPostingBuffer.Find then begin
            POSPostingBuffer.Amount := 0;
            POSPostingBuffer."Amount (LCY)" := 0;
            POSPostingBuffer."Rounding Amount" := 0;
            POSPostingBuffer."Rounding Amount (LCY)" := 0;
            POSPostingBuffer.Description := CopyStr(PostingDescription,1,MaxStrLen(POSPostingBuffer.Description));
            //-NPR5.50 [354832]
            POSPostingBuffer."VAT Amount (LCY)" := 0;
            POSPostingBuffer."VAT Base Amount" := 0;
            //+NPR5.50 [354832]

            POSPostingBuffer.Insert;
          end;

          POSPostingBuffer."Rounding Amount" := POSPostingBuffer."Rounding Amount" + POSPaymentLineToBeCompressed."Rounding Amount";
          POSPostingBuffer."Rounding Amount (LCY)" := POSPostingBuffer."Rounding Amount" + POSPaymentLineToBeCompressed."Rounding Amount (LCY)";

          //-NPR5.50 [354832]
          // POSPostingBuffer.Amount := POSPostingBuffer.Amount + POSPaymentLineToBeCompressed.Amount;
          //POSPostingBuffer."Amount (LCY)" := POSPostingBuffer."Amount (LCY)" + POSPaymentLineToBeCompressed."Amount (LCY)";

          POSPostingBuffer.Amount := POSPostingBuffer.Amount + POSPaymentLineToBeCompressed.Amount - POSPaymentLineToBeCompressed."VAT Amount (LCY)";
          POSPostingBuffer."Amount (LCY)" := POSPostingBuffer."Amount (LCY)" + POSPaymentLineToBeCompressed."Amount (LCY)" - POSPaymentLineToBeCompressed."VAT Amount (LCY)";

          POSPostingBuffer."VAT Amount" += POSPaymentLineToBeCompressed."VAT Amount (LCY)"; // VAT reversal in foreign currency not supported.
          POSPostingBuffer."VAT Amount (LCY)" += POSPaymentLineToBeCompressed."VAT Amount (LCY)";
          POSPostingBuffer."VAT Base Amount" += POSPaymentLineToBeCompressed."VAT Base Amount (LCY)";
          //+NPR5.50 [354832]

          POSPostingBuffer.Modify;

        until POSPaymentLineToBeCompressed.Next = 0;
    end;

    local procedure CreatePOSPostingLogEntry(var POSEntry: Record "POS Entry"): Integer
    var
        POSPostingLog: Record "POS Posting Log";
        LastPOSEntry: Record "POS Entry";
    begin
        LastPOSEntry.Reset;
        LastPOSEntry.FindLast;
        with POSPostingLog do begin
          Init;
          "Entry No." := 0;
          "User ID" := UserId;
          "Posting Timestamp" := CurrentDateTime;
          "With Error" := true;
          "Error Description" := TextUnknownError;
          "POS Entry View" := CopyStr(POSEntry.GetView,1,MaxStrLen("POS Entry View"));
          "Last POS Entry No. at Posting" := LastPOSEntry."Entry No.";
          "Parameter Posting Date" := PostingDate;
          "Parameter Replace Posting Date" := ReplacePostingDate;
          "Parameter Replace Doc. Date" := ReplaceDocumentDate;
          "Parameter Post Item Entries" := PostItemEntriesVar;
          "Parameter Post POS Entries" := PostPOSEntriesVar;
          "Parameter Post Compressed" := PostCompressedVar;
          "Parameter Stop On Error" := StopOnErrorVar;
          Insert(true);
          exit("Entry No.");
        end;
    end;

    local procedure UpdatePOSPostingLogEntry(POSPostingLogEntryNo: Integer;WithError: Boolean)
    var
        POSPostingLog: Record "POS Posting Log";
    begin
        with POSPostingLog do begin
          Get(POSPostingLogEntryNo);
          if WithError then begin
            "With Error" := true;
            "Error Description" := CopyStr(ErrorText,1,MaxStrLen("Error Description"));
          end else begin
            "With Error" := false;
            "Error Description" := '';
          end;
          //-NPR5.38 [302791]
          "Posting Duration" := CurrentDateTime - "Posting Timestamp";
          //+NPR5.38 [302791]
          Modify(true);
        end;
    end;

    local procedure GetCompressionMethod(POSPeriodRegister: Record "POS Period Register";PostCompressed: Boolean): Integer
    begin
        //-NPR5.51 [359403]
        //  IF NOT PostCompressed THEN
        //    IF POSPeriodRegister."Posting Compression" = POSPeriodRegister."Posting Compression"::"Per POS Period" THEN
        //      EXIT(POSPeriodRegister."Posting Compression"::"Per POS Entry")
        //  ELSE
        //    EXIT(POSPeriodRegister."Posting Compression");

        if (not PostCompressed) then
          if (POSPeriodRegister."Posting Compression" = POSPeriodRegister."Posting Compression"::"Per POS Period") then
            exit(POSPeriodRegister."Posting Compression"::"Per POS Entry");

        exit (POSPeriodRegister."Posting Compression");
        //+NPR5.51 [359403]
    end;

    local procedure GetPostingSetupFromBufferLine(POSPostingBuffer: Record "POS Posting Buffer";var POSPostingSetup: Record "POS Posting Setup")
    begin
        if not GetPostingSetup(POSPostingBuffer."POS Store Code",POSPostingBuffer."POS Payment Method Code",POSPostingBuffer."POS Payment Bin Code",POSPostingSetup) then
          if POSPostingBuffer."POS Entry No." <> 0 then
            //-+NPR5.45 [322769] ERROR(TextPostingSetupMissing,POSPostingSetup.TABLECAPTION,POSPostingBuffer."Line Type",POSPostingBuffer.FIELDCAPTION("POS Entry No."),POSPostingBuffer."POS Entry No.")
            Error(TextPostingSetupMissing,POSPostingSetup.TableCaption,POSPostingBuffer."Line Type",POSPostingBuffer.FieldCaption("POS Entry No."),POSPostingBuffer."POS Entry No.",
              StrSubstNo ('%1: %4, %2: %5, %3: %6',POSPostingBuffer.FieldCaption ("POS Store Code"),POSPostingBuffer.FieldCaption ("POS Payment Method Code"),POSPostingBuffer.FieldCaption ("POS Payment Bin Code"),
                                                   POSPostingBuffer."POS Store Code",POSPostingBuffer."POS Payment Method Code",POSPostingBuffer."POS Payment Bin Code"))
          else
            //-+NPR5.45 [322769] ERROR(TextPostingSetupMissing,POSPostingSetup.TABLECAPTION,POSPostingBuffer."Line Type",POSPostingBuffer."POS Period Register",POSPostingBuffer."POS Period Register");
            Error(TextPostingSetupMissing,POSPostingSetup.TableCaption,POSPostingBuffer."Line Type",POSPostingBuffer."POS Period Register",POSPostingBuffer."POS Period Register",
              StrSubstNo ('%1: %4, %2: %5, %3: %6',POSPostingBuffer.FieldCaption ("POS Store Code"),POSPostingBuffer.FieldCaption ("POS Payment Method Code"),POSPostingBuffer.FieldCaption ("POS Payment Bin Code"),
                                                   POSPostingBuffer."POS Store Code",POSPostingBuffer."POS Payment Method Code",POSPostingBuffer."POS Payment Bin Code"));
    end;

    local procedure GetPostingSetupFromBalancingLine(POSBalancingLine: Record "POS Balancing Line";var POSPostingSetup: Record "POS Posting Setup")
    begin
        if not GetPostingSetup(POSBalancingLine."POS Store Code",POSBalancingLine."POS Payment Method Code",POSBalancingLine."POS Payment Bin Code",POSPostingSetup) then
          if POSBalancingLine."POS Entry No." <> 0 then
            //-+NPR5.45 [322769] ERROR(TextPostingSetupMissing,POSPostingSetup.TABLECAPTION,POSBalancingLine.TABLECAPTION,POSBalancingLine.FIELDCAPTION("POS Entry No."),POSBalancingLine."POS Entry No.")
            Error(TextPostingSetupMissing,POSPostingSetup.TableCaption,POSBalancingLine.TableCaption,POSBalancingLine.FieldCaption("POS Entry No."),POSBalancingLine."POS Entry No.",
              StrSubstNo ('%1: %4, %2: %5, %3: %6',POSBalancingLine.FieldCaption ("POS Store Code"),POSBalancingLine.FieldCaption ("POS Payment Method Code"),POSBalancingLine.FieldCaption ("POS Payment Bin Code"),
                                                   POSBalancingLine."POS Store Code",POSBalancingLine."POS Payment Method Code",POSBalancingLine."POS Payment Bin Code"))
          else
            //-+NPR5.45 [322769] ERROR(TextPostingSetupMissing,POSPostingSetup.TABLECAPTION,POSBalancingLine.TABLECAPTION,POSBalancingLine.FIELDCAPTION("POS Period Register No."),POSBalancingLine."POS Period Register No.");
            Error(TextPostingSetupMissing,POSPostingSetup.TableCaption,POSBalancingLine.TableCaption,POSBalancingLine.FieldCaption("POS Period Register No."),POSBalancingLine."POS Period Register No.",
              StrSubstNo ('%1: %4, %2: %5, %3: %6',POSBalancingLine.FieldCaption ("POS Store Code"),POSBalancingLine.FieldCaption ("POS Payment Method Code"),POSBalancingLine.FieldCaption ("POS Payment Bin Code"),
                                                   POSBalancingLine."POS Store Code",POSBalancingLine."POS Payment Method Code",POSBalancingLine."POS Payment Bin Code"));
    end;

    procedure GetPostingSetup(POSStoreCode: Code[10];POSPaymentMethodCode: Code[10];POSPaymentBinCode: Code[10];var POSPostingSetup: Record "POS Posting Setup"): Boolean
    var
        LocPOSPostingSetup: Record "POS Posting Setup";
        POSEntryManagement: Codeunit "POS Entry Management";
    begin
        with LocPOSPostingSetup do begin
          //All three match
          if Get(POSStoreCode,POSPaymentMethodCode,POSPaymentBinCode) then begin
            POSEntryManagement.CheckPostingSetupLine(LocPOSPostingSetup);
            POSPostingSetup := LocPOSPostingSetup;
            exit(true);
          end;
          //Store and Method
          if Get(POSStoreCode,POSPaymentMethodCode,'') then begin
            POSEntryManagement.CheckPostingSetupLine(LocPOSPostingSetup);
            POSPostingSetup := LocPOSPostingSetup;
            exit(true);
          end;
          //Store and Bin
          if Get(POSStoreCode,'',POSPaymentBinCode) then begin
            POSEntryManagement.CheckPostingSetupLine(LocPOSPostingSetup);
            POSPostingSetup := LocPOSPostingSetup;
            exit(true);
          end;
          //Method and Bin
          if Get('',POSPaymentMethodCode,POSPaymentBinCode) then begin
            POSEntryManagement.CheckPostingSetupLine(LocPOSPostingSetup);
            POSPostingSetup := LocPOSPostingSetup;
            exit(true);
          end;
          //Method only
          if Get('',POSPaymentMethodCode,'') then begin
            POSEntryManagement.CheckPostingSetupLine(LocPOSPostingSetup);
            POSPostingSetup := LocPOSPostingSetup;
            exit(true);
          end;
          exit(false);
        end;
    end;

    local procedure GetGLAccountType(POSPostingSetup: Record "POS Posting Setup"): Integer
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        POSPostingSetup.TestField("Account No.");
        case POSPostingSetup."Account Type" of
          POSPostingSetup."Account Type"::"G/L Account" :
            exit(GenJournalLine."Account Type"::"G/L Account");
          POSPostingSetup."Account Type"::"Bank Account" :
            exit(GenJournalLine."Account Type"::"Bank Account");
          POSPostingSetup."Account Type"::Customer :
            exit(GenJournalLine."Account Type"::Customer);
        end;
        Error(TextAccountTypeNotSupported,POSPostingSetup.FieldCaption("Account Type"),POSPostingSetup.TableCaption);
    end;

    local procedure GetDifferenceAccountType(POSPostingSetup: Record "POS Posting Setup"): Integer
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        case POSPostingSetup."Account Type" of
          POSPostingSetup."Difference Account Type"::"G/L Account" :
            exit(GenJournalLine."Account Type"::"G/L Account");
          POSPostingSetup."Difference Account Type"::"Bank Account" :
            exit(GenJournalLine."Account Type"::"Bank Account");
          POSPostingSetup."Difference Account Type"::Customer :
            exit(GenJournalLine."Account Type"::Customer);
        end;
        Error(TextAccountTypeNotSupported,POSPostingSetup.FieldCaption("Account Type"),POSPostingSetup.TableCaption);
    end;

    local procedure MarkPOSEntries(OptStatus: Option Posted,Error;POSPostingLogEntryNo: Integer;var POSEntry: Record "POS Entry")
    begin
        if POSEntry.FindSet then repeat
          //-NPR5.38 [301600]
          if  (POSEntry."Post Entry Status" in [POSEntry."Post Entry Status"::Unposted,POSEntry."Post Entry Status"::"Error while Posting"]) then begin
          //+NPR5.38 [301600]
            case OptStatus of
              OptStatus::Posted :
                begin
                  POSEntry.Validate("Post Entry Status",POSEntry."Post Entry Status"::Posted);
                end;
              OptStatus::Error :
                begin
                  POSEntry.Validate("Post Entry Status",POSEntry."Post Entry Status"::"Error while Posting");
                end;
            end;
            POSEntry."POS Posting Log Entry No." := POSPostingLogEntryNo;
            POSEntry.Modify(true);
          //-NPR5.38 [301600]
          end;
          //+NPR5.38 [301600]
        until POSEntry.Next  = 0;
    end;

    local procedure MakeGenJournalFromPOSPostingBuffer(POSPostingBuffer: Record "POS Posting Buffer";AmountIn: Decimal;AmountInLCY: Decimal;PostingType: Integer;AccountType: Integer;AccountNo: Code[20];BalancingAccountType: Integer;BalancingAccountNo: Code[20];VATAmountIn: Decimal;VATAmountInLCY: Decimal;var GenJournalLine: Record "Gen. Journal Line")
    var
        POSStore: Record "POS Store";
    begin
        //-NPR5.42 [312858]
        // IF (AmountIn = 0) AND (AmountInLCY = 0) THEN
        //  EXIT;
        //+NPR5.42 [312858]
        if POSPostingBuffer."POS Store Code" = '' then
          POSStore.Init
        else
          POSStore.Get(POSPostingBuffer."POS Store Code");
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
          //-NPR5.38 [294720]
          //'',
          POSPostingBuffer."External Document No.",
          //+NPR5.38 [294720]
          POSPostingBuffer."Tax Area Code",
          POSPostingBuffer."Tax Liable",
          POSPostingBuffer."Tax Group Code",
          POSPostingBuffer."Use Tax",
          VATAmountIn,
          VATAmountInLCY,
          POSStore."VAT Customer No.",
          GenJournalLine);
        //-NPR5.38 [294718]

        //+NPR5.38 [294718]
        OnAfterInsertPOSPostingBufferToGenJnl(POSPostingBuffer,GenJournalLine,PreviewMode);
    end;

    local procedure MakeGenJournalFromPOSBalancingLine(POSBalancingLine: Record "POS Balancing Line";Amount: Decimal;AccountType: Integer;AccountNo: Code[20];PostingDescription: Text;var GenJournalLine: Record "Gen. Journal Line")
    var
        POSEntry: Record "POS Entry";
    begin
        POSEntry.Get(POSBalancingLine."POS Entry No.");
        MakeGenJournalLine(
          AccountType,
          AccountNo,
          0,
          '',
          0,
          POSEntry."Posting Date",
          POSBalancingLine."Document No.",
          //-NPR5.38 [302777]
          //POSBalancingLine.Description,
          PostingDescription,
          //+NPR5.38 [302777]
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
          GenJournalLine);
        OnAfterInsertPOSBalancingLineToGenJnl(POSBalancingLine,GenJournalLine,PreviewMode);
    end;

    local procedure MakeGenJournalLine(AccountType: Integer;AccountNo: Code[20];BalancingAccountType: Integer;BalancingAccountNo: Code[20];GenPostingType: Integer;PostingDate: Date;DocumentNo: Code[20];PostingDescription: Text;VATPerc: Decimal;PostingCurrencyCode: Code[10];PostingAmount: Decimal;PostingAmountLCY: Decimal;PostingGroup: Code[10];GenBusPostingGroup: Code[10];GenProdPostingGroup: Code[10];VATBusPostingGroup: Code[10];VATProdPostingGroup: Code[10];ShortcutDim1: Code[20];ShortcutDim2: Code[20];DimSetID: Integer;SalespersonCode: Code[10];ReasonCode: Code[10];ExternalDocNo: Code[35];TaxAreaCode: Code[20];TaxLiable: Boolean;TaxGroupCode: Code[35];Usetax: Boolean;VATAmount: Decimal;VATAmountLCY: Decimal;VATCustomerNo: Code[20];var GenJournalLine: Record "Gen. Journal Line")
    var
        NPRetailSetup: Record "NP Retail Setup";
    begin
        NPRetailSetup.Get;
        LineNumber := LineNumber + 10000;
        with GenJournalLine do begin
          Init;
          "Journal Template Name" := '';
          "Journal Batch Name" := '';
          "Line No." := LineNumber;
          "System-Created Entry" := true;
          "Account Type" := AccountType;
          if "Account Type" = "Account Type"::Customer then
        //-NPR5.50 [300557]
        //    "Document Type" := "Document Type"::Payment;
            if PostingAmount <= 0 then
              "Document Type" := "Document Type"::Payment
            else
              "Document Type" := "Document Type"::Refund;
        //+NPR5.50 [300557]
          "Account No." := AccountNo;
          "Gen. Posting Type" := GenPostingType;
          "Posting Date" := PostingDate;
          "Document Date" := "Posting Date";
          if PreviewMode then
            "Document No." := FakeDocNoTxt
          else
            "Document No." := DocumentNo;
          "External Document No." := ExternalDocNo;
          Description := CopyStr(PostingDescription,1,MaxStrLen(Description));
          if StrLen(PostingDescription) > MaxStrLen(Description) then
            Comment := CopyStr(PostingDescription,1,MaxStrLen(Comment));

          "Currency Code" := PostingCurrencyCode;
          //-NPR5.38 [302777]
          //IF (PostingAmountLCY <> 0) AND (PostingCurrencyCode <> '') THEN
          //  VALIDATE("Currency Factor",PostingAmount / PostingAmountLCY);
          if (PostingCurrencyCode <> '') then
            if (PostingAmountLCY <> 0) then
              Validate("Currency Factor",PostingAmount / PostingAmountLCY)
            else
              Validate("Currency Code");
          //+NPR5.38 [302777]
          if PostingAmount <> 0 then
            Validate(Amount,PostingAmount);
          if PostingAmountLCY <> 0 then
            Validate("Amount (LCY)",PostingAmountLCY);
          "Source Currency Code" := PostingCurrencyCode;
          "Source Currency Amount" := PostingAmount;

          if GenPostingType in ["Gen. Posting Type"::Sale,"Gen. Posting Type"::Purchase] then begin
            if TaxAreaCode = '' then begin
              "VAT %" := VATPerc;
              "Source Curr. VAT Amount" := VATAmount;
              "Source Curr. VAT Base Amount" := PostingAmount;
               "Use Tax" := Usetax;
              "VAT Posting" := "VAT Posting"::"Manual VAT Entry";
              "VAT Amount" := VATAmount;
              "VAT Amount (LCY)" := VATAmountLCY;
              "Tax Area Code" := TaxAreaCode;
              "Tax Liable" := TaxLiable;
              "Tax Group Code" := TaxGroupCode;
              "VAT Bus. Posting Group" := VATBusPostingGroup;
              "VAT Prod. Posting Group" := VATProdPostingGroup;

              if GenPostingType = "Gen. Posting Type"::Sale then
                "Bill-to/Pay-to No." := VATCustomerNo;

            end else
              "VAT Calculation Type" := "VAT Calculation Type"::"Sales Tax";
          end;

          "Posting Group" := PostingGroup;
          "Gen. Bus. Posting Group" := GenBusPostingGroup;
          "Gen. Prod. Posting Group" := GenProdPostingGroup;
          "Shortcut Dimension 1 Code" := ShortcutDim1;
          "Shortcut Dimension 2 Code" := ShortcutDim2;
          "Dimension Set ID" := DimSetID;
          "Salespers./Purch. Code" := SalespersonCode;
          "Reason Code" := ReasonCode;
          "Source Code" := NPRetailSetup."Source Code";
          Insert;
        end;
    end;

    local procedure CreateGenJournalLinesFromSalesTax(var POSEntry: Record "POS Entry";var GenJnlLine: Record "Gen. Journal Line")
    var
        TaxJurisdiction: Record "Tax Jurisdiction";
        CurrExchRate: Record "Currency Exchange Rate";
        CustPostingGr: Record "Customer Posting Group";
        POSTaxAmountLine: Record "POS Tax Amount Line";
        TempPOSTaxAmountLine: Record "POS Tax Amount Line" temporary;
        NPRetailSetup: Record "NP Retail Setup";
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        TaxLineCount: Integer;
        RemSalesTaxAmt: Decimal;
        RemSalesTaxSrcAmt: Decimal;
        RecRef: RecordRef;
        FldRef: FieldRef;
        IsNALocalized: Boolean;
    begin
        NPRetailSetup.Get;
        GLSetup.Get;
        RecRef.GetTable(GenJnlLine);
        IsNALocalized := RecRef.FieldExist(10011);

        TempPOSTaxAmountLine.DeleteAll;
        POSTaxAmountLine.SetRange("POS Entry No.",POSEntry."Entry No.");
        POSTaxAmountLine.SetRange("Tax Calculation Type",TempPOSTaxAmountLine."Tax Calculation Type"::"Sales Tax");
        if POSTaxAmountLine.FindSet then repeat
          if IsNALocalized then begin
            TempPOSTaxAmountLine := POSTaxAmountLine;
            TempPOSTaxAmountLine.Insert;
          end else begin
            //IF Not in NA database, post as one line because of checks in Standard NAV
            TempPOSTaxAmountLine.Reset;
            TempPOSTaxAmountLine.SetRange("Tax Calculation Type",POSTaxAmountLine."Tax Calculation Type");
            TempPOSTaxAmountLine.SetRange("Tax Area Code",POSTaxAmountLine."Tax Area Code");
            TempPOSTaxAmountLine.SetRange("Tax Group Code",POSTaxAmountLine."Tax Group Code");
            TempPOSTaxAmountLine.SetRange("Use Tax",POSTaxAmountLine."Use Tax");
            TempPOSTaxAmountLine.SetRange("Tax Area Code for Key",POSTaxAmountLine."Tax Area Code for Key");
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

        if POSEntry.FindFirst then repeat
          TaxLineCount := 0;
          RemSalesTaxAmt := 0;
          RemSalesTaxSrcAmt := 0;
          if POSEntry."Currency Code" <> '' then
            Currency.Get(POSEntry."Currency Code")
          else
            Currency.Init;
          TempPOSTaxAmountLine.SetRange("POS Entry No.",POSEntry."Entry No.");
          TempPOSTaxAmountLine.SetRange("Tax Calculation Type",TempPOSTaxAmountLine."Tax Calculation Type"::"Sales Tax");
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
                GenJnlLine.Description := CopyStr(POSEntry.Description,1,MaxStrLen(GenJnlLine.Description));
                GenJnlLine."Line No." := LineNumber ;
                GenJnlLine."Reason Code" := POSEntry."Reason Code";
                //GenJnlLine."Document Type"
                if PreviewMode then
                  GenJnlLine."Document No." := FakeDocNoTxt
                else
                  GenJnlLine."Document No." := POSEntry."Document No.";
                //GenJnlLine."External Document No."
                GenJnlLine."System-Created Entry" := true;
                GenJnlLine.Amount := 0;
                GenJnlLine."Source Currency Code" := POSEntry."Currency Code";
                GenJnlLine."Source Currency Amount" := 0;
                //GenJnlLine.Correction
                GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::Sale;
                GenJnlLine."Tax Area Code" := TempPOSTaxAmountLine."Tax Area Code";
                if IsNALocalized then begin
                  //-NPR5.39 [304901]
                  RecRef.GetTable(GenJnlLine);
                  //+NPR5.39 [304901]
                  FldRef := RecRef.Field(10011);
                  FldRef.Value :=  TempPOSTaxAmountLine."Tax Jurisdiction Code";
                  FldRef := RecRef.Field(10012);
                  FldRef.Value := TempPOSTaxAmountLine."Tax Type";
                  //-NPR5.39 [304901]
                  RecRef.SetTable(GenJnlLine);
                  //+NPR5.39 [304901]
                end;
                //GenJnlLine."Tax Exemption No."
                GenJnlLine."Tax Group Code" := TempPOSTaxAmountLine."Tax Group Code";
                GenJnlLine."Tax Liable" := TempPOSTaxAmountLine."Tax Liable";
                GenJnlLine.Quantity := TempPOSTaxAmountLine.Quantity;
                GenJnlLine."VAT Calculation Type" := GenJnlLine."VAT Calculation Type"::"Sales Tax";
                GenJnlLine."VAT Posting" := GenJnlLine."VAT Posting"::"Manual VAT Entry";
                GenJnlLine."Shortcut Dimension 1 Code" := POSEntry."Shortcut Dimension 1 Code" ;
                GenJnlLine."Shortcut Dimension 2 Code" := POSEntry."Shortcut Dimension 2 Code";
                GenJnlLine."Dimension Set ID" := POSEntry."Dimension Set ID";
                GenJnlLine."Source Code" := NPRetailSetup."Source Code";
                GenJnlLine."Bill-to/Pay-to No." := POSEntry."Customer No.";
                GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
                GenJnlLine."Source No." := POSEntry."Customer No.";
                //GenJnlLine."Posting No. Series"
                //GenJnlLine."STE Transaction ID"  //Only in NA Version
                GenJnlLine."Source Curr. VAT Base Amount" :=
                  CurrExchRate.ExchangeAmtLCYToFCY(
                    POSEntry."Posting Date",POSEntry."Currency Code",TempPOSTaxAmountLine."Tax Base Amount",POSEntry."Currency Factor");
                GenJnlLine."VAT Base Amount (LCY)" :=
                  Round(TempPOSTaxAmountLine."Tax Base Amount");
                GenJnlLine."VAT Base Amount" := GenJnlLine."VAT Base Amount (LCY)";

                if TaxJurisdiction.Code <> TempPOSTaxAmountLine."Tax Jurisdiction Code" then begin
                  TaxJurisdiction.Get(TempPOSTaxAmountLine."Tax Jurisdiction Code");
                  //IF SalesTaxCountry = SalesTaxCountry::CA THEN BEGIN
                    RemSalesTaxAmt := 0;
                    RemSalesTaxSrcAmt := 0;
                  //END;
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
                  GenJnlLine."Source Curr. VAT Amount" := Round(RemSalesTaxSrcAmt,Currency."Amount Rounding Precision");
                  RemSalesTaxSrcAmt := RemSalesTaxSrcAmt - GenJnlLine."Source Curr. VAT Amount";
                  RemSalesTaxAmt := RemSalesTaxAmt + TempPOSTaxAmountLine."Tax Amount";
                  GenJnlLine."VAT Amount (LCY)" := Round(RemSalesTaxAmt,GLSetup."Amount Rounding Precision");
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
                //GenJnlPostLine.RunWithCheck(GenJnlLine);
              end;
            until TempPOSTaxAmountLine.Next = 0;
          end;
        until POSEntry.Next = 0;
    end;

    local procedure PostSalesTaxToGL(var POSEntry: Record "POS Entry")
    var
        TaxJurisdiction: Record "Tax Jurisdiction";
        CurrExchRate: Record "Currency Exchange Rate";
        CustPostingGr: Record "Customer Posting Group";
        POSTaxAmountLine: Record "POS Tax Amount Line";
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
        NPRetailSetup: Record "NP Retail Setup";
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        TaxLineCount: Integer;
        RemSalesTaxAmt: Decimal;
        RemSalesTaxSrcAmt: Decimal;
    begin
        NPRetailSetup.Get;
        GLSetup.Get;
        TaxLineCount := 0;
        RemSalesTaxAmt := 0;
        RemSalesTaxSrcAmt := 0;
        if POSEntry."Currency Code" <> '' then
          Currency.Get(POSEntry."Currency Code")
        else
          Currency.Init;
        POSTaxAmountLine.SetRange("POS Entry No.",POSEntry."Entry No.");
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
              TempGenJnlLine.Description := CopyStr(POSEntry.Description,1,MaxStrLen(TempGenJnlLine.Description));
              //TempGenJnlLine.Description := 'Sales Tax';
              TempGenJnlLine."Reason Code" := POSEntry."Reason Code";
              //TempGenJnlLine."Document Type"
              if PreviewMode then
                TempGenJnlLine."Document No." := FakeDocNoTxt
              else
                TempGenJnlLine."Document No." := POSEntry."Document No.";
              //TempGenJnlLine."External Document No."
              TempGenJnlLine."System-Created Entry" := true;
              TempGenJnlLine.Amount := 0;
              TempGenJnlLine."Source Currency Code" := POSEntry."Currency Code";
              TempGenJnlLine."Source Currency Amount" := 0;
              //TempGenJnlLine.Correction
              TempGenJnlLine."Gen. Posting Type" := TempGenJnlLine."Gen. Posting Type"::Sale;
              TempGenJnlLine."Tax Area Code" := POSTaxAmountLine."Tax Area Code";
              //TempGenJnlLine."Tax Type" := POSTaxAmountLine."Tax Type"; //Only in NA Version
              //TempGenJnlLine."Tax Exemption No."
              TempGenJnlLine."Tax Group Code" := POSTaxAmountLine."Tax Group Code";
              TempGenJnlLine."Tax Liable" := POSTaxAmountLine."Tax Liable";
              TempGenJnlLine.Quantity := POSTaxAmountLine.Quantity;
              TempGenJnlLine."VAT Calculation Type" := TempGenJnlLine."VAT Calculation Type"::"Sales Tax";
              TempGenJnlLine."VAT Posting" := TempGenJnlLine."VAT Posting"::"Manual VAT Entry";
              TempGenJnlLine."Shortcut Dimension 1 Code" := POSEntry."Shortcut Dimension 1 Code" ;
              TempGenJnlLine."Shortcut Dimension 2 Code" := POSEntry."Shortcut Dimension 2 Code";
              TempGenJnlLine."Dimension Set ID" := POSEntry."Dimension Set ID";
              TempGenJnlLine."Source Code" := NPRetailSetup."Source Code";
              //TempGenJnlLine."EU 3-Party Trade" := SalesHeader."EU 3-Party Trade";
              TempGenJnlLine."Bill-to/Pay-to No." := POSEntry."Customer No.";
              TempGenJnlLine."Source Type" := TempGenJnlLine."Source Type"::Customer;
              TempGenJnlLine."Source No." := POSEntry."Customer No.";
              //TempGenJnlLine."Posting No. Series"
              //TempGenJnlLine."STE Transaction ID"  //Only in NA Version
              TempGenJnlLine."Source Curr. VAT Base Amount" :=
                CurrExchRate.ExchangeAmtLCYToFCY(
                  POSEntry."Posting Date",POSEntry."Currency Code",POSTaxAmountLine."Tax Base Amount",POSEntry."Currency Factor");
              TempGenJnlLine."VAT Base Amount (LCY)" :=
                Round(POSTaxAmountLine."Tax Base Amount");
              TempGenJnlLine."VAT Base Amount" := TempGenJnlLine."VAT Base Amount (LCY)";
              if TaxJurisdiction.Code <> POSTaxAmountLine."Tax Jurisdiction Code" then begin
                TaxJurisdiction.Get(POSTaxAmountLine."Tax Jurisdiction Code");
                //IF SalesTaxCountry = SalesTaxCountry::CA THEN BEGIN
                  RemSalesTaxAmt := 0;
                  RemSalesTaxSrcAmt := 0;
                //END;
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
                TempGenJnlLine."Source Curr. VAT Amount" := Round(RemSalesTaxSrcAmt,Currency."Amount Rounding Precision");
                RemSalesTaxSrcAmt := RemSalesTaxSrcAmt - TempGenJnlLine."Source Curr. VAT Amount";
                RemSalesTaxAmt := RemSalesTaxAmt + POSTaxAmountLine."Tax Amount";
                TempGenJnlLine."VAT Amount (LCY)" := Round(RemSalesTaxAmt,GLSetup."Amount Rounding Precision");
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

    local procedure DialogUpdate()
    begin
    end;

    local procedure GetLastPaymentMethod()
    begin
    end;

    procedure Preview(var POSEntry: Record "POS Entry")
    var
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
    begin
        Error('Not supported in 2017');
        /*
        GenJnlPostPreview.Start;
        PreviewMode := TRUE;
        IF NOT Code(POSEntry) THEN BEGIN
          GenJnlPostPreview.Finish;
          IF GETLASTERRORTEXT <> GenJnlPostPreview.GetPreviewModeErrMessage THEN
            ERROR(GETLASTERRORTEXT);
          GenJnlPostPreview.ShowAllEntries;
          ERROR('');
        END;
        */

    end;

    procedure CompareToAuditRoll(var POSEntry: Record "POS Entry")
    var
        AuditRoll: Record "Audit Roll";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        POSAuditRollIntegration: Codeunit "POS-Audit Roll Integration";
        AuditRollDocNo: Code[20];
    begin
        Error('Not supported in 2017');
        /*
        //-NPR5.37 [293133];
        GenJnlPostPreview.Start;
        PreviewMode := TRUE;
        POSAuditRollIntegration.PrepareAuditRollCompare(POSEntry);
        
        IF NOT Code(POSEntry) THEN BEGIN
          GenJnlPostPreview.Finish;
          IF GETLASTERRORTEXT <> GenJnlPostPreview.GetPreviewModeErrMessage THEN
            ERROR(GETLASTERRORTEXT);
          GenJnlPostPreview.ShowAllEntries;
          ERROR('');
        END;
        //+NPR5.37 [293133]
        */

    end;

    local procedure SetAppliesToDocument(var GenJournalLine: Record "Gen. Journal Line";var POSPostingBuffer: Record "POS Posting Buffer")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        //-NPR5.50 [300557]
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

        GenJournalLine.Validate("Applies-to Doc. Type",POSPostingBuffer."Applies-to Doc. Type");
        GenJournalLine.Validate("Applies-to Doc. No.",POSPostingBuffer."Applies-to Doc. No.");
        GenJournalLine.Modify;
        //+NPR5.50 [300557]
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 45, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnModifyGLRegister(var Rec: Record "G/L Register";var xRec: Record "G/L Register";RunTrigger: Boolean)
    var
        NPRetailSetup: Record "NP Retail Setup";
        GLEntry: Record "G/L Entry";
    begin
        //-TEMP DEBUG
        NPRetailSetup.Get;
        if NPRetailSetup."Source Code" <> Rec."Source Code" then
          exit;
        //COMMIT;
        //GLEntry.SETRANGE("Entry No.",Rec."From Entry No.",Rec."To Entry No.");
        //PAGE.RUNMODAL(PAGE::"General Ledger Entries",GLEntry);
        //+TEMP DEBUG
    end;

    local procedure "---Events"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPOSEntry(var POSEntry: Record "POS Entry";PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPostingRestrictions(var POSEntry: Record "POS Entry";PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPOSEntry(var POSEntry: Record "POS Entry";PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSPostingBufferToGenJnl(var POSPostingBuffer: Record "POS Posting Buffer";var GenJournalLine: Record "Gen. Journal Line";PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSBalancingLineToGenJnl(var POSBalancingLine: Record "POS Balancing Line";var GenJournalLine: Record "Gen. Journal Line";PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPOSEntryBatch(var POSEntry: Record "POS Entry";PreviewMode: Boolean)
    begin
    end;
}

