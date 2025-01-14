page 6184931 "NPR Retail Enter. Act: Subs"
{
    Extensible = False;
    Caption = 'Subscriptions';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Entertainment Cue";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup("Subscription Requests")
            {
                Caption = 'Subscription Requests';
                field("No. of Sub Req Pending"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("No. of Sub Req Pending"))))
                {
                    Caption = 'Pending';
                    ToolTip = 'The number of subscription requests with status Pending';
                    ApplicationArea = NPRRetail;
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    trigger OnDrillDown()
                    begin
                        DrillDownNoOfSubReqPending();
                    end;
                }
                field("No. of Sub Req Confirmed"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("No. of Sub Req Confirmed"))))
                {
                    Caption = 'Confirmed (Today)';
                    ToolTip = 'The number of subscription requests that were confirmed today';
                    ApplicationArea = NPRRetail;
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    trigger OnDrillDown()
                    begin
                        DrillDownNoOfSubReqConfirmed();
                    end;
                }
                field("No. of Sub Req Rejected"; Rec."No. of Sub Req Rejected")
                {
                    Caption = 'Rejected (Today)';
                    ToolTip = 'The number of subscription requests that were rejected today';
                    ApplicationArea = NPRRetail;
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    trigger OnDrillDown()
                    begin
                        DrillDownNoOfSubReqRejected();
                    end;
                }
                field("No. of Sub Req Error"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("No. of Sub Req Error"))))
                {
                    Caption = 'Error';
                    ToolTip = 'The number of subscription requests with status Error';
                    ApplicationArea = NPRRetail;
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    trigger OnDrillDown()
                    begin
                        DrillDownNoofSubReqError();
                    end;
                }
            }
            cuegroup("Subscription Payment Requests")
            {
                Caption = 'Subscription Payment Requests';
                field("No. of Sub Pay Req New"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("No. of Sub Pay Req New"))))
                {
                    Caption = 'Pending';
                    ToolTip = 'The number of subscription payment requests that are waiting for processing';
                    ApplicationArea = NPRRetail;
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    trigger OnDrillDown()
                    begin
                        DrillDownNoofSubPayReqNew();
                    end;
                }
                field(NoofSubPayReqCaptToday; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("No. of Sub Pay Req Captured"))))
                {
                    Caption = 'Captured (Today)';
                    ToolTip = 'The number of subscription payment requests that were captured today';
                    ApplicationArea = NPRRetail;
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    trigger OnDrillDown()
                    begin
                        DrillDownNoOfSubPayReqCaptToday();
                    end;
                }
                field(NoofSubPayReqRejectToday; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("No. of Sub Pay Req Rejected"))))
                {
                    Caption = 'Rejected (Today)';
                    ToolTip = 'The number of subscription payment requests that were captured today';
                    ApplicationArea = NPRRetail;
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    trigger OnDrillDown()
                    begin
                        DrillDownNoOfSubPayReqRejectToday();
                    end;
                }
                field("No. of Sub Pay Req Error"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("No. of Sub Pay Req Error"))))
                {
                    Caption = 'Error';
                    ToolTip = 'The number of subscription payment requests with status Error';
                    ApplicationArea = NPRRetail;
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    trigger OnDrillDown()
                    begin
                        DrillDownNoofSubPayReqError();
                    end;
                }
            }
        }
    }

    var
        BackgroundTaskResults: Dictionary of [Text, Text];
        BackgroundTaskId: Integer;

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.EnqueueBackgroundTask(BackgroundTaskId, Codeunit::"NPR Entertai. Cue Backgrd Task");
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        BackgrndTaskMgt: Codeunit "NPR Page Background Task Mgt.";
    begin
        BackgrndTaskMgt.CopyTaskResults(Results, BackgroundTaskResults);
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

    local procedure DrillDownNoOfSubReqError()
    var
        SubscrRequest: Record "NPR MM Subscr. Request";
    begin
        SubscrRequest.Reset();
        SubscrRequest.SetRange("Processing Status", SubscrRequest."Processing Status"::Error);
        Page.Run(0, SubscrRequest);
    end;

    local procedure DrillDownNoOfSubReqPending()
    var
        SubscrRequest: Record "NPR MM Subscr. Request";
    begin
        SubscrRequest.Reset();
        SubscrRequest.SetRange("Processing Status", SubscrRequest."Processing Status"::Pending);
        Page.Run(0, SubscrRequest);
    end;

    local procedure DrillDownNoOfSubReqConfirmed()
    var
        SubscrRequest: Record "NPR MM Subscr. Request";
    begin
        SubscrRequest.Reset();
        SubscrRequest.SetRange(Status, SubscrRequest.Status::Confirmed);
        SubscrRequest.SetRange("Processing Status", SubscrRequest."Processing Status"::Success);
        SubscrRequest.SetRange("Processing Status Change Date", Today);
        Page.Run(0, SubscrRequest);
    end;

    local procedure DrillDownNoOfSubReqRejected()
    var
        SubscrRequest: Record "NPR MM Subscr. Request";
    begin
        SubscrRequest.Reset();
        SubscrRequest.SetRange(Status, SubscrRequest.Status::Rejected);
        SubscrRequest.SetRange("Processing Status", SubscrRequest."Processing Status"::Success);
        SubscrRequest.SetRange("Processing Status Change Date", Today);
        Page.Run(0, SubscrRequest);
    end;

    local procedure DrillDownNoOfSubPayReqError()
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
    begin
        SubscrPaymentRequest.Reset();
        SubscrPaymentRequest.SetRange(Status, SubscrPaymentRequest.Status::Error);
        Page.Run(0, SubscrPaymentRequest);
    end;

    local procedure DrillDownNoOfSubPayReqNew()
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
    begin
        SubscrPaymentRequest.Reset();
        SubscrPaymentRequest.SetRange(Status, SubscrPaymentRequest.Status::New);
        Page.Run(0, SubscrPaymentRequest);
    end;

    local procedure DrillDownNoOfSubPayReqCaptToday()
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
    begin
        SubscrPaymentRequest.Reset();
        SubscrPaymentRequest.SetRange(Status, SubscrPaymentRequest.Status::Captured);
        SubscrPaymentRequest.SetRange("Status Change Date", Today);
        Page.Run(0, SubscrPaymentRequest);
    end;

    local procedure DrillDownNoOfSubPayReqRejectToday()
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
    begin
        SubscrPaymentRequest.Reset();
        SubscrPaymentRequest.SetRange(Status, SubscrPaymentRequest.Status::Rejected);
        SubscrPaymentRequest.SetRange("Status Change Date", Today);
        Page.Run(0, SubscrPaymentRequest);
    end;

}