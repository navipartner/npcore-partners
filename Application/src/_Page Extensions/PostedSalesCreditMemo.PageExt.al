pageextension 6014428 "NPR Posted Sales Credit Memo" extends "Posted Sales Credit Memo"
{
    layout
    {
        addlast("Invoice Details")
        {
            field("NPR Magento Payment Amount"; Rec."NPR Magento Payment Amount")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the sum of Payment Lines attached to the Posted Sales Credit Memo';
            }
        }
        addafter("External Document No.")
        {
            field("NPR Sales Channel"; Rec."NPR Sales Channel")
            {
                ToolTip = 'Specifies the value of the Sales Channel field';
                Visible = false;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
        addafter(Cancelled)
        {
            field("NPR Document Fiscalized"; CROAuxSalesCrMemoHdr."NPR CRO Document Fiscalized")
            {
                Caption = 'Document Fiscalized';
                ApplicationArea = NPRCROFiscal;
                ToolTip = 'Specifies the value of the Document Fiscalized field.';
                Editable = false;
            }
        }
    }
    actions
    {
        addlast(processing)
        {
            action("NPR NPRUpdateFromCustomer")
            {
                Caption = 'Update OIOUBL fields from Customer';
                ToolTip = 'Transfer OIOUBL fields from Customer to Document';
                ApplicationArea = NPRRetail;
                Image = DocumentEdit;
                Ellipsis = true;
                Visible = OIOUBLInstalled;

                trigger OnAction()
                var
                    UpdateDocument: Codeunit "NPR OIOUBL Update Document";
                begin
                    UpdateDocument.SalesCrMemoSetOIOUBLFieldsFromCustomer(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
        addafter(AttachAsPDF)
        {
            action("NPR Print Prepayment Invoice")
            {
                Caption = 'Print Prepayment Invoice';
                ToolTip = 'Runs a Prepayment Invoice report.';
                ApplicationArea = NPRRSLocal;
                Image = Print;

                trigger OnAction()
                var
                    PrepaymentSalesCrMemo: Report "NPR Prepayment Sales Cr. Memo";
                begin
                    PrepaymentSalesCrMemo.SetFilters(Rec."No.", Rec."Posting Date");
                    PrepaymentSalesCrMemo.RunModal();
                end;
            }
        }
    }

    var
        CROAuxSalesCrMemoHdr: Record "NPR CRO Aux Sales Cr. Memo Hdr";
        OIOUBLInstalled: Boolean;

    trigger OnOpenPage()
    var
        OIOUBLSetup: Record "NPR OIOUBL Setup";
    begin
        OIOUBLInstalled := OIOUBLSetup.IsOIOUBLInstalled();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CROAuxSalesCrMemoHdr.ReadCROAuxSalesCrMemoHeaderFields(Rec);
    end;
}