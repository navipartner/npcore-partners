page 6184534 "NPR Adyen Reconciliation List"
{
    Caption = 'NP Pay Reconciliation List';
    PageType = List;
    SourceTable = "NPR Adyen Reconciliation Hdr";
    SourceTableView = sorting("Document No.") order(descending);
    CardPageId = "NPR Adyen Reconciliation";
    Extensible = false;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    AdditionalSearchTerms = 'NP Pay Reconciliation';
    Editable = false;
    DeleteAllowed = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Reconciliation Document No.';
                    StyleExpr = _StyleExprTxt;
                }
                field("Batch Number"; Rec."Batch Number")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Batch Number.';
                    StyleExpr = _StyleExprTxt;
                }
                field("Merchant Account"; Rec."Merchant Account")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Merchant Account.';
                    StyleExpr = _StyleExprTxt;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Document Date.';
                    StyleExpr = _StyleExprTxt;
                }
                field("Transactions Date"; Rec."Transactions Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Transactions Date.';
                    StyleExpr = _StyleExprTxt;
                }
                field("Total Transactions Amount"; Rec."Total Transactions Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Total Transactions Amount.';
                    StyleExpr = _StyleExprTxt;
                }
                field("Total Posted Amount"; Rec."Total Posted Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Total Posted Amount.';
                    StyleExpr = _StyleExprTxt;
                }
                field("Webhook Request ID"; Rec."Webhook Request ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Webhook Request ID.';
                    StyleExpr = _StyleExprTxt;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Document Status.';
                    StyleExpr = _StyleExprTxt;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                Caption = 'Refresh';
                ApplicationArea = NPRRetail;
                Image = Refresh;
                ToolTip = 'Running this action will Refresh the page.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    RefreshingLbl: Label 'Refreshing...';
                    Window: Dialog;
                begin
                    Window.Open(RefreshingLbl);
                    CurrPage.Update(false);
                    Window.Close();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        _StyleExprTxt := ChangeColorDocument();
    end;

    local procedure ChangeColorDocument(): Text[50]
    begin
        if Rec."Failed Lines Exist" then
            exit('Unfavorable');

        if (Rec.Status = Rec.Status::Posted) or
           (not _AdyenSetup."Enable Automatic Posting" and ((Rec.Status = Rec.Status::Matched)))
        then
            exit('Favorable');

        exit('Standard');
    end;

    trigger OnOpenPage()
    begin
        _AdyenSetup.GetRecordOnce();
    end;

    var
        _StyleExprTxt: Text[50];
        _AdyenSetup: Record "NPR Adyen Setup";
}