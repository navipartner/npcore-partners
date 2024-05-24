page 6184502 "NPR Adyen Reconciliation"
{
    Extensible = false;

    Caption = 'Adyen Reconciliation';
    UsageCategory = Documents;
    ApplicationArea = NPRRetail;
    AdditionalSearchTerms = 'Adyen Reconciliation';
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

                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the Reconciliation Document No.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
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
                field("Batch Number"; Rec."Batch Number")
                {
                    ToolTip = 'Specifies the Reconciliation Batch Number.';
                    Editable = false;
                    Visible = not _IsExternalReport;
                    ApplicationArea = NPRRetail;
                }
                field("Adyen Acc. Currency Code"; Rec."Adyen Acc. Currency Code")
                {
                    ToolTip = 'Specifies the Adyen Account Currency Code.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Opening Balance"; Rec."Opening Balance")
                {
                    ToolTip = 'Specifies the opening balance shown on the Adyen''s statement.';
                    Editable = false;
                    Visible = not _IsExternalReport;
                    ApplicationArea = NPRRetail;
                }
                field("Closing Balance"; Rec."Closing Balance")
                {
                    ToolTip = 'Specifies the closing balance shown on the Adyen''s statement.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Acquirer Commission"; Rec."Acquirer Commission")
                {
                    ToolTip = 'Specifies the Aqcuirer Commission from External Settlement Detail Report.';
                    Editable = false;
                    Visible = _IsExternalReport;
                    ApplicationArea = NPRRetail;
                }
                field("Total Transactions Amount"; Rec."Total Transactions Amount")
                {
                    ToolTip = 'Specifies the Total Transactions Amount.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Total Posted Amount"; Rec."Total Posted Amount")
                {
                    ToolTip = 'Specifies the Total Posted Amount.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field(Posted; Rec.Posted)
                {
                    ToolTip = 'Specifies if the Document is successfully Posted.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
            }
            part("Reconciliation Lines"; "NPR Adyen Reconciliation Lines")
            {
                Caption = 'Adyen Reconciliation Lines';
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

                actionref(ReCreate_Promoted; "Re-Create Document")
                {
                }
                actionref(Match_Promoted; "Match Entries")
                {
                }
                actionref(Reconcile_Promoted; "Reconcile Entries")
                {
                }
                actionref(Post_Promoted; "Post Entries")
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

                action("Re-Create Document")
                {
                    Caption = 'Re-Create Document';
                    Ellipsis = true;
                    Image = SuggestLines;
                    Enabled = not _LinePosted;
                    ToolTip = 'Running this action will re-Create current Document (Not available if the Document is Posted).';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        WebhookRequest: Record "NPR AF Rec. Webhook Request";
                    begin
                        if WebhookRequest.Get(Rec."Webhook Request ID") then begin
                            _TransactionMatching.CreateSettlementDocuments(WebhookRequest, true, Rec."Document No.");
                            CurrPage.Update();
                        end;
                    end;
                }
                action("Match Entries")
                {
                    Caption = 'Match Entries';
                    Ellipsis = true;
                    Image = SelectEntries;
                    Enabled = not _DocumentPosted;
                    ToolTip = 'Running this action will initiate transaction matching process (Assignes Matching table and Matching entry No.).';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        MatchedEntries: Integer;
                        MatchedSuccessResult: Label 'Successfully matched %1 entries!';
                        MatchedNullResult: Label 'No entries were matched!';
                    begin
                        MatchedEntries := _TransactionMatching.MatchEntries(Rec);
                        if MatchedEntries > 0 then
                            Message(MatchedSuccessResult, Format(MatchedEntries))
                        else
                            Message(MatchedNullResult);
                        CurrPage.Update();
                    end;
                }
                action("Reconcile Entries")
                {
                    Caption = 'Reconcile Entries';
                    Ellipsis = true;
                    Image = Reconcile;
                    Enabled = not _DocumentPosted;
                    ToolTip = 'Running this action will initiate transaction reconciliation process. (Marks matched entries as "Reconciled").';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ReconciledSuccessResult: Label 'Successfully reconciled document!';
                        ReconciledFailedResult: Label 'Couldn''t reconcile some entries!';
                    begin
                        if _TransactionMatching.ReconcileEntries(Rec) then
                            Message(ReconciledSuccessResult)
                        else
                            Message(ReconciledFailedResult);
                        CurrPage.Update();
                    end;
                }
                action("Post Entries")
                {
                    Caption = 'Post Entries';
                    Ellipsis = true;
                    Image = PostingEntries;
                    Enabled = not _DocumentPosted;
                    ToolTip = 'Running this action will post transactions.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        PostedSuccessResult: Label 'Successfully posted document!';
                        PostedFailedResult: Label 'Couldn''t post some entries!';
                    begin
                        if _TransactionMatching.PostEntries(Rec) then
                            Message(PostedSuccessResult)
                        else
                            Message(PostedFailedResult);
                        CurrPage.Update();
                    end;
                }
            }
        }
        area(Navigation)
        {
            action("Show Logs")
            {
                Caption = 'Show Logs';
                Ellipsis = true;
                Image = Log;
                ToolTip = 'Running this action will open Adyen Reconciliation Log Journal.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    Logs: Record "NPR Adyen Reconciliation Log";
                begin
                    Logs.FilterGroup(0);
                    Logs.SetRange("Webhook Request ID", Rec."Webhook Request ID");
                    Logs.SetFilter("Creation Date", '>=%1', CreateDateTime(Rec."Document Date", 0T));
                    Logs.SetCurrentKey(ID);
                    Logs.Ascending(false);
                    Logs.FilterGroup(2);
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
                    AdyenReconciliationLine: Record "NPR Adyen Reconciliation Line";
                begin
                    AdyenReconciliationLine.Reset();
                    AdyenReconciliationLine.SetRange("Document No.", Rec."Document No.");
                    if AdyenReconciliationLine.FindFirst() then begin
                        if AdyenMerchantSetup.Get(AdyenReconciliationLine."Merchant Account") then
                            Page.RunModal(Page::"NPR Adyen Merchant Setup", AdyenMerchantSetup)
                        else
                            Page.RunModal(Page::"NPR Adyen Merchant Setup");
                    end else
                        Page.RunModal(Page::"NPR Adyen Merchant Setup");
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        GLEntry: Record "G/L Entry";
    begin
        if Rec."Document Type" = Rec."Document Type"::"External Settlement detail (C)" then
            _IsExternalReport := true;

        GLEntry.Reset();
        GLEntry.SetRange("Posting Date", Today());
        IF GLEntry.FindSet(true) then
            GLEntry.DeleteAll();
    end;

    trigger OnAfterGetRecord()
    var
        RecLine: Record "NPR Adyen Reconciliation Line";
    begin
        _DocumentPosted := Rec.Posted;
        RecLine.Reset();
        RecLine.SetFilter("Document No.", Rec."Document No.");
        RecLine.SetFilter(Status, '=%1', RecLine.Status::Posted);
        if RecLine.IsEmpty() then
            _LinePosted := false
        else
            _LinePosted := true;
    end;

    trigger OnDeleteRecord(): Boolean
    var
        ReconciliationLine: Record "NPR Adyen Reconciliation Line";
    begin
        ReconciliationLine.Reset();
        ReconciliationLine.SetRange("Document No.", Rec."Document No.");
        if ReconciliationLine.FindSet(true) then
            ReconciliationLine.DeleteAll();
    end;

    var
        _TransactionMatching: Codeunit "NPR Adyen Trans. Matching";
        _LinePosted: Boolean;
        _IsExternalReport: Boolean;
        _DocumentPosted: Boolean;
}
