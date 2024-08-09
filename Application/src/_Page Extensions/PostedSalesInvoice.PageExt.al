pageextension 6014405 "NPR Posted Sales Invoice" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("NPR Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
            {
                ToolTip = 'Specifies the Sell-to Customer Name 2 that will appear on the new sales document.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Payment Method Code")
        {
            field("NPR Magento Payment Amount"; Rec."NPR Magento Payment Amount")
            {
                ToolTip = 'Specifies the sum of Payment Lines attached to the Posted Sales Invoice.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Ship-to Name")
        {
            field("NPR Ship-to Name 2"; Rec."Ship-to Name 2")
            {
                ToolTip = 'Specifies the additional name of the customer that you shipped the items on the invoice to.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Bill-to Name")
        {
            field("NPR Bill-to Name 2"; Rec."Bill-to Name 2")
            {
                ToolTip = 'Specifies the additinal name of the customer that the invoice was sent to.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter(Cancelled)
        {
            field("NPR RS Audit Entry"; RSAuxSalesInvHeader."NPR RS Audit Entry")
            {
                Caption = 'RS Audit Entry';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS Audit Entry field.';
                Editable = false;
            }
            field("NPR CRO Document Fiscalized"; CROAuxSalesInvHeader."NPR CRO Document Fiscalized")
            {
                Caption = 'Document Fiscalized';
                ApplicationArea = NPRCROFiscal;
                ToolTip = 'Specifies the value of the CRO Document Fiscalized field.';
                Editable = false;
            }
        }
        addafter(Closed)
        {
            field("NPR Sales Channel"; Rec."NPR Sales Channel")
            {
                ToolTip = 'Specifies the value of the Sales Channel field';
                Visible = false;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
#if not BC17
        addafter("External Document No.")
        {
            field("NPR Spfy Order ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
            {
                Caption = 'Shopify Order ID';
                Editable = false;
                Visible = ShopifyIntegrationIsEnabled;
                ApplicationArea = NPRShopify;
                ToolTip = 'Specifies the Shopify Oder ID assigned to the document.';
            }
            field("NPR Shopify Store Code"; SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Store Code"))
            {
                Caption = 'Shopify Store Code';
                Editable = false;
                Visible = ShopifyIntegrationIsEnabled;
                ApplicationArea = NPRShopify;
                ToolTip = 'Specifies the Shopify store the document has been created at.';
            }
        }
#endif
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        addlast(content)
        {
            group("NPR RS E-Invoicing")
            {
                Caption = 'RS E-Invoicing';

                field("NPR RS EI Send To SEF"; RSEIAuxSalesInvHdr."NPR RS EI Send To SEF")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Send To SEF';
                    ToolTip = 'Specifies the value of the Send To SEF field.';
                    Editable = not IsRSEInvoiceSent;
                    trigger OnValidate()
                    begin
                        RSEIAuxSalesInvHdr.SaveRSEIAuxSalesInvHdrFields();
                        IsDocForSendingToSEF := RSEIAuxSalesInvHdr."NPR RS EI Send To SEF";
                    end;
                }
                field("NPR RS EI Send To CIR"; RSEIAuxSalesInvHdr."NPR RS EI Send To CIR")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Send To CIR';
                    ToolTip = 'Specifies the value of the Send To CIR field.';
                    Editable = not IsRSEInvoiceSent;
                    Enabled = IsDocForSendingToSEF;
                    trigger OnValidate()
                    begin
                        RSEIAuxSalesInvHdr.SaveRSEIAuxSalesInvHdrFields();
                    end;
                }
                field("NPR RS EI Tax Liability Method"; RSEIAuxSalesInvHdr."NPR RS EI Tax Liability Method")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Tax Liability Method';
                    ToolTip = 'Specifies the value of the Tax Liability Method field.';
                    Editable = not IsRSEInvoiceSent;
                    Enabled = IsDocForSendingToSEF;
                    trigger OnValidate()
                    begin
                        RSEIAuxSalesInvHdr.SaveRSEIAuxSalesInvHdrFields();
                    end;
                }
                field("NPR RS EI Model"; RSEIAuxSalesInvHdr."NPR RS EI Model")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Model';
                    ToolTip = 'Specifies the value of the Model field.';
                    Editable = not IsRSEInvoiceSent;
                    Enabled = IsDocForSendingToSEF;
                    trigger OnValidate()
                    begin
                        IsModelFilled := (RSEIAuxSalesInvHdr."NPR RS EI Model" <> '');
                        if IsModelFilled then
                            RSEIAuxSalesInvHdr."NPR RS EI Reference Number" := '';
                        RSEIAuxSalesInvHdr.SaveRSEIAuxSalesInvHdrFields();
                    end;
                }
                field("NPR RS EI Reference Number"; RSEIAuxSalesInvHdr."NPR RS EI Reference Number")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Reference Number';
                    ToolTip = 'Specifies the value of the Reference Number field.';
                    Editable = (not IsRSEInvoiceSent) and IsModelFilled;
                    Enabled = IsDocForSendingToSEF;
                    trigger OnValidate()
                    begin
                        RSEIAuxSalesInvHdr.SaveRSEIAuxSalesInvHdrFields();
                    end;
                }
                field("NPR RS EI Sales Invoice ID"; RSEIAuxSalesInvHdr."NPR RS EI Sales Invoice ID")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Sales Invoice ID';
                    ToolTip = 'Specifies the value of the Sales Invoice ID field.';
                    Editable = false;
                }
                field("NPR RS EI Purchase Invoice ID"; RSEIAuxSalesInvHdr."NPR RS EI Purchase Invoice ID")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Purchase Invoice ID';
                    ToolTip = 'Specifies the value of the Purchase Invoice ID field.';
                    Editable = false;
                }
                field("NPR RS EI Invoice Status"; RSEIAuxSalesInvHdr."NPR RS EI Invoice Status")
                {
                    Caption = 'Invoice Status';
                    ToolTip = 'Specifies the value of the Invoice Status field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Invoice Type Code"; RSEIAuxSalesInvHdr."NPR RS Invoice Type Code")
                {
                    Caption = 'Invoice Type Code';
                    ToolTip = 'Specifies the value of the Invoice Type Code field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Creation Date"; RSEIAuxSalesInvHdr."NPR RS EI Creation Date")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Creation Date';
                    ToolTip = 'Specifies the value of the Creation Date field.';
                    Editable = false;
                }

                field("NPR RS EI Sending Date"; RSEIAuxSalesInvHdr."NPR RS EI Sending Date")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Sending Date';
                    ToolTip = 'Specifies the value of the Sending Date field.';
                    Editable = false;
                }

                field("NPR RS EI Request Id"; RSEIAuxSalesInvHdr."NPR RS EI Request ID")
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
        addafter(AttachAsPDF)
        {
            action("NPR SendSMS")
            {
                Caption = 'Send SMS';
                Image = SendConfirmation;
                ToolTip = 'Specifies whether a notification SMS should be sent to a responsible person. The messages are sent using SMS templates.';
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    SMSMgt: Codeunit "NPR SMS Management";
                begin
                    SMSMgt.EditAndSendSMS(Rec);
                end;
            }
        }
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
                    UpdateDocument.SalesInvoiceSetOIOUBLFieldsFromCustomer(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
        addafter(AttachAsPDF)
        {
            action("NPR Print Sales Invoice")
            {
                Caption = 'Print Sales Invoice';
                ToolTip = 'Runs a Sales Invoice report.';
                ApplicationArea = NPRRSLocal;
                Image = Print;

                trigger OnAction()
                var
                    PrepaymentSalesInvoice: Report "NPR Retail Sales Invoice";
                begin
                    PrepaymentSalesInvoice.SetFilters(Rec."No.", Rec."Order Date");
                    PrepaymentSalesInvoice.RunModal();
                end;
            }

            action("NPR Print Prepayment Invoice")
            {
                Caption = 'Print Prepayment Invoice';
                ToolTip = 'Runs a Prepayment Invoice report.';
                ApplicationArea = NPRRSLocal;
                Image = Print;

                trigger OnAction()
                var
                    PrepaymentSalesInvoice: Report "NPR Prepayment Sales Invoice";
                begin
                    PrepaymentSalesInvoice.SetFilters(Rec."No.", Rec."Order Date");
                    PrepaymentSalesInvoice.RunModal();
                end;
            }
        }

        addafter("NPR SendSMS")
        {
            group("NPR PayByLink")
            {
                Caption = 'Pay by Link';
                Image = Payment;

                action("NPR Pay by link")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Pay by link';
                    ToolTip = 'Pay by link.';
                    Image = LinkWeb;

                    trigger OnAction()
                    var
                        PaybyLink: Interface "NPR Pay by Link";
                        PayByLinkSetup: Record "NPR Pay By Link Setup";
                        MagentoPaymentGateway: Record "NPR Magento Payment Gateway";
                    begin
                        PayByLinkSetup.Get();
                        MagentoPaymentGateway.Get(PayByLinkSetup."Payment Gateaway Code");
                        PaybyLink := MagentoPaymentGateway."Integration Type";
                        PaybyLink.SetDocument(Rec);
                        PaybyLink.SetShowDialog();
                        PaybyLink.IssuePayByLink();
                    end;
                }
            }
        }
        addlast(navigation)
        {
            group("NPR PayByLink Navigation")
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
                    var
                        MagentoPaymentLine: Record "NPR Magento Payment Line";
                    begin
                        MagentoPaymentLine.Reset();
                        MagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
                        MagentoPaymentLine.SetRange("Document No.", Rec."No.");
                        Page.Run(Page::"NPR Magento Payment Line List", MagentoPaymentLine);
                    end;
                }
            }
        }
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        addlast("&Invoice")
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
                        RSEIOutSalesInvMgt: Codeunit "NPR RS EI Out Sales Inv. Mgt.";
                    begin
                        RSEIOutSalesInvMgt.CreateRequestAndSendSalesInvoice(Rec);
                    end;
                }
            }
        }
#endif
    }
    var
        RSAuxSalesInvHeader: Record "NPR RS Aux Sales Inv. Header";
        CROAuxSalesInvHeader: Record "NPR CRO Aux Sales Inv. Header";
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RSEIAuxSalesInvHdr: Record "NPR RS EI Aux Sales Inv. Hdr.";
#endif
#if not BC17
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
#endif
        OIOUBLInstalled: Boolean;
#if not BC17
        ShopifyIntegrationIsEnabled: Boolean;
#endif
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        IsRSEInvoiceSent: Boolean;
        IsModelFilled: Boolean;
        IsDocForSendingToSEF: Boolean;
#endif

    trigger OnOpenPage()
    var
        OIOUBLSetup: Record "NPR OIOUBL Setup";
#if not BC17
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
#endif
    begin
        OIOUBLInstalled := OIOUBLSetup.IsOIOUBLInstalled();
#if not BC17
        ShopifyIntegrationIsEnabled := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders");
#endif
    end;

    trigger OnAfterGetCurrRecord()
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    var
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
#endif
    begin
        RSAuxSalesInvHeader.ReadRSAuxSalesInvHeaderFields(Rec);
        CROAuxSalesInvHeader.ReadCROAuxSalesInvHeaderFields(Rec);
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RSEIAuxSalesInvHdr.ReadRSEIAuxSalesInvHdrFields(Rec);
        IsRSEInvoiceSent := RSEInvoiceMgt.CheckIsRSEInvoiceSent(Rec."No.");
        IsDocForSendingToSEF := RSEInvoiceMgt.CheckIsDocumentSetForSendingToSEF(RSEIAuxSalesInvHdr);
        IsModelFilled := false;
#endif
    end;
}