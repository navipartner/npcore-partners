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
        }
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
    }

    var
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";

    trigger OnAfterGetCurrRecord()
    begin
        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(Rec);
    end;
}