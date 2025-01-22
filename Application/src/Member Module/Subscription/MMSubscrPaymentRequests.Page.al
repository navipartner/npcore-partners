page 6184832 "NPR MM Subscr.Payment Requests"
{
    Extensible = false;
    Caption = 'Subscr. Payment Requests';
    PageType = List;
    SourceTable = "NPR MM Subscr. Payment Request";
    UsageCategory = Tasks;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    Editable = false;

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
                field("Batch No."; Rec."Batch No.")
                {
                    ToolTip = 'Specifies the value of the Batch No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(PSP; Rec.PSP)
                {
                    ToolTip = 'Specifies the value of the PSP field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the type of requested transaction.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
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
                field("External Transaction ID"; Rec."External Transaction ID")
                {
                    ToolTip = 'Specifies the value of the External Transaction ID field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("PSP Reference"; Rec."PSP Reference")
                {
                    ToolTip = 'Specifies the value of the PSP Reference field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Payment PSP Reference"; Rec."Payment PSP Reference")
                {
                    ToolTip = 'Specifies the value of the Payment PSP Reference field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Result Code"; Rec."Result Code")
                {
                    ToolTip = 'Specifies the value of the Refuse Reason Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Rejected Reason Code"; Rec."Rejected Reason Code")
                {
                    ToolTip = 'Specifies the value of the Rejected Reason Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Rejected Reason Description"; Rec."Rejected Reason Description")
                {
                    ToolTip = 'Specifies the value of the Rejected Reason Description field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Process Try Count"; Rec."Process Try Count")
                {
                    ToolTip = 'Specifies the value of the Process Try Count field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Posted; Rec.Posted)
                {
                    ToolTip = 'Specifies whether the subscription payment request has been posted to the general ledger.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Posting Document No."; Rec."Posting Document No.")
                {
                    ToolTip = 'Specifies the document number used by the posting process for the subscription payment request.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the posting date used by the posting process for the subscription payment request.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("G/L Entry No."; Rec."G/L Entry No.")
                {
                    ToolTip = 'Specifies the entry number created in the general ledger by the posting process for the subscription payment request.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Cust. Ledger Entry No."; Rec."Cust. Ledger Entry No.")
                {
                    ToolTip = 'Specifies the entry number created in the customer ledger by the posting process for the subscription payment request.';
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
                field("Subscr. Request Entry No."; Rec."Subscr. Request Entry No.")
                {
                    ToolTip = 'Specifies the value of the Subscription Request Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Reconciled; Rec.Reconciled)
                {
                    ToolTip = 'Specifies whether the subscription payment request has been reconciled.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced, NPRRetail;
                }
                field("Reconciliation Date"; Rec."Reconciliation Date")
                {
                    ToolTip = 'Specifies the date when the subscription payment request has been reconciled.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced, NPRRetail;
                }
            }
        }
    }

    actions
    {
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
            action(Refund)
            {
                Caption = 'Refund';
                ToolTip = 'Requests a refund for the current subscription payment. In order to request a refund, the status of the payment must be "Captured".';
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
                    RequestRefund();
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
        area(Navigation)
        {
            action(LogEntries)
            {
                Caption = 'Log Entries';
                ToolTip = 'Shows the interactions for the current subscription payment request';
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
                ToolTip = 'Find the posted entries for current subscription payment request';
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

#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            actionref(LogEntries_Promoted; LogEntries) { }
            actionref(FindEntries_Promoted; FindEntries) { }
            actionref(Process_Promoted; Process) { }
            actionref(ProcessWithoutTryCountUpdate_Promoted; ProcessWithoutTryCountUpdate) { }
            actionref(Cancel_Promoted; Cancel) { }
            actionref(Refund_Promoted; Refund) { }
            actionref(ResetTryCount_Promoted; ResetTryCount) { }
        }
#endif
    }

    local procedure ProcessCurrentRecord(SkipTryCountUpdate: Boolean)
    var
        SubsPayRequestUtils: Codeunit "NPR MM Subs Pay Request Utils";
    begin
        SubsPayRequestUtils.ProcessSubsPayRequestWithConfirmation(Rec, SkipTryCountUpdate);
    end;

    local procedure OpenLogEntries()
    var
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
    begin
        SubsPayReqLogUtils.OpenLogEntries(Rec);
    end;

    local procedure SetStatusCancelled()
    var
        SubsPayRequestUtils: Codeunit "NPR MM Subs Pay Request Utils";
    begin
        SubsPayRequestUtils.SetSubscrPaymentRequestStatusCancelled(Rec);
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
        SubsPayRequestUtils: Codeunit "NPR MM Subs Pay Request Utils";
    begin
        SubsPayRequestUtils.ResetProcessTryCountWithConfirmation(Rec);
    end;

    local procedure RequestRefund()
    var
        SubscrPmtReversalRequest: Record "NPR MM Subscr. Payment Request";
        SubscrReversalMgt: Codeunit "NPR MM Subscr. Reversal Mgt.";
        RefundReqestedMsg: Label 'Refund of selected subscription payment has been successfully requested.';
    begin
        SubscrReversalMgt.RequestRefundWithConfirmation(Rec, SubscrPmtReversalRequest);
        if SubscrPmtReversalRequest."Entry No." <> 0 then begin
            Rec := SubscrPmtReversalRequest;
            Rec.Mark(true);
            CurrPage.Update(false);
            Message(RefundReqestedMsg);
        end;
    end;
}