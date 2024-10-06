page 6151260 "NPR POS Entry Cue"
{
    Caption = 'POS Entry Cue';
    Extensible = False;
    PageType = CardPart;
    SourceTable = "NPR POS Entry Cue.";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup("POS Entry Unposted Posting")
            {
                Caption = 'Unposted Postings';
                field(UnpostedItemTrans; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Unposted Item Trans."))))
                {
                    ApplicationArea = NPRRetail;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    AutoFormatType = 11;
                    Caption = 'Unposted Item Transactions';
                    ToolTip = 'Specifies the number of the unposted item transactions. By clicking, you can drill down to a list of unposted item transactions.';

                    trigger OnDrillDown()
                    var
                        POSEntry: Record "NPR POS Entry";
                    begin
                        POSEntry.SetRange("Post Item Entry Status", POSEntry."Post Item Entry Status"::Unposted);
                        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Credit Sale");
                        Page.RunModal(0, POSEntry);
                        CurrPage.Update(false);
                    end;
                }
                field(UnpostedGLTrans; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Unposted G/L Trans."))))
                {
                    ApplicationArea = NPRRetail;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    AutoFormatType = 11;
                    Caption = 'Unposted G/L Transactions';
                    ToolTip = 'Specifies the number of the unposted G/L transactions. By clicking, you can drill down to the list of unposted G/L transactions.';

                    trigger OnDrillDown()
                    var
                        POSEntry: Record "NPR POS Entry";
                    begin
                        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Unposted);
                        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Credit Sale");
                        Page.RunModal(0, POSEntry);
                        CurrPage.Update(false);
                    end;
                }
            }
            cuegroup("POS Entry Failed Posting")
            {
                Caption = 'Failed Postings';
                field(FailedItemTrans; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Failed Item Transaction."))))
                {
                    ApplicationArea = NPRRetail;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    AutoFormatType = 11;
                    Caption = 'Failed Item Transactions';
                    Style = Unfavorable;
                    StyleExpr = FailedItemTransExists;
                    ToolTip = 'Specifies the number of the failed item transactions. By clicking, you can drill down to the list of the failed item transactions.';

                    trigger OnDrillDown()
                    var
                        POSEntry: Record "NPR POS Entry";
                    begin
                        POSEntry.SetRange("Post Item Entry Status", POSEntry."Post Item Entry Status"::"Error while Posting");
                        Page.RunModal(0, POSEntry);
                        CurrPage.Update(false);
                    end;
                }
                field(FailedGLTrans; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Failed G/L Posting Trans."))))
                {
                    ApplicationArea = NPRRetail;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    AutoFormatType = 11;
                    Caption = 'Failed G/L Transaction';
                    Style = Unfavorable;
                    StyleExpr = FailedGLPostTransExists;
                    ToolTip = 'Specifies the number of the Failed G/L transactions. By clicking, you can drill down to the list of the Failed G/L transactions.';

                    trigger OnDrillDown()
                    var
                        POSEntry: Record "NPR POS Entry";
                    begin
                        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::"Error while Posting");
                        Page.RunModal(0, POSEntry);
                        CurrPage.Update(false);
                    end;
                }
            }
            cuegroup("EFT Errors")
            {
                Caption = 'EFT Errors';
                ShowCaption = true;
                field(FailedReconcBatches; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Reconc. Batches with Errors"))))
                {
                    ApplicationArea = NPRRetail;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    AutoFormatType = 11;
                    Caption = 'Reconciliation Batches with Errors';
                    ToolTip = 'Specifies the number of Reconciliation Batches that have Errors. By clicking, you can drill down to the list of failed NP Pay Batches.';

                    trigger OnDrillDown()
                    var
                        AdyenReconHdr: Record "NPR Adyen Reconciliation Hdr";
                        AdyenReconList: Page "NPR Adyen Reconciliation List";
                    begin
                        AdyenReconHdr.SetRange("Failed Lines Exist", true);
                        AdyenReconList.SetTableView(AdyenReconHdr);
                        AdyenReconList.RunModal();
                    end;
                }
                field(EFTReconcErrors; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("EFT Reconciliation Errors"))))
                {
                    ApplicationArea = NPRRetail;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    AutoFormatType = 11;
                    Caption = 'EFT Transaction Errors';
                    ToolTip = 'Specifies the number of Transaction EFT Errors in the last 30 days. By clicking, you can drill down to the list of Transaction EFT Errors in the last 30 days.';

                    trigger OnDrillDown()
                    var
                        EFTRequest: Record "NPR EFT Transaction Request";
                    begin
                        Rec.CopyFilter("EFT Errors Date Filter", EFTRequest."Transaction Date");
                        EFTRequest.SetFilter("Result Amount", '<>%1', 0);
                        EFTRequest.SetRange("FF Moved to POS Entry", false);
                        Page.RunModal(0, EFTRequest);
                        CurrPage.Update(false);
                    end;
                }
                field(UnfinishedEFTRequests; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Unfinished EFT Requests"))))
                {
                    ApplicationArea = NPRRetail;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    AutoFormatType = 11;
                    Caption = 'Unfinished EFT Requests';
                    ToolTip = 'Specifies the number of Unfinished EFT Requests in last 30 days. By clicking, you can drill down to the list of Unfinished EFT Requests in last 30 days.';

                    trigger OnDrillDown()
                    var
                        EFTRequest: Record "NPR EFT Transaction Request";
                    begin
                        Rec.CopyFilter("EFT Errors Date Filter", EFTRequest."Transaction Date");
                        EFTRequest.SetFilter("Amount Input", '<>%1', 0);
                        EFTRequest.SetRange(Finished, 0DT);
                        Page.RunModal(0, EFTRequest);
                        CurrPage.Update(false);
                    end;
                }
                field(EFTUnknownResultRequests; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("EFT Req. with Unknown Result"))))
                {
                    ApplicationArea = NPRRetail;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    AutoFormatType = 11;
                    Caption = 'EFT Requests with Unknown Result';
                    ToolTip = 'Specifies the number of Unfinished EFT Requests in last 30 days. By clicking, you can drill down to the list of Unfinished EFT Requests in last 30 days.';

                    trigger OnDrillDown()
                    var
                        EFTRequest: Record "NPR EFT Transaction Request";
                    begin
                        Rec.CopyFilter("EFT Errors Date Filter", EFTRequest."Transaction Date");
                        EFTRequest.SetFilter("Amount Input", '<>%1', 0);
                        EFTRequest.SetRange("External Result Known", false);
                        Page.RunModal(0, EFTRequest);
                        CurrPage.Update(false);
                    end;
                }
            }
            cuegroup("Incoming Documents")
            {
                Caption = 'Incoming Documents';
                field("My Incoming Documents"; Rec."My Incoming Documents")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the number of the incoming documents that are assigned to the current user.';
                }
            }
            cuegroup("Cash Summary")
            {
                Caption = 'Cash Summary';
                field("Transaction Amount (LCY)"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Transaction Amount (LCY)"))))
                {
                    ApplicationArea = NPRRetail;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    AutoFormatType = 11;
                    Caption = 'Transaction Amount (LCY)';
                    ToolTip = 'Specifies the total amount of cash currently stored in all POS units in the local currency.';
                    trigger OnDrillDown()
                    begin
                        Page.RunModal(Page::"NPR Cash Summary");
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    var
        BackgroundTaskResults: Dictionary of [Text, Text];
        BackgroundTaskId: Integer;
        FailedItemTransExists: Boolean;
        FailedGLPostTransExists: Boolean;

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        Rec.SetRange("EFT Errors Date Filter", CalcDate('<-30D>', Today()), Today());
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.EnqueueBackgroundTask(BackgroundTaskId, Codeunit::"NPR POS Entry Cue Backgrd Task");
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        BackgrndTaskMgt: Codeunit "NPR Page Background Task Mgt.";
    begin
        BackgrndTaskMgt.CopyTaskResults(Results, BackgroundTaskResults);
        UpdateControls();
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    var
        BackgrndTaskMgt: Codeunit "NPR Page Background Task Mgt.";
    begin
        if (TaskId = BackgroundTaskId) then
            BackgrndTaskMgt.FailedTaskError(CurrPage.Caption(), ErrorCode, ErrorText);
    end;

    local procedure GetFieldValueFromBackgroundTaskResultSet(FieldNo: Text) Result: Decimal
    begin
        if not BackgroundTaskResults.ContainsKey(FieldNo) then
            exit(0);
        if not Evaluate(Result, BackgroundTaskResults.Get(FieldNo), 9) then
            Result := 0;
    end;

    local procedure UpdateControls()
    begin
        FailedItemTransExists := GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Failed Item Transaction."))) > 0;
        FailedGLPostTransExists := GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Failed G/L Posting Trans."))) > 0;
    end;
}
