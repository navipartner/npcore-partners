pageextension 6014456 "NPR Purchase Credit Memo" extends "Purchase Credit Memo"
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
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        modify("Vendor Cr. Memo No.")
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
                    Caption = 'RS EI Tax Liability Method';
                    ToolTip = 'Specifies the value of the RS EI Tax Liability Method field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Sales Invoice Id"; RSEIAuxPurchHeader."NPR RS EI Sales Invoice ID")
                {
                    Caption = 'RS EI Sales Invoice ID';
                    ToolTip = 'Specifies the value of the RS EI Sales Invoice ID field.';
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
                    Caption = 'RS EI Purchase Invoice ID';
                    ToolTip = 'Specifies the value of the RS EI Purchase Invoice ID field.';
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
                    Caption = 'RS EI Invoice Status';
                    ToolTip = 'Specifies the value of the RS EI Invoice Status field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Total Amount"; RSEIAuxPurchHeader."NPR RS EI Total Amount")
                {
                    Caption = 'RS EI Total Amount';
                    ToolTip = 'Specifies the value of the RS EI Total Amount field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Creation Date"; RSEIAuxPurchHeader."NPR RS EI Creation Date")
                {
                    Caption = 'RS EI Creation Date';
                    ToolTip = 'Specifies the value of the RS EI Creation Date field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Sending Date"; RSEIAuxPurchHeader."NPR RS EI Sending Date")
                {
                    Caption = 'RS EI Sending Date';
                    ToolTip = 'Specifies the value of the RS EI Sending Date field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Model"; RSEIAuxPurchHeader."NPR RS EI Model")
                {
                    Caption = 'RS EI Model';
                    ToolTip = 'Specifies the value of the RS EI Model field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
                field("NPR RS EI Reference Number"; RSEIAuxPurchHeader."NPR RS EI Reference Number")
                {
                    Caption = 'RS EI Reference Number';
                    ToolTip = 'Specifies the value of the RS EI Reference Number field.';
                    ApplicationArea = NPRRSEInvoice;
                    Editable = false;
                }
            }
        }
#endif
    }
    actions
    {
        addfirst("F&unctions")
        {
            action("NPR Import From Scanner File")
            {
                Caption = 'Import From Scanner File';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
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
                    ScannerImportMgt.ImportFromScanner(InventorySetup."NPR Scanner Provider", Enum::"NPR Scanner Import"::PURCHASE, RecRef);
                end;
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