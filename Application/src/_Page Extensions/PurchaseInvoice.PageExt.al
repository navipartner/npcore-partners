pageextension 6014454 "NPR Purchase Invoice" extends "Purchase Invoice"
{
    layout
    {
        addlast(General)
        {
            field("NPR Prepayment"; RSPurchaseHeader."Prepayment")
            {
                ApplicationArea = NPRRSLocal;
                Caption = 'Prepayment';
                ToolTip = 'Specifies the value of the Prepayment field.';
                trigger OnValidate()
                begin
                    RSPurchaseHeader.Validate(Prepayment);
                    RSPurchaseHeader.Save();
                end;
            }
        }
        addafter(Control1906949207)
        {
            part("NPR NPAttributes"; "NPR NP Attributes FactBox")
            {
                Provider = PurchLines;
                SubPageLink = "No." = FIELD("No.");
                ApplicationArea = NPRRetail;
            }
        }
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        modify("Vendor Invoice No.")
        {
            Editable = IsDocumentRSEInvoice;
        }
        addlast(content)
        {
            group("NPR RS E-Invoicing")
            {
                Caption = 'RS E-Invoicing';

                field("NPR RS E-Invoice"; RSEIAuxPurchHeader."NPR RS E-Invoice")
                {
                    Caption = 'RS E-Invoice';
                    ToolTip = 'Specifies the value of the RS E-Invoice field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Tax Liability Method"; RSEIAuxPurchHeader."NPR RS EI Tax Liability Method")
                {
                    Caption = 'Tax Liability Method';
                    ToolTip = 'Specifies the value of the Tax Liability Method field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Sales Invoice Id"; RSEIAuxPurchHeader."NPR RS EI Sales Invoice ID")
                {
                    Caption = 'Sales Invoice ID';
                    ToolTip = 'Specifies the value of the Sales Invoice ID field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                    trigger OnDrillDown()
                    var
                        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
                    begin
                        RSEInvoiceDocument.SetRange("Sales Invoice ID", RSEIAuxPurchHeader."NPR RS EI Sales Invoice ID");
                        Page.Run(Page::"NPR RS E-Invoice Documents", RSEInvoiceDocument);
                    end;
                }
                field("NPR RS EI Purchase Invoice Id"; RSEIAuxPurchHeader."NPR RS EI Purchase Invoice ID")
                {
                    Caption = 'Purchase Invoice ID';
                    ToolTip = 'Specifies the value of the Purchase Invoice ID field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                    trigger OnDrillDown()
                    var
                        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
                    begin
                        RSEInvoiceDocument.SetRange("Purchase Invoice ID", RSEIAuxPurchHeader."NPR RS EI Purchase Invoice ID");
                        Page.Run(Page::"NPR RS E-Invoice Documents", RSEInvoiceDocument);
                    end;
                }
                field("NPR RS EI Invoice Status"; RSEIAuxPurchHeader."NPR RS EI Invoice Status")
                {
                    Caption = 'Invoice Status';
                    ToolTip = 'Specifies the value of the Invoice Status field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Invoice Type Code"; RSEIAuxPurchHeader."NPR RS E-Invoice Type Code")
                {
                    Caption = 'Invoice Type Code';
                    ToolTip = 'Specifies the value of the Invoice Type Code field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Total Amount"; RSEIAuxPurchHeader."NPR RS EI Total Amount")
                {
                    Caption = 'Total Amount';
                    ToolTip = 'Specifies the value of the Total Amount field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Creation Date"; RSEIAuxPurchHeader."NPR RS EI Creation Date")
                {
                    Caption = 'Creation Date';
                    ToolTip = 'Specifies the value of the Creation Date field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Sending Date"; RSEIAuxPurchHeader."NPR RS EI Sending Date")
                {
                    Caption = 'Sending Date';
                    ToolTip = 'Specifies the value of the Sending Date field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Model"; RSEIAuxPurchHeader."NPR RS EI Model")
                {
                    Caption = 'Model';
                    ToolTip = 'Specifies the value of the Model field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Reference Number"; RSEIAuxPurchHeader."NPR RS EI Reference Number")
                {
                    Caption = 'Reference Number';
                    ToolTip = 'Specifies the value of the Reference Number field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
            }
        }
#endif
    }
    actions
    {
        addafter(RemoveIncomingDoc)
        {
            action("NPR Show Imported File")
            {
                Caption = 'Show Imported File';

                ToolTip = 'Executes the Show Imported File action and displays imported files.';
                Image = View;
                ApplicationArea = NPRRetail;
                ObsoleteState = Pending;
                ObsoleteTag = '2023-06-28';
                ObsoleteReason = 'Field XML Stylesheet is not used anymore.';
                Visible = false;

                trigger OnAction()
                var
                    NcImportListPg: Page "NPR Nc Import List";
                begin
                    NcImportListPg.ShowFormattedDocByDocNo(Rec."Vendor Invoice No.");
                end;
            }
        }
        addafter("P&osting")
        {
            group("NPR Print")
            {
                Caption = 'Print';
                Image = Print;
                action("NPR RetailPrint")
                {
                    Caption = 'Retail Print';
                    Ellipsis = true;
                    Image = BinContent;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    ToolTip = 'Displays the Retail Journal Print page where different labels can be printed.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        LabelManagement: Codeunit "NPR Label Management";
                    begin
                        LabelManagement.ChooseLabel(Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        RSPurchaseHeader.Read(Rec.SystemId);
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RSEIAuxPurchHeader.ReadRSEIAuxPurchHeaderFields(Rec);
        IsDocumentRSEInvoice := not (RSEIAuxPurchHeader."NPR RS E-Invoice");
#endif
    end;

    var
        RSPurchaseHeader: Record "NPR RS Purchase Header";
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RSEIAuxPurchHeader: Record "NPR RS EI Aux Purch. Header";
        IsDocumentRSEInvoice: Boolean;
#endif
}