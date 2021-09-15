page 6151260 "NPR POS Entry Cue"
{
    PageType = CardPart;
    SourceTable = "NPR POS Entry Cue.";
    UsageCategory = None;
    Caption = 'POS Entry Cue';

    layout
    {
        area(content)
        {
            cuegroup("POS Entry Unposted Posting")
            {
                Caption = 'Unposted postings';
                field(UnpostedItemTrans; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Unposted Item Trans."))))
                {
                    Caption = 'Unposted Item Transactions';
                    ToolTip = 'Specifies the value of the Unposted Item Transactions field';
                    ApplicationArea = NPRRetail;

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
                    Caption = 'Unposted G/L Transactions';
                    ToolTip = 'Specifies the value of the Unposted G/L Transactions field';
                    ApplicationArea = NPRRetail;

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
                Caption = 'Failed postings';
                field(FailedItemTrans; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Failed Item Transaction."))))
                {
                    Caption = 'Failed Item Transactions';
                    ToolTip = 'Specifies the value of the Failed Item Transactions field';
                    ApplicationArea = NPRRetail;
                    Style = Unfavorable;
                    StyleExpr = FailedItemTransExists;

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
                    Caption = 'Failed G/L Transaction';
                    ToolTip = 'Specifies the value of the Failed G/L Transactions field';
                    ApplicationArea = NPRRetail;
                    Style = Unfavorable;
                    StyleExpr = FailedGLPostTransExists;

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
                field(EFTReconcErrors; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("EFT Reconciliation Errors"))))
                {
                    Caption = 'EFT Reconciliation Errors';
                    ToolTip = 'Specifies Reconciliation EFT Errors in last 30 days';
                    ApplicationArea = NPRRetail;

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
                    Caption = 'Unfinished EFT Requests';
                    ToolTip = 'Specifies Unfinished EFT Requests in last 30 days';
                    ApplicationArea = NPRRetail;

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
                    Caption = 'EFT Requests with Unknown Result';
                    ToolTip = 'Specifies the value of the EFT Requests with unknown result in last 30 days';
                    ApplicationArea = NPRRetail;

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
            cuegroup("Active Discounts, Coupons & Vouchers")
            {
                field(CampaignDiscounts; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Campaign Discount List"))))
                {
                    Caption = 'Campaign Discounts';
                    ToolTip = 'Specifies the value of the Campaign Discounts field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Page.RunModal(Page::"NPR Campaign Discount List");
                        CurrPage.Update(false);
                    end;
                }
                field(MixDiscounts; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Mix Discount List"))))
                {
                    Caption = 'Mix Discounts';
                    ToolTip = 'Specifies the value of the Mix Discounts field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        MixedDiscount: Record "NPR Mixed Discount";
                    begin
                        MixedDiscount.SetRange("Mix Type", MixedDiscount."Mix Type"::Standard, MixedDiscount."Mix Type"::Combination);
                        Page.RunModal(Page::"NPR Mixed Discount List", MixedDiscount);
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

    local procedure GetFieldValueFromBackgroundTaskResultSet(FieldNo: Text) Result: Integer
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