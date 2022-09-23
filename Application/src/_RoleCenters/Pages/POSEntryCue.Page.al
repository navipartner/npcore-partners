page 6151260 "NPR POS Entry Cue"
{
    Extensible = False;
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
                Caption = 'Unposted Postings';
                field(UnpostedItemTrans; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Unposted Item Trans."))))
                {
                    Caption = 'Unposted Item Transactions';
                    ToolTip = 'Specifies the number of the unposted item transactions. By clicking, you can drill down to a list of unposted item transactions.';

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
                    ToolTip = 'Specifies the number of the unposted G/L transactions. By clicking, you can drill down to the list of unposted G/L transactions.';

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
                Caption = 'Failed Postings';
                field(FailedItemTrans; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Failed Item Transaction."))))
                {
                    Caption = 'Failed Item Transactions';
                    ToolTip = 'Specifies the number of the failed item transactions. By clicking, you can drill down to the list of the failed item transactions.';

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
                    ToolTip = 'Specifies the number of the Failed G/L transactions. By clicking, you can drill down to the list of the Failed G/L transactions.';

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
                Caption = 'EFT Errors';
                ShowCaption = true;

                field(EFTReconcErrors; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("EFT Reconciliation Errors"))))
                {
                    Caption = 'EFT Reconciliation Errors';
                    ToolTip = 'Specifies the number of Reconciliation EFT Errors in the last 30 days. By clicking, you can drill down to the list of Reconciliation EFT Errors in the last 30 days.';

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
                    ToolTip = 'Specifies the number of Unfinished EFT Requests in last 30 days. By clicking, you can drill down to the list of Unfinished EFT Requests in last 30 days.';

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
                    ToolTip = 'Specifies the number of Unfinished EFT Requests in last 30 days. By clicking, you can drill down to the list of Unfinished EFT Requests in last 30 days.';

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
                Caption = 'Active Discounts, Coupons & Vouchers';
                ShowCaption = true;

                field(CampaignDiscounts; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Campaign Discount List"))))
                {
                    Caption = 'Campaign Discounts';
                    ToolTip = 'Specifies the number of the Campaign Discounts. By clicking, you can drill down to the list of the Campaign Discounts.';

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
                    ToolTip = 'Specifies the number of the Mix Discounts. By clicking, you can drill down to the list of the Mix Discounts.';

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
                field(CouponList; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Coupon List"))))
                {
                    Caption = 'Coupon List';
                    ToolTip = 'Specifies the number of the Coupon List. By clicking, you can drill down to the list of the Coupon List.';

                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        CouponList: Record "NPR NpDc Coupon";
                    begin
                        Page.RunModal(Page::"NPR NpDc Coupons", CouponList);
                        CurrPage.Update(false);
                    end;
                }
                field(VoucherList; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Voucher List"))))
                {
                    Caption = 'Voucher List';
                    ToolTip = 'Specifies the number of the Voucher List. By clicking, you can drill down to the list of the Voucher List.';

                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        VoucherList: Record "NPR NpRv Voucher";
                    begin
                        Page.RunModal(Page::"NPR NpRv Vouchers", VoucherList);
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
