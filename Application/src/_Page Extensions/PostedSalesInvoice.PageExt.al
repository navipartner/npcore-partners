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
    }
    var
        RSAuxSalesInvHeader: Record "NPR RS Aux Sales Inv. Header";
        CROAuxSalesInvHeader: Record "NPR CRO Aux Sales Inv. Header";
#if not BC17
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
#endif
        OIOUBLInstalled: Boolean;
#if not BC17
        ShopifyIntegrationIsEnabled: Boolean;
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
    begin
        RSAuxSalesInvHeader.ReadRSAuxSalesInvHeaderFields(Rec);
        CROAuxSalesInvHeader.ReadCROAuxSalesInvHeaderFields(Rec);
    end;
}