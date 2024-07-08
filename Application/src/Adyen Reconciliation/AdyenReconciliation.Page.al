page 6184502 "NPR Adyen Reconciliation"
{
    Extensible = false;
    Caption = 'Adyen Reconciliation Document';
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
                    ToolTip = 'Specifies the Adyen Account Currency Code.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                group(OpeningBalance)
                {
                    Visible = (not _IsExternalReport) and (not _OpeningBalanceNull);
                    ShowCaption = false;

                    field("Opening Balance"; Rec."Opening Balance")
                    {
                        ToolTip = 'Specifies the opening balance (in Adyen Account Currency) shown on the Adyen''s statement.';
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
                        ToolTip = 'Specifies the closing balance (in Adyen Account Currency) shown on the Adyen''s statement.';
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
                        ToolTip = 'Specifies the Aqcuirer Commission from External Settlement Detail Report (in Adyen Account Currency).';
                        Editable = false;
                        ApplicationArea = NPRRetail;
                    }
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

                actionref(Recreate_Promoted; "Recreate Document")
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
                    begin
                        if _TransactionMatching.PostEntries(Rec) then
                            Message(PostedSuccessResult)
                        else
                            Message(PostedFailedResult);
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
                ToolTip = 'Running this action will open Adyen Reconciliation Log Journal.';
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
        _DocumentPosted := Rec.Posted;
        _AdyenSetup.GetRecordOnce();
        _PostWithTransactionDate := _AdyenSetup."Post with Transaction Date";

        _IsExternalReport := Rec."Document Type" = Rec."Document Type"::"External Settlement detail (C)";
        _OpeningBalanceNull := Rec."Opening Balance" = 0;
        _ClosingBalanceNull := Rec."Closing Balance" = 0;
        _MerchantPayoutNull := Rec."Merchant Payout" = 0;
    end;

    var
        _AdyenSetup: Record "NPR Adyen Setup";
        _TransactionMatching: Codeunit "NPR Adyen Trans. Matching";
        _IsExternalReport: Boolean;
        _DocumentPosted: Boolean;
        _PostWithTransactionDate: Boolean;
        _OpeningBalanceNull: Boolean;
        _ClosingBalanceNull: Boolean;
        _MerchantPayoutNull: Boolean;
}
