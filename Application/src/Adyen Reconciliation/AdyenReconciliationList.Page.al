page 6184534 "NPR Adyen Reconciliation List"
{
    Caption = 'Adyen Reconciliation List';
    PageType = List;
    SourceTable = "NPR Adyen Reconciliation Hdr";
    CardPageId = "NPR Adyen Reconciliation";
    Extensible = false;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    AdditionalSearchTerms = 'Adyen Reconciliation';
    Editable = false;

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

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorDocument(Rec);
                    end;
                }
                field("Batch Number"; Rec."Batch Number")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Batch Number.';
                    StyleExpr = _StyleExprTxt;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorDocument(Rec);
                    end;
                }
                field("Merchant Account"; Rec."Merchant Account")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Merchant Account.';
                    StyleExpr = _StyleExprTxt;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorDocument(Rec);
                    end;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Document Date.';
                    StyleExpr = _StyleExprTxt;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorDocument(Rec);
                    end;
                }
                field("Total Transactions Amount"; Rec."Total Transactions Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Total Transactions Amount.';
                    StyleExpr = _StyleExprTxt;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorDocument(Rec);
                    end;
                }
                field("Total Posted Amount"; Rec."Total Posted Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Total Posted Amount.';
                    StyleExpr = _StyleExprTxt;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorDocument(Rec);
                    end;
                }
                field("Webhook Request ID"; Rec."Webhook Request ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Webhook Request ID.';
                    StyleExpr = _StyleExprTxt;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorDocument(Rec);
                    end;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the Document is Posted.';
                    StyleExpr = _StyleExprTxt;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorDocument(Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        _StyleExprTxt := _AdyenManagement.ChangeColorDocument(Rec);
    end;

    var
        _StyleExprTxt: Text[50];
        _AdyenManagement: Codeunit "NPR Adyen Management";
}
