pageextension 6014524 "NPR Posted Purchase Cr. Memo" extends "Posted Purchase Credit Memo"
{
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    layout
    {
        addlast(content)
        {
            group("NPR RS E-Invoicing")
            {
                Caption = 'RS E-Invoicing';

                field("NPR RS E-Invoice"; RSEIAuxPurchCrMemHdr."NPR RS E-Invoice")
                {
                    Caption = 'RS E-Invoice';
                    ToolTip = 'Specifies the value of the RS E-Invoice field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Tax Liability Method"; RSEIAuxPurchCrMemHdr."NPR RS EI Tax Liability Method")
                {
                    Caption = 'Tax Liability Method';
                    ToolTip = 'Specifies the value of the Tax Liability Method field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Sales Invoice Id"; RSEIAuxPurchCrMemHdr."NPR RS EI Sales Invoice ID")
                {
                    Caption = 'Sales Invoice ID';
                    ToolTip = 'Specifies the value of the Sales Invoice ID field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                    trigger OnDrillDown()
                    var
                        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
                    begin
                        RSEInvoiceDocument.SetRange("Sales Invoice ID", RSEIAuxPurchCrMemHdr."NPR RS EI Sales Invoice ID");
                        Page.Run(Page::"NPR RS E-Invoice Documents", RSEInvoiceDocument);
                    end;
                }
                field("NPR RS EI Purchase Invoice Id"; RSEIAuxPurchCrMemHdr."NPR RS EI Purchase Invoice ID")
                {
                    Caption = 'Purchase Invoice ID';
                    ToolTip = 'Specifies the value of the Purchase Invoice ID field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                    trigger OnDrillDown()
                    var
                        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
                    begin
                        RSEInvoiceDocument.SetRange("Purchase Invoice ID", RSEIAuxPurchCrMemHdr."NPR RS EI Purchase Invoice ID");
                        Page.Run(Page::"NPR RS E-Invoice Documents", RSEInvoiceDocument);
                    end;
                }
                field("NPR RS EI Invoice Status"; RSEIAuxPurchCrMemHdr."NPR RS EI Invoice Status")
                {
                    Caption = 'Invoice Status';
                    ToolTip = 'Specifies the value of the Invoice Status field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Invoice Type Code"; RSEIAuxPurchCrMemHdr."NPR RS E-Invoice Type Code")
                {
                    Caption = 'Invoice Type Code';
                    ToolTip = 'Specifies the value of the Invoice Type Code field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Total Amount"; RSEIAuxPurchCrMemHdr."NPR RS EI Total Amount")
                {
                    Caption = 'Total Amount';
                    ToolTip = 'Specifies the value of the Total Amount field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Creation Date"; RSEIAuxPurchCrMemHdr."NPR RS EI Creation Date")
                {
                    Caption = 'Creation Date';
                    ToolTip = 'Specifies the value of the Creation Date field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Sending Date"; RSEIAuxPurchCrMemHdr."NPR RS EI Sending Date")
                {
                    Caption = 'Sending Date';
                    ToolTip = 'Specifies the value of the Sending Date field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Model"; RSEIAuxPurchCrMemHdr."NPR RS EI Model")
                {
                    Caption = 'Model';
                    ToolTip = 'Specifies the value of the Model field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Reference Number"; RSEIAuxPurchCrMemHdr."NPR RS EI Reference Number")
                {
                    Caption = 'Reference Number';
                    ToolTip = 'Specifies the value of the Reference Number field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        RSEIAuxPurchCrMemHdr.ReadRSEIAuxPurchCrMemHdrFields(Rec);
    end;

    var
        RSEIAuxPurchCrMemHdr: Record "NPR RS EI Aux Purch. CrMem Hdr";
#endif
}