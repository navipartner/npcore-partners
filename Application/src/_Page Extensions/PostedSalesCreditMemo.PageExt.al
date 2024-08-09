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
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        addlast(content)
        {
            group("NPR RS E-Invoicing")
            {
                Caption = 'RS E-Invoicing';

                field("NPR RS EI Send To SEF"; RSEIAuxSalesCrMemoHdr."NPR RS EI Send To SEF")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Send To SEF';
                    ToolTip = 'Specifies the value of the Send To SEF field.';
                    Editable = not IsRSEInvoiceSent;
                    trigger OnValidate()
                    begin
                        RSEIAuxSalesCrMemoHdr.SaveRSEIAuxSalesCrMemoHdrFields();
                        IsDocForSendingToSEF := RSEIAuxSalesCrMemoHdr."NPR RS EI Send To SEF";
                    end;
                }
                field("NPR RS EI Send To CIR"; RSEIAuxSalesCrMemoHdr."NPR RS EI Send To CIR")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Send To CIR';
                    ToolTip = 'Specifies the value of the Send To CIR field.';
                    Editable = not IsRSEInvoiceSent;
                    Enabled = IsDocForSendingToSEF;
                    trigger OnValidate()
                    begin
                        RSEIAuxSalesCrMemoHdr.SaveRSEIAuxSalesCrMemoHdrFields();
                    end;
                }
                field("NPR RS EI Tax Liability Method"; RSEIAuxSalesCrMemoHdr."NPR RS EI Tax Liability Method")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Tax Liability Method';
                    ToolTip = 'Specifies the value of the Tax Liability Method field.';
                    Editable = not IsRSEInvoiceSent;
                    Enabled = IsDocForSendingToSEF;
                    trigger OnValidate()
                    begin
                        RSEIAuxSalesCrMemoHdr.SaveRSEIAuxSalesCrMemoHdrFields();
                    end;
                }
                field("NPR RS EI Model"; RSEIAuxSalesCrMemoHdr."NPR RS EI Model")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Model';
                    ToolTip = 'Specifies the value of the Model field.';
                    Editable = not IsRSEInvoiceSent;
                    Enabled = IsDocForSendingToSEF;
                    trigger OnValidate()
                    begin
                        IsModelFilled := (RSEIAuxSalesCrMemoHdr."NPR RS EI Model" <> '');
                        if IsModelFilled then
                            RSEIAuxSalesCrMemoHdr."NPR RS EI Reference Number" := '';
                        RSEIAuxSalesCrMemoHdr.SaveRSEIAuxSalesCrMemoHdrFields();
                    end;
                }
                field("NPR RS EI Reference Number"; RSEIAuxSalesCrMemoHdr."NPR RS EI Reference Number")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Reference Number';
                    ToolTip = 'Specifies the value of the Reference Number field.';
                    Editable = (not IsRSEInvoiceSent) and IsModelFilled;
                    Enabled = IsDocForSendingToSEF;
                    trigger OnValidate()
                    begin
                        RSEIAuxSalesCrMemoHdr.SaveRSEIAuxSalesCrMemoHdrFields();
                    end;
                }
                field("NPR RS EI Sales Invoice ID"; RSEIAuxSalesCrMemoHdr."NPR RS EI Sales Invoice ID")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Sales Invoice ID';
                    ToolTip = 'Specifies the value of the Sales Invoice ID field.';
                    Editable = false;
                }
                field("NPR RS EI Purchase Invoice ID"; RSEIAuxSalesCrMemoHdr."NPR RS EI Purchase Invoice ID")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Purchase Invoice ID';
                    ToolTip = 'Specifies the value of the Purchase Invoice ID field.';
                    Editable = false;
                }
                field("NPR RS EI Invoice Status"; RSEIAuxSalesCrMemoHdr."NPR RS EI Invoice Status")
                {
                    Caption = 'Invoice Status';
                    ToolTip = 'Specifies the value of the Invoice Status field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Invoice Type Code"; RSEIAuxSalesCrMemoHdr."NPR RS E-Invoice Type Code")
                {
                    Caption = 'Invoice Type Code';
                    ToolTip = 'Specifies the value of the Invoice Type Code field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Creation Date"; RSEIAuxSalesCrMemoHdr."NPR RS EI Creation Date")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Creation Date';
                    ToolTip = 'Specifies the value of the Creation Date field.';
                    Editable = false;
                }

                field("NPR RS EI Sending Date"; RSEIAuxSalesCrMemoHdr."NPR RS EI Sending Date")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Sending Date';
                    ToolTip = 'Specifies the value of the Sending Date field.';
                    Editable = false;
                }

                field("NPR RS EI Request Id"; RSEIAuxSalesCrMemoHdr."NPR RS EI Request ID")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Request Id';
                    ToolTip = 'Specifies the value of the Request Id field.';
                    Editable = false;
                }
            }
        }
#endif
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
        addlast(navigation)
        {
            group("NPR PayByLink")
            {
                Caption = 'Payments';
                Image = Payment;
                action("NPR Payment Lines")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Payment Lines';
                    Image = PaymentHistory;
                    ToolTip = 'View Payment Lines';

                    trigger OnAction()
                    begin
                        Rec.OpenMagentPaymentLines();
                    end;
                }
            }

        }
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        addlast("&Cr. Memo")
        {
            group("NPR RS E-Invoicing Actions")
            {
                Caption = 'RS E-Invoicing';

                action("NPR Send E-Invoice")
                {
                    Caption = 'Send E-Invoice';
                    ToolTip = 'Executes the Send E-Invoice action.';
                    ApplicationArea = NPRRSEInvoice;
                    Image = SendTo;
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        RSEIOutSalesCrMemoMgt: Codeunit "NPR RSEI Out SalesCr.Memo Mgt.";
                    begin
                        RSEIOutSalesCrMemoMgt.CreateRequestAndSendSalesCrMemo(Rec);
                    end;
                }
            }
        }
#endif
    }

    var
        CROAuxSalesCrMemoHdr: Record "NPR CRO Aux Sales Cr. Memo Hdr";
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RSEIAuxSalesCrMemoHdr: Record "NPR RSEI Aux Sales Cr.Memo Hdr";
        IsRSEInvoiceSent: Boolean;
        IsModelFilled: Boolean;
        IsDocForSendingToSEF: Boolean;
#endif
        OIOUBLInstalled: Boolean;

    trigger OnOpenPage()
    var
        OIOUBLSetup: Record "NPR OIOUBL Setup";
    begin
        OIOUBLInstalled := OIOUBLSetup.IsOIOUBLInstalled();
    end;

    trigger OnAfterGetCurrRecord()
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    var
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
#endif
    begin
        CROAuxSalesCrMemoHdr.ReadCROAuxSalesCrMemoHeaderFields(Rec);
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RSEIAuxSalesCrMemoHdr.ReadRSEIAuxSalesCrMemoHdrFields(Rec);
        IsRSEInvoiceSent := RSEInvoiceMgt.CheckIsRSEInvoiceSent(Rec."No.");
        IsDocForSendingToSEF := RSEInvoiceMgt.CheckIsDocumentSetForSendingToSEF(RSEIAuxSalesCrMemoHdr);
        IsModelFilled := false;
#endif
    end;
}