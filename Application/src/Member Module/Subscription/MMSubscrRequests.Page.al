page 6184833 "NPR MM Subscr. Requests"
{
    Extensible = false;
    Caption = 'Subscription Requests';
    PageType = List;
    SourceTable = "NPR MM Subscr. Request";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    UsageCategory = Tasks;
    Editable = false;
    SourceTableView = sorting("Subscription Entry No.", "Entry No.");

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies a unique entry number, assigned by the system to this record according to an automatically maintained number series.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Type; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Processing Status"; Rec."Processing Status")
                {
                    ToolTip = 'Specifies the value of the Processing Status field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("New Valid From Date"; Rec."New Valid From Date")
                {
                    ToolTip = 'Specifies the value of the New Valid From Date field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("New Valid Until Date"; Rec."New Valid Until Date")
                {
                    ToolTip = 'Specifies the value of the New Valid Until Date field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Terminate At"; Rec."Terminate At")
                {
                    ToolTip = 'Specifies the value of the Terminate At field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Posted; Rec.Posted)
                {
                    ToolTip = 'Specifies whether the subscription request has been posted to the general ledger.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Posted M/ship Ledg. Entry No."; Rec."Posted M/ship Ledg. Entry No.")
                {
                    ToolTip = 'Specifies the membership ledger entry number created by the subscription request posting process.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Posting Document No."; Rec."Posting Document No.")
                {
                    ToolTip = 'Specifies the document number used by the posting process for the subscription request.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the posting date used by the posting process for the subscription request.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("G/L Entry No."; Rec."G/L Entry No.")
                {
                    ToolTip = 'Specifies the entry number created in the general ledger by the posting process for the subscription request.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Cust. Ledger Entry No."; Rec."Cust. Ledger Entry No.")
                {
                    ToolTip = 'Specifies the entry number created in the customer ledger by the posting process for the subscription request.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Reversed; Rec.Reversed)
                {
                    ToolTip = 'Specifies the value of the Reversed field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Reversed by Entry No."; Rec."Reversed by Entry No.")
                {
                    ToolTip = 'Specifies the value of the Reversed by Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Subscription Entry No."; Rec."Subscription Entry No.")
                {
                    ToolTip = 'Specifies the value of the Subscription Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Process Try Count"; Rec."Process Try Count")
                {
                    ToolTip = 'Specifies the value of the Process Try Count field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Created from Entry No."; Rec."Created from Entry No.")
                {
                    ToolTip = 'Specifies the value of the Created from Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Visible = false;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(PaymentRequests)
            {
                Caption = 'Payment Requests';
                ToolTip = 'Shows the payment requests generated for this subscription renewal.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = PaymentHistory;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif

                trigger OnAction()
                var
                    SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
                    SubscrPaymentRequest_Marked: Record "NPR MM Subscr. Payment Request";
                begin
                    SubscrPaymentRequest.SetCurrentKey("Subscr. Request Entry No.");
                    SubscrPaymentRequest.SetLoadFields("Subscr. Request Entry No.", Reversed, "Reversed by Entry No.");
                    SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", Rec."Entry No.");
                    if SubscrPaymentRequest.FindSet() then
                        repeat
                            SubscrPaymentRequest_Marked := SubscrPaymentRequest;
                            SubscrPaymentRequest_Marked.Mark(true);
                            SubscrPaymentRequest.MarkReversed(SubscrPaymentRequest_Marked);
                        until SubscrPaymentRequest.Next() = 0;

                    SubscrPaymentRequest_Marked.MarkedOnly(true);
                    Page.Run(Page::"NPR MM Subscr.Payment Requests", SubscrPaymentRequest_Marked);
                end;
            }
            action(LogEntries)
            {
                Caption = 'Log Entries';
                ToolTip = 'Shows the interactions for the current subscription request';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = Log;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                trigger OnAction()
                begin
                    OpenLogEntries()
                end;
            }
            action(FindEntries)
            {
                Caption = 'Find Entries...';
                ToolTip = 'Find the posted entries for current subscription request';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = Navigate;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                trigger OnAction()
                begin
                    FindPostedEntries();
                end;
            }
        }

        area(Processing)
        {
            action(Process)
            {
                Caption = 'Process';
                ToolTip = 'Processes the current subscription payment request';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = NextRecord;

#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                trigger OnAction()
                begin
                    ProcessCurrentRecord(false)
                end;
            }
            action(ProcessWithoutTryCountUpdate)
            {
                Caption = 'Process (Without Try Count Update)';
                ToolTip = 'Processes the current subscription payment request without incrementing the try count';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = NextRecord;

#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                trigger OnAction()
                begin
                    ProcessCurrentRecord(true)
                end;
            }
            action(Cancel)
            {
                Caption = 'Cancel';
                ToolTip = 'Sets the status of the current subscription payment reques to Cancelled';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = Cancel;

#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                trigger OnAction()
                begin
                    SetStatusCancelled();
                end;
            }
            action(Regret)
            {
                Caption = 'Regret';
                ToolTip = 'Creates a new entry of type "Regret" for the current subscription request entry and requests a refund of the associated payment. The status of the payment must be "Captured".';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = VendorPayment;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                trigger OnAction()
                begin
                    RegretSubscriptionRequest();
                end;
            }
            action(ResetTryCount)
            {
                Caption = 'Reset Process Try Count';
                ToolTip = 'Sets the process try count to zero';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = Restore;

#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                trigger OnAction()
                begin
                    ResetProcessTryCount();
                end;
            }
        }

#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            actionref(PaymentRequests_Promoted; PaymentRequests) { }
            actionref(LogEntries_Promoted; LogEntries) { }
            actionref(FindEntries_Promoted; FindEntries) { }
            actionref(Process_Promoted; Process) { }
            actionref(ProcessWithoutTryCountUpdate_Promoted; ProcessWithoutTryCountUpdate) { }
            actionref(Cancel_Promoted; Cancel) { }
            actionref(Regret_Promoted; Regret) { }
            actionref(ResetTryCount_Promoted; ResetTryCount) { }
        }
#endif
    }

    local procedure ProcessCurrentRecord(SkipTryCountUpdate: Boolean)
    var
        SubscrRequestUtils: Codeunit "NPR MM Subscr. Request Utils";
    begin
        SubscrRequestUtils.ProcessSubscriptionRequestWithConfirmation(Rec, SkipTryCountUpdate);
    end;

    local procedure OpenLogEntries()
    var
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Req Log Utils";
    begin
        SubsPayReqLogUtils.OpenLogEntries(Rec);
    end;

    local procedure SetStatusCancelled()
    var
        SubscrRequestUtils: Codeunit "NPR MM Subscr. Request Utils";
    begin
        SubscrRequestUtils.SetSubscriptionRequestStatusCancelledWithConfirmation(Rec, true);
    end;

    local procedure FindPostedEntries()
    var
        Navigate: Page Navigate;
    begin
        Navigate.SetDoc(Rec."Posting Date", Rec."Posting Document No.");
        Navigate.Run();
    end;

    local procedure ResetProcessTryCount()
    var
        SubscrRequestUtils: Codeunit "NPR MM Subscr. Request Utils";
    begin
        SubscrRequestUtils.ResetProcessTryCountWithConfirmation(Rec);
    end;

    local procedure RegretSubscriptionRequest()
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscrPmtReversalRequest: Record "NPR MM Subscr. Payment Request";
        SubscrReversalMgt: Codeunit "NPR MM Subscr. Reversal Mgt.";
        RefundReqestedMsg: Label 'A new entry of type "Regret" for the current subscription request entry has been successfully created.';
    begin
        Rec.TestField(Type, Rec.Type::Renew);
        Rec.TestField(Status, Rec.Status::Confirmed);
        SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", Rec."Entry No.");
        SubscrPaymentRequest.FindLast();
        SubscrPaymentRequest.TestField(Status, SubscrPaymentRequest.Status::Captured);

        SubscrReversalMgt.RequestRefundWithConfirmation(SubscrPaymentRequest, SubscrPmtReversalRequest);
        if SubscrPmtReversalRequest."Entry No." <> 0 then begin
            Rec."Entry No." := SubscrPmtReversalRequest."Subscr. Request Entry No.";
            if Rec.Find() then;
            CurrPage.Update(false);
            Message(RefundReqestedMsg);
        end;
    end;
}