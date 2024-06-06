page 6184502 "NPR Adyen Reconciliation"
{
    Extensible = false;

    Caption = 'Adyen Reconciliation';
    UsageCategory = None;
    PageType = ListPlus;
    SourceTable = "NPR Adyen Reconciliation Hdr";
    RefreshOnActivate = true;
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = false;

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
                    ToolTip = 'Specifies the opening balance (in Adyen Account Currency) shown on the Adyen''s statement.';
                    Editable = false;
                    Visible = not _IsExternalReport;
                    ApplicationArea = NPRRetail;
                }
                field("Closing Balance"; Rec."Closing Balance")
                {
                    ToolTip = 'Specifies the closing balance (in Adyen Account Currency) shown on the Adyen''s statement.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Acquirer Commission"; Rec."Acquirer Commission")
                {
                    ToolTip = 'Specifies the Aqcuirer Commission from External Settlement Detail Report (in Adyen Account Currency).';
                    Editable = false;
                    Visible = _IsExternalReport;
                    ApplicationArea = NPRRetail;
                }
                field("Total Transactions Amount"; Rec."Total Transactions Amount")
                {
                    ToolTip = 'Specifies the Total Transactions Amount (in Adyen Account Currency).';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Total Posted Amount"; Rec."Total Posted Amount")
                {
                    ToolTip = 'Specifies the Total Posted Amount (in Adyen Account Currency).';
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
                        ValidationError: Label 'Report did not pass the Validation Scheme or Adyen Setup is incomplete.\Please check logs for more information.';
                    begin
                        if WebhookRequest.Get(Rec."Webhook Request ID") then begin
                            if _TransactionMatching.ValidateReportScheme(WebhookRequest) then begin
                                _TransactionMatching.CreateSettlementDocuments(WebhookRequest, true, Rec."Document No.");
                                CurrPage.Update();
                            end else
                                Error(ValidationError);
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
                        MatchedSuccessResult: Label 'Successfully matched %1 entries.';
                        MatchedNullResult: Label 'No entries were matched.';
                    begin
                        MatchedEntries := _TransactionMatching.MatchEntries(Rec);
                        if MatchedEntries > 0 then
                            Message(MatchedSuccessResult, Format(MatchedEntries))
                        else
                            Message(MatchedNullResult);
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
                        PostedSuccessResult: Label 'Successfully posted document.';
                        PostedFailedResult: Label 'Couldn''t post some entries.';
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
                begin
                    if AdyenMerchantSetup.Get(Rec."Merchant Account") then
                        Page.RunModal(Page::"NPR Adyen Merchant Setup", AdyenMerchantSetup)
                    else
                        Page.RunModal(Page::"NPR Adyen Merchant Setup");
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec."Document Type" = Rec."Document Type"::"External Settlement detail (C)" then
            _IsExternalReport := true;
    end;

    trigger OnAfterGetRecord()
    var
        RecLine: Record "NPR Adyen Recon. Line";
        AdyenSetup: Record "NPR Adyen Setup";
    begin
        RecLine.Reset();
        RecLine.SetRange("Document No.", Rec."Document No.");
        if RecLine.IsEmpty() then begin
            Rec.Posted := true;
            Rec.Modify();
        end;
        _DocumentPosted := Rec.Posted;
        if AdyenSetup.Get() then
            _PostWithTransactionDate := AdyenSetup."Post with Transaction Date";
        RecLine.SetRange(Status, RecLine.Status::Posted);
        if not RecLine.IsEmpty() then
            _LinePosted := true;
    end;

    var
        _TransactionMatching: Codeunit "NPR Adyen Trans. Matching";
        _LinePosted: Boolean;
        _IsExternalReport: Boolean;
        _DocumentPosted: Boolean;
        _PostWithTransactionDate: Boolean;
}
