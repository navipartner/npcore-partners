page 6184502 "NPR Adyen Reconciliation"
{
    Extensible = false;
    Caption = 'NP Pay Reconciliation Document';
    UsageCategory = None;
    PageType = ListPlus;
    SourceTable = "NPR Adyen Reconciliation Hdr";
    RefreshOnActivate = true;
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the Reconciliation Document Type.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Merchant Account"; Rec."Merchant Account")
                {
                    ToolTip = 'Specifies the Merchant Account reconciled.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ToolTip = 'Specifies the Reconciliation Document Date.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Transactions Date"; Rec."Transactions Date")
                {
                    ToolTip = 'Specifies the Report Transactions Date.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                group(PostingDate)
                {
                    Visible = not _PostWithTransactionDate;
                    ShowCaption = false;

                    field("Posting Date"; Rec."Posting Date")
                    {
                        ToolTip = 'Specifies the Date the Transactions are to be posted with.';
                        ApplicationArea = NPRRetail;
                        Editable = not _DocumentPosted;
                    }
                }
                group(BatchNumber)
                {
                    ShowCaption = false;
                    Visible = not _IsExternalReport;

                    field("Batch Number"; Rec."Batch Number")
                    {
                        ToolTip = 'Specifies the Reconciliation Batch Number.';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                }
                field("Adyen Acc. Currency Code"; Rec."Adyen Acc. Currency Code")
                {
                    ToolTip = 'Specifies the Acquirer Account Currency Code.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                group(OpeningBalance)
                {
                    Visible = (not _IsExternalReport) and (not _OpeningBalanceNull);
                    ShowCaption = false;

                    field("Opening Balance"; Rec."Opening Balance")
                    {
                        ToolTip = 'Specifies the opening balance (in Acquirer Account Currency) shown on the NP Pay''s statement.';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                }
                group(ClosingBalance)
                {
                    Visible = not _ClosingBalanceNull;
                    ShowCaption = false;

                    field("Closing Balance"; Rec."Closing Balance")
                    {
                        ToolTip = 'Specifies the closing balance (in Acquirer Account Currency) shown on the NP Pay''s statement.';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                }
                group(AcquirerCommission)
                {
                    Visible = _IsExternalReport;
                    ShowCaption = false;

                    field("Acquirer Commission"; Rec."Acquirer Commission")
                    {
                        ToolTip = 'Specifies the Aqcuirer Commission from External Settlement Detail Report (in Acquirer Account Currency).';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                }

                field("Total Transactions Amount"; Rec."Total Transactions Amount")
                {
                    ToolTip = 'Specifies the Total Transactions Amount (in Acquirer Account Currency).';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Total Posted Amount"; Rec."Total Posted Amount")
                {
                    ToolTip = 'Specifies the Total Posted Amount (in Acquirer Account Currency).';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the Document Status.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                group(MerchantPayout)
                {
                    Visible = not _MerchantPayoutNull;
                    ShowCaption = false;

                    field("Merchant Payout"; Rec."Merchant Payout")
                    {
                        ToolTip = 'Specifies the Merchant Payout.';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            part("Reconciliation Lines"; "NPR Adyen Reconciliation Lines")
            {
                Caption = 'NP Pay Reconciliation Lines';
                SubPageLink = "Document No." = field("Document No.");
                UpdatePropagation = Both;
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
#IF NOT (BC17 or BC18 or BC19 or BC20 or BC21 or BC2200 or BC2201)
        area(Promoted)
        {
            group(Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref(Recreate_Promoted; "Recreate Document")
                {
                }
                actionref(Match_Promoted; "Match Entries")
                {
                }
                actionref(Post_Promoted; "Post Entries")
                {
                }
                actionref(Reconcile_Promoted; "Set as Reconciled")
                {
                }
            }
        }
#ENDIF
        area(Processing)
        {
            group(Manage)
            {
                Caption = 'Manage';
                Image = Process;

                action("Recreate Document")
                {
                    Caption = 'Recreate Document';
                    Image = RefreshText;
                    Enabled = not _DocumentPosted;
                    ToolTip = 'Running this action will initiate the Document Recreation process, which includes downloading the report and re-importing the entries, except for the posted ones.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        UpdatedEnties: Integer;
                        UpdatedEntriesSuccessLbl: Label 'Successfully recreated %1 entry/entries.';
                        UpdatedEntriesEmptyLbl: Label 'No entries were updated.';
                    begin
                        UpdatedEnties := _TransactionMatching.RecreateDocumentEntries(Rec);
                        if UpdatedEnties > 0 then begin
                            Message(UpdatedEntriesSuccessLbl, Format(UpdatedEnties));
                            CurrPage.Update(false);
                        end else
                            Message(UpdatedEntriesEmptyLbl);
                    end;
                }

                action("Match Entries")
                {
                    Caption = 'Match Entries';
                    Image = SelectEntries;
                    Enabled = not _DocumentPosted;
                    ToolTip = 'Running this action will initiate transaction matching process (Assignes Matching table and Matching entry No.).';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        MatchedEntries: Integer;
                        MatchedSuccessResult: Label 'Successfully matched %1 entries.';
                        MatchedNullResult: Label 'No entries were matched.';
                    begin
                        MatchedEntries := _TransactionMatching.MatchEntries(Rec);
                        if MatchedEntries > 0 then
                            Message(MatchedSuccessResult, Format(MatchedEntries))
                        else
                            Message(MatchedNullResult);
                        CurrPage.Update(false);
                    end;
                }
                action("Post Entries")
                {
                    Caption = 'Post Entries';
                    Image = PostingEntries;
                    Enabled = not _DocumentPosted;
                    ToolTip = 'Running this action will post transactions.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        PostedSuccessResult: Label 'Successfully posted document.';
                        PostedFailedResult: Label 'Couldn''t post some entries.';
                        PostingConfirmationLbl: Label 'Are you sure you want to post the Reconciliation lines?';
                    begin
                        if not Confirm(PostingConfirmationLbl) then
                            exit;

                        if _TransactionMatching.PostEntries(Rec) then
                            Message(PostedSuccessResult)
                        else
                            Message(PostedFailedResult);
                        CurrPage.Update(false);
                    end;
                }
                action("Set as Reconciled")
                {
                    Caption = 'Set as Reconciled';
                    Image = PostingEntries;
                    Enabled = not _DocumentReconciled and not _DocumentPosted;
                    ToolTip = 'Running this action will set transactions as Reconciled.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ReconcilingSuccessResult: Label 'The reconciliation document lines have been successfully set as reconciled.';
                        ReconcilingFailedResult: Label 'Some entries could not be set as reconciled.';
                        ReconcilingConfirmationLbl: Label 'This will set the reconciliation lines as reconciled. This action is irreversible and once you''ve completed it, you won''t be able to change the transaction matching. Are you sure you want to proceed?';
                    begin
                        if not Confirm(ReconcilingConfirmationLbl) then
                            exit;

                        if _TransactionMatching.ReconcileEntries(Rec) then
                            Message(ReconcilingSuccessResult)
                        else
                            Message(ReconcilingFailedResult);
                        CurrPage.Update(false);
                    end;
                }
                action("Reverse Postings")
                {
                    Caption = 'Reverse Postings...';
                    Image = ReverseRegister;
                    Enabled = _HasPostedLines;
                    ToolTip = 'Running this action will revert the posting process for all lines.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        UnPostingConfirmationLbl: Label 'Are you sure you want to reverse the posting for this Reconciliation Document?';
                    begin
                        if not Confirm(UnPostingConfirmationLbl) then
                            exit;

                        _TransactionMatching.ReversePostings(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
        area(Navigation)
        {
            action("Show Logs")
            {
                Caption = 'Show Logs';
                Image = Log;
                ToolTip = 'Running this action will open NP Pay Reconciliation Log Journal.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    Logs: Record "NPR Adyen Reconciliation Log";
                begin
                    Logs.FilterGroup(2);
                    Logs.SetRange("Webhook Request ID", Rec."Webhook Request ID");
                    Logs.SetFilter("Creation Date", '>=%1', CreateDateTime(Rec."Document Date", 0T));
                    Logs.FilterGroup(0);
                    Page.Run(Page::"NPR Adyen Reconciliation Logs", Logs);
                end;
            }
            action("Merchant Account Setup")
            {
                Caption = 'Merchant Account Setup';
                Image = Setup;
                ToolTip = 'Running this action will open current document''s Merchant Account Setup.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    AdyenMerchantSetup: Record "NPR Adyen Merchant Setup";
                begin
                    if AdyenMerchantSetup.Get(Rec."Merchant Account") then
                        Page.RunModal(Page::"NPR Adyen Merchant Setup", AdyenMerchantSetup)
                    else
                        Page.RunModal(Page::"NPR Adyen Merchant Setup");
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        _DocumentPosted := Rec.Status = Rec.Status::Posted;
        _DocumentReconciled := Rec.Status = Rec.Status::Reconciled;
        _HasPostedLines := Rec."Total Posted Amount" > 0;
        _IsExternalReport := Rec."Document Type" = Rec."Document Type"::"External Settlement detail (C)";
        _OpeningBalanceNull := Rec."Opening Balance" = 0;
        _ClosingBalanceNull := Rec."Closing Balance" = 0;
        _MerchantPayoutNull := Rec."Merchant Payout" = 0;
    end;

    trigger OnOpenPage()
    begin
        _AdyenSetup.GetRecordOnce();
        _PostWithTransactionDate := _AdyenSetup."Post with Transaction Date";
    end;

    var
        _AdyenSetup: Record "NPR Adyen Setup";
        _TransactionMatching: Codeunit "NPR Adyen Trans. Matching";
        _HasPostedLines: Boolean;
        _IsExternalReport: Boolean;
        _DocumentPosted: Boolean;
        _DocumentReconciled: Boolean;
        _PostWithTransactionDate: Boolean;
        _OpeningBalanceNull: Boolean;
        _ClosingBalanceNull: Boolean;
        _MerchantPayoutNull: Boolean;
}
