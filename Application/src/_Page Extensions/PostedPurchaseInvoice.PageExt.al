pageextension 6014514 "NPR Posted Purchase Invoice" extends "Posted Purchase Invoice"
{
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    layout
    {
        addlast(content)
        {
            group("NPR RS E-Invoicing")
            {
                Caption = 'RS E-Invoicing';

                field("NPR RS E-Invoice"; RSEIAuxPurchInvHdr."NPR RS E-Invoice")
                {
                    Caption = 'RS E-Invoice';
                    ToolTip = 'Specifies the value of the RS E-Invoice field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Tax Liability Method"; RSEIAuxPurchInvHdr."NPR RS EI Tax Liability Method")
                {
                    Caption = 'Tax Liability Method';
                    ToolTip = 'Specifies the value of the Tax Liability Method field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Sales Invoice Id"; RSEIAuxPurchInvHdr."NPR RS EI Sales Invoice ID")
                {
                    Caption = 'Sales Invoice ID';
                    ToolTip = 'Specifies the value of the Sales Invoice ID field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                    trigger OnDrillDown()
                    var
                        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
                    begin
                        RSEInvoiceDocument.SetRange("Sales Invoice ID", RSEIAuxPurchInvHdr."NPR RS EI Sales Invoice ID");
                        Page.Run(Page::"NPR RS E-Invoice Documents", RSEInvoiceDocument);
                    end;
                }
                field("NPR RS EI Purchase Invoice Id"; RSEIAuxPurchInvHdr."NPR RS EI Purchase Invoice ID")
                {
                    Caption = 'Purchase Invoice ID';
                    ToolTip = 'Specifies the value of the Purchase Invoice ID field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                    trigger OnDrillDown()
                    var
                        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
                    begin
                        RSEInvoiceDocument.SetRange("Purchase Invoice ID", RSEIAuxPurchInvHdr."NPR RS EI Purchase Invoice ID");
                        Page.Run(Page::"NPR RS E-Invoice Documents", RSEInvoiceDocument);
                    end;
                }
                field("NPR RS EI Invoice Status"; RSEIAuxPurchInvHdr."NPR RS EI Invoice Status")
                {
                    Caption = 'Invoice Status';
                    ToolTip = 'Specifies the value of the Invoice Status field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Invoice Type Code"; RSEIAuxPurchInvHdr."NPR RS E-Invoice Type Code")
                {
                    Caption = 'Invoice Type Code';
                    ToolTip = 'Specifies the value of the Invoice Type Code field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Total Amount"; RSEIAuxPurchInvHdr."NPR RS EI Total Amount")
                {
                    Caption = 'Total Amount';
                    ToolTip = 'Specifies the value of the Total Amount field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Creation Date"; RSEIAuxPurchInvHdr."NPR RS EI Creation Date")
                {
                    Caption = 'Creation Date';
                    ToolTip = 'Specifies the value of the Creation Date field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Sending Date"; RSEIAuxPurchInvHdr."NPR RS EI Sending Date")
                {
                    Caption = 'Sending Date';
                    ToolTip = 'Specifies the value of the Sending Date field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Model"; RSEIAuxPurchInvHdr."NPR RS EI Model")
                {
                    Caption = 'Model';
                    ToolTip = 'Specifies the value of the Model field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Reference Number"; RSEIAuxPurchInvHdr."NPR RS EI Reference Number")
                {
                    Caption = 'Reference Number';
                    ToolTip = 'Specifies the value of the Reference Number field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
            }
        }
    }
#endif
    actions
    {
        addafter(AttachAsPDF)
        {
            action("NPR PrintRetailPrice")
            {
                Caption = 'Print Purchase Price Calculation';
                ToolTip = 'Runs a Purchase Price Calculation report.';
                ApplicationArea = NPRRSRLocal;
                Image = Print;
                Enabled = RetailLocationCodeExists;
                trigger OnAction()
                var
                    RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
                begin
                    RSRLocalizationMgt.RunPostedPurchaseInvoiceCalcReport(Rec."No.", Rec."Posting Date");
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        RSRetailLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
    begin
        RetailLocationCodeExists := RSRetailLocalizationMgt.CheckForRetailLocationLines(Rec);
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RSEIAuxPurchInvHdr.ReadRSEIAuxPurchInvHdrFields(Rec);
#endif
    end;

    var
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RSEIAuxPurchInvHdr: Record "NPR RS EI Aux Purch. Inv. Hdr.";
#endif
        RetailLocationCodeExists: Boolean;
}