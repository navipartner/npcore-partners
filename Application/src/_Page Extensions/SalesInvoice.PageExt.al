pageextension 6014442 "NPR Sales Invoice" extends "Sales Invoice"
{
    layout
    {
        addafter(Status)
        {
            field("NPR Group Code"; Rec."NPR Group Code")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Group Code field.';
            }
            field("NPR Sales Channel"; Rec."NPR Sales Channel")
            {
                ToolTip = 'Specifies the value of the Sales Channel field';
                Visible = false;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            field("NPR Posting No."; Rec."Posting No.")
            {
                ApplicationArea = NPRRetail;
                Importance = Additional;
                Visible = false;
                ToolTip = 'Specifies the value of the Posting No. field.';
            }
        }

        addafter("Posting Date")
        {
            field("NPR NPPostingDescription1"; Rec."Posting Description")
            {

                Visible = false;
                ToolTip = 'Specifies the date when the posting of the sales document will be recorded.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter(Control174)
        {
            field("NPR Bill-to E-mail"; Rec."NPR Bill-to E-mail")
            {
                ToolTip = 'Specifies the e-mail address of the customer contact you are sending the invoice to.';
                ApplicationArea = NPRRetail;
            }
            field("NPR Bill-to Phone No."; Rec."NPR Bill-to Phone No.")
            {
                ToolTip = 'Specifies the phone number of the customer contact you are sending the invoice to.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Salesperson Code")
        {
            field("NPR RS POS Unit"; RSAuxSalesHeader."NPR RS POS Unit")
            {
                Caption = 'RS POS Unit';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS POS Unit field.';
                ShowMandatory = true;
                TableRelation = "NPR POS Unit";
                trigger OnValidate()
                begin
                    RSAuxSalesHeader.Validate("NPR RS POS Unit");
                    RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
                end;
            }
            field("NPR RS Cust. Ident. Type"; RSAuxSalesHeader."NPR RS Cust. Ident. Type")
            {
                Caption = 'RS Customer Identification Type';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS Customer Identification Type field.';
                trigger OnValidate()
                begin
                    RSAuxSalesHeader.Validate("NPR RS Cust. Ident. Type");
                    RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
                end;
            }
            field("NPR RS Customer Ident."; RSAuxSalesHeader."NPR RS Customer Ident.")
            {
                Caption = 'RS Customer Identification';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS Customer Identification field.';
                trigger OnValidate()
                begin
                    RSAuxSalesHeader.Validate("NPR RS Customer Ident.");
                    RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
                end;
            }
            field("NPR RS Add. Cust. Ident. Type"; RSAuxSalesHeader."NPR RS Add. Cust. Ident. Type")
            {
                Caption = 'RS Optional Cust. Identification Type';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS Optional Cust. Identification Type field.';
                trigger OnValidate()
                begin
                    RSAuxSalesHeader.Validate("NPR RS Add. Cust. Ident. Type");
                    RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
                end;
            }
            field("NPR RS Add. Cust. Ident."; RSAuxSalesHeader."NPR RS Add. Cust. Ident.")
            {
                Caption = 'RS Additional Cust. Identification';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS Additional Cust. Identification field.';
                trigger OnValidate()
                begin
                    RSAuxSalesHeader.Validate("NPR RS Add. Cust. Ident.");
                    RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
                end;
            }
            field("NPR RS Audit Entry"; RSAuxSalesHeader."NPR RS Audit Entry")
            {
                Caption = 'RS Audit Entry';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS Audit Entry field.';
                Editable = false;
            }
            field("NPR CRO POS Unit"; CROAuxSalesHeader."NPR CRO POS Unit")
            {
                Caption = 'CRO POS Unit';
                ApplicationArea = NPRCROFiscal;
                ToolTip = 'Specifies the value of the CRO POS Unit field.';
                TableRelation = "NPR POS Unit";
                trigger OnValidate()
                begin
                    CROAuxSalesHeader.Validate("NPR CRO POS Unit");
                    CROAuxSalesHeader.SaveCROAuxSalesHeaderFields();
                end;
            }
            field("NPR SI POS Unit"; SIAuxSalesHeader."NPR SI POS Unit")
            {
                Caption = 'SI POS Unit';
                ApplicationArea = NPRSIFiscal;
                ToolTip = 'Specifies the value of the SI POS Unit field.';
                TableRelation = "NPR POS Unit";
                trigger OnValidate()
                begin
                    SIAuxSalesHeader.Validate("NPR SI POS Unit");
                    SIAuxSalesHeader.SaveSIAuxSalesHeaderFields();
                end;
            }
        }
#if not (BC17 or BC18 or BC19 or BC20 or BC21)

        addlast(content)
        {
            group("NPR RS E-Invoicing")
            {
                Caption = 'RS E-Invoicing';

                field("NPR RS EI Send To SEF"; RSEIAuxSalesHeader."NPR RS EI Send To SEF")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Send To SEF';
                    ToolTip = 'Specifies the value of the Send To SEF field.';
                    trigger OnValidate()
                    begin
                        RSEIAuxSalesHeader.SaveRSEIAuxSalesHeaderFields();
                        IsDocForSendingToSEF := RSEIAuxSalesHeader."NPR RS EI Send To SEF";
                        RSEIAuxSalesHeader.SetReferenceNumberFromSalesHeader(Rec);
                    end;
                }
                field("NPR RS EI Send To CIR"; RSEIAuxSalesHeader."NPR RS EI Send To CIR")
                {
                    ApplicationArea = NPRRSEInvoice;
                    Caption = 'Send To CIR';
                    ToolTip = 'Specifies the value of the Send To CIR field.';
                    Enabled = IsDocForSendingToSEF;
                    trigger OnValidate()
                    begin
                        RSEIAuxSalesHeader.SaveRSEIAuxSalesHeaderFields();
                    end;
                }
                field("NPR RS EI Tax Liability Method"; RSEIAuxSalesHeader."NPR RS EI Tax Liability Method")
                {
                    Caption = 'Tax Liability Method';
                    ToolTip = 'Specifies the value of the Tax Liability Method field.';
                    ApplicationArea = NPRRSEInvoice;
                    Enabled = IsDocForSendingToSEF;
                    trigger OnValidate()
                    begin
                        RSEIAuxSalesHeader.SaveRSEIAuxSalesHeaderFields();
                    end;
                }
                field("NPR RS EI Model"; RSEIAuxSalesHeader."NPR RS EI Model")
                {
                    Caption = 'Model';
                    ToolTip = 'Specifies the value of the RS Model field.';
                    ApplicationArea = NPRRSEInvoice;
                    Enabled = IsDocForSendingToSEF;
                    trigger OnValidate()
                    begin
                        IsModelFilled := (RSEIAuxSalesHeader."NPR RS EI Model" <> '');
                        if IsModelFilled then
                            RSEIAuxSalesHeader."NPR RS EI Reference Number" := '';
                        RSEIAuxSalesHeader.SaveRSEIAuxSalesHeaderFields();
                    end;
                }
                field("NPR RS EI Reference Number"; RSEIAuxSalesHeader."NPR RS EI Reference Number")
                {
                    Caption = 'Reference Number';
                    ToolTip = 'Specifies the value of the RS Reference Number field.';
                    ApplicationArea = NPRRSEInvoice;
                    Enabled = IsDocForSendingToSEF;
                    Editable = IsModelFilled;
                    trigger OnValidate()
                    begin
                        RSEIAuxSalesHeader.SaveRSEIAuxSalesHeaderFields();
                    end;
                }
            }
        }
#endif
    }
    actions
    {
        addafter("Co&mments")
        {
            action("NPR POS Entry")
            {
                Caption = 'POS Entry';
                Image = Entry;

                ToolTip = 'View all the POS entries for this item.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSEntryNavigation: Codeunit "NPR POS Entry Navigation";
                begin
                    POSEntryNavigation.OpenPOSEntryListFromSalesDocument(Rec);
                end;
            }
        }
        addafter("&Invoice")
        {
            group("NPR Retail")
            {
                Caption = 'Retail';
                action("NPR Retail Vouchers")
                {
                    Caption = 'Retail Vouchers';
                    Image = Certificate;

                    ToolTip = 'View all vouchers for the selected customer.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
                    begin
                        NpRvSalesDocMgt.ShowRelatedVouchersAction(Rec);
                    end;
                }
            }
        }
        addafter("Move Negative Lines")
        {
            action("NPR ImportFromScanner")
            {
                Caption = 'Import from scanner';
                Image = Import;
                Promoted = true;
                PromotedOnly = true;

                ToolTip = 'Start importing the file from the scanner.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    InventorySetup: Record "Inventory Setup";
                    ScannerImportMgt: Codeunit "NPR Scanner Import Mgt.";
                    RecRef: RecordRef;
                begin
                    if not InventorySetup.Get() then
                        exit;

                    RecRef.GetTable(Rec);
                    ScannerImportMgt.ImportFromScanner(InventorySetup."NPR Scanner Provider", Enum::"NPR Scanner Import"::SALES, RecRef);
                end;
            }
        }
        addafter("F&unctions")
        {
            group("NPR Retail Voucher")
            {
                action("NPR Issue Voucher")
                {
                    Caption = 'Issue Voucher';
                    Image = PostedPayableVoucher;

                    ToolTip = 'View all the Issued Vouchers for the customer selected.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
                    begin
                        NpRvSalesDocMgt.IssueVoucherAction(Rec);
                    end;
                }
            }
        }
        addafter("P&osting")
        {
            group("NPR PayByLink")
            {
                Caption = 'Pay by Link';
                ToolTip = 'Pay by Link';
                Image = Payment;

                action("NPR Pay by link")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Pay by Link';
                    ToolTip = 'Pay by Link';
                    Image = LinkWeb;

                    trigger OnAction()
                    var
                        PaybyLink: Interface "NPR Pay by Link";
                        AdyenSetup: Record "NPR Adyen Setup";
                        MagentoPaymentGateway: Record "NPR Magento Payment Gateway";
                    begin
                        AdyenSetup.Get();
                        MagentoPaymentGateway.Get(AdyenSetup."Pay By Link Gateaway Code");
                        PaybyLink := MagentoPaymentGateway."Integration Type";
                        PaybyLink.SetDocument(Rec);
                        PaybyLink.SetShowDialog();
                        PaybyLink.IssuePayByLink();
                    end;
                }
            }
        }
        addafter(ProformaInvoice)
        {
            action("NPR RS Thermal Print Bill")
            {
                Caption = 'Print RS Bill';
                ToolTip = 'Executing this action starts connection with hardware connector and try to print RS Bill from RS Audit Log.';
                ApplicationArea = NPRRSFiscal;
                Image = PrintCover;
                trigger OnAction()
                var
                    RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
                begin
                    RSAuditMgt.TermalPrintSalesHeader(Rec);
                end;
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
                    begin
                        Rec.OpenMagentPaymentLines();
                    end;
                }
            }
        }

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        addlast("&Invoice")
        {
            action("NPR RS EI Apply Tax Exemption")
            {
                Caption = 'Apply Tax Exemption Reason';
                ToolTip = 'Executes the Apply Tax Exemption Reason action.';
                ApplicationArea = NPRRSEInvoice;
                Image = TaxSetup;
                Promoted = true;
                PromotedCategory = Category7;

                trigger OnAction()
                begin
                    RSEInvoiceMgt.ApplyTaxExemptionReason(Rec);
                end;
            }
        }
#endif
    }

    var
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
        CROAuxSalesHeader: Record "NPR CRO Aux Sales Header";
        SIAuxSalesHeader: Record "NPR SI Aux Sales Header";
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RSEIAuxSalesHeader: Record "NPR RS EI Aux Sales Header";
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
        IsModelFilled: Boolean;
        IsDocForSendingToSEF: Boolean;
#endif

    trigger OnAfterGetCurrRecord()
    begin
        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(Rec);
        CROAuxSalesHeader.ReadCROAuxSalesHeaderFields(Rec);
        SIAuxSalesHeader.ReadSIAuxSalesHeaderFields(Rec);
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RSEIAuxSalesHeader.SetReferenceNumberFromSalesHeader(Rec);
        IsDocForSendingToSEF := RSEInvoiceMgt.CheckIsDocumentSetForSendingToSEF(RSEIAuxSalesHeader);
        IsModelFilled := false;
#endif
    end;
}