pageextension 6014412 "NPR Sales Credit Memo" extends "Sales Credit Memo"
{
    layout
    {
        addafter(Status)
        {
            field("NPR Correction"; Rec.Correction)
            {
                ApplicationArea = NPRRetail;
                Importance = Additional;
                ToolTip = 'Specifies whether this credit memo is to be posted as a corrective entry.';
            }

            field("NPR Group Code"; Rec."NPR Group Code")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Group Code field.';
            }
            field("NPR PR POS Trans. Scheduled For Post"; Rec."NPR POS Trans. Sch. For Post")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies if there are POS entries scheduled for posting';
                Visible = AsyncEnabled;
                trigger OnDrillDown()
                var
                    POSAsyncPostingMgt: Codeunit "NPR POS Async. Posting Mgt.";
                begin
                    POSAsyncPostingMgt.ScheduledTransFromPOSOnDrillDown(Rec);
                end;
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

        addlast("Credit Memo Details")
        {
            field("NPR Magento Payment Amount"; Rec."NPR Magento Payment Amount")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the sum of Payment Lines attached to the Sales Credit Memo';
            }
        }
        addafter("Salesperson Code")
        {
            field("NPR RS POS Unit"; RSAuxSalesHeader."NPR RS POS Unit")
            {
                Caption = 'RS POS Unit';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS POS Unit field.';
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
                Caption = 'RS Additional Cust. Identification Type';
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
            field("NPR RS Referent No."; RSAuxSalesHeader."NPR RS Referent No.")
            {
                Caption = 'RS Referent No.';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS Referent No. field.';
                trigger OnValidate()
                begin
                    RSAuxSalesHeader.Validate("NPR RS Referent No.");
                    RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
                end;
            }
            field("NPR RS Referent Date/Time"; RSAuxSalesHeader."NPR RS Referent Date/Time")
            {
                Caption = 'RS Referent Date/Time';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS Referent Date/Time field.';
                trigger OnValidate()
                begin
                    RSAuxSalesHeader.Validate("NPR RS Referent Date/Time");
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
                Caption = 'POS Unit No.';
                ApplicationArea = NPRCROFiscal;
                ToolTip = 'Specifies the value of the POS Unit No. field.';
                TableRelation = "NPR POS Unit";
                trigger OnValidate()
                begin
                    CROAuxSalesHeader.Validate("NPR CRO POS Unit");
                    CROAuxSalesHeader.SaveCROAuxSalesHeaderFields();
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
        addlast(navigation)
        {
            group("NPR PayByLink")
            {
                Caption = 'Pay by Link';
                Image = Payment;
                action("NPR Payment Lines")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Payment Lines';
                    Image = PaymentHistory;
                    ToolTip = 'View Pay by Link Payment Lines';

                    trigger OnAction()
                    begin
                        Rec.OpenMagentPaymentLines();
                    end;
                }
            }
        }
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        addlast("&Credit Memo")
        {
            action("NPR RS EI Apply Tax Exemption")
            {
                Caption = 'Apply Tax Exemption Reason';
                ToolTip = 'Executes the Apply Tax Exemption Reason action.';
                ApplicationArea = NPRRSEInvoice;
                Image = TaxSetup;
                Promoted = true;
                PromotedCategory = Category8;
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
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RSEIAuxSalesHeader: Record "NPR RS EI Aux Sales Header";
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
        IsDocForSendingToSEF: Boolean;
        IsModelFilled: Boolean;
#endif
        AsyncEnabled: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(Rec);
        CROAuxSalesHeader.ReadCROAuxSalesHeaderFields(Rec);
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RSEIAuxSalesHeader.ReadRSEIAuxSalesHeaderFields(Rec);
        RSEIAuxSalesHeader.SetDefaultTaxLiabilityForSalesCrMemo(Rec);
        IsDocForSendingToSEF := RSEInvoiceMgt.CheckIsDocumentSetForSendingToSEF(RSEIAuxSalesHeader);
        IsModelFilled := false;
#endif
    end;

    trigger OnOpenPage()
    var
        POSAsyncPostingMgt: Codeunit "NPR POS Async. Posting Mgt.";
    begin
        AsyncEnabled := POSAsyncPostingMgt.SetVisibility();
    end;
}