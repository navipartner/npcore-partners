#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6248222 "NPR Entria Order Imp. Failures"
{
    Caption = 'Entria Order Import Failures';
    PageType = List;
    SourceTable = "NPR Entria Order Imp. Failure";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    Editable = false;
    InsertAllowed = false;
    Extensible = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies where the import of this order stands: Pending while it still has retries left, Error once the retry budget is used up, and Skipped while a human has stopped it.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = _StatusStyleTxt;
                }
                field("Store Code"; Rec."Store Code")
                {
                    ToolTip = 'Specifies the Entria store the failed order belongs to.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = _StatusStyleTxt;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number of the order that failed to import, if one was assigned.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = _StatusStyleTxt;
                }
                field("Display No."; Rec."Display No.")
                {
                    ToolTip = 'Specifies the Entria display_id of the order that failed to import.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = _StatusStyleTxt;
                }
                field("Order Id"; Rec."Order Id")
                {
                    ToolTip = 'Specifies the Entria order id used to identify and re-fetch the order.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = _StatusStyleTxt;
                }
                field("Order Updated At"; Rec."Order Updated At")
                {
                    ToolTip = 'Specifies the order''s updated_at value from Entria at the time of the failed import.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = _StatusStyleTxt;
                }
                field("Last Error"; Rec."Last Error")
                {
                    ToolTip = 'Specifies the last error encountered while importing this order.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = _StatusStyleTxt;
                }
                field("Retry Count"; Rec."Retry Count")
                {
                    ToolTip = 'Specifies how many times the import of this order has been retried.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = _StatusStyleTxt;
                }
                field("Next Retry At"; Rec."Next Retry At")
                {
                    ToolTip = 'Specifies when this order will be retried next. Empty once the retry budget is used up.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = _StatusStyleTxt;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RequeueForImport)
            {
                Caption = 'Requeue for Import';
                ToolTip = 'Resets the retry budget and puts the order in front of the next import job. The import itself is done by that job, not by this action. This is the way back from both Error and Skipped.';
                ApplicationArea = NPRRetail;
                Image = Restore;
                trigger OnAction()
                var
                    BlockedReasons: Text;
                    ImportBlockedMsg: Label 'The order is queued for import, but it will not be imported until this is resolved:\%1', Comment = '%1 = one or more reasons why the Entria order import will not run';
                    RequeueQst: Label 'Requeue Entria order %1 for import?\The Entria order import job will pick it up on its next run.', Comment = '%1 = the order''s display no., or its Entria order id when no display no. is known';
                begin
                    if not Confirm(RequeueQst, false, OrderDescription()) then
                        exit;

                    _EntriaJQ.MarkOrderForRetry(Rec);
                    Rec.Modify(true);
                    CurrPage.Update(false);

                    BlockedReasons := _EntriaIntegrationMgt.GetOrderImportBlockedReasons(Rec."Store Code");
                    if BlockedReasons <> '' then
                        Message(ImportBlockedMsg, BlockedReasons);
                end;
            }
            action(SkipOrder)
            {
                Caption = 'Skip';
                ToolTip = 'Stops automatic retries for this order.';
                ApplicationArea = NPRRetail;
                Image = Cancel;
                Visible = not _IsSkipped;
                trigger OnAction()
                var
                    SkipQst: Label 'Stop the automatic import retries for Entria order %1?', Comment = '%1 = the order''s display no., or its Entria order id when no display no. is known';
                begin
                    if not Confirm(SkipQst, false, OrderDescription()) then
                        exit;

                    _EntriaJQ.SkipOrder(Rec);
                    Rec.Modify(true);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        _StatusStyleTxt := StatusStyle();
        _IsSkipped := Rec.Status = Rec.Status::Skipped;
    end;

    /// <summary>
    /// Names the order the way the operator reading the confirmation knows it: by its Entria display no.,
    /// falling back to the Entria order id on a row that failed before a display no. was known.
    /// </summary>
    local procedure OrderDescription(): Text
    begin
        if Rec."Document No." <> '' then
            exit(Rec."Document No.");

        exit(Format(Rec."Display No."));
    end;

    local procedure StatusStyle(): Text[50]
    begin
        case Rec.Status of
            Rec.Status::Error:
                exit('Unfavorable');
            Rec.Status::Skipped:
                exit('Subordinate');
        end;

        exit('Standard');
    end;

    var
        _EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
        _EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        _IsSkipped: Boolean;
        _StatusStyleTxt: Text[50];
}
#endif
