pageextension 6014440 "NPR Sales Order" extends "Sales Order"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("NPR Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
            {
                ToolTip = 'Specifies the name of the customer who will receive the products and be billed by default.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Ship-to Name")
        {
            field("NPR Ship-to Name 2"; Rec."Ship-to Name 2")
            {
                ToolTip = 'Specifies the additional name that products on the sales document will be shipped to.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Bill-to Name")
        {
            field("NPR Bill-to Name 2"; Rec."Bill-to Name 2")
            {
                ToolTip = 'Specifies the customer to whom you will send the sales invoice, when different from the customer that you are selling to.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter(Status)
        {
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

        addafter(Control85)
        {
            field("NPR Bill-to Company"; Rec."NPR Bill-to Company")
            {
                ToolTip = 'Specifies the company that you will send the invoice to.';
                ApplicationArea = NPRRetail;
                ObsoleteState = Pending;
                ObsoleteTag = '2023-06-28';
                ObsoleteReason = 'Not Used.';
            }
            field("NPR Bill-To Vendor No."; Rec."NPR Bill-To Vendor No.")
            {
                ToolTip = 'Specifies the vendor number to whom you will send the sales invoice.';
                ApplicationArea = NPRRetail;
                ObsoleteState = Pending;
                ObsoleteTag = '2023-06-28';
                ObsoleteReason = 'Not Used.';
            }
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
        addafter("Shipping Advice")
        {
            field("NPR Delivery Location"; Rec."NPR Delivery Location")
            {
                ToolTip = 'Specifies where the items from the sales document are shipped to.';
                ApplicationArea = NPRRetail;
            }
            field("NPR Delivery Instructions"; Rec."NPR Delivery Instructions")
            {
                ToolTip = 'Specifies the specific delivery instructions related to sales order.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Shipping Time")
        {
            field("NPR Package Code"; Rec."NPR Package Code")
            {
                ToolTip = 'Specifies the value of the Package Code field.';
                ApplicationArea = NPRRetail;
            }
            field("NPR Kolli"; Rec."NPR Kolli")
            {
                ToolTip = 'Specifies the number of packages';
                ApplicationArea = NPRRetail;
            }
            field("NPR Package Quantity"; Rec."NPR Package Quantity")
            {
                ToolTip = 'Specifies the value of the Package Quantity field.';
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
                Caption = 'RS Additional Cust. Identification';
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
                Caption = 'CRO POS Unit No.';
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
        addlast("Invoice Details")
        {
            field("NPR Magento Payment Amount"; Rec."NPR Magento Payment Amount")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the sum of Payment Lines attached to the Sales Order';
            }
        }
        addafter("Prepayment %")
        {
            field("NPR Prepayment Amount"; RSSalesHeader."Prepmt. Amount Incl. VAT")
            {
                ApplicationArea = NPRRSLocal;
                BlankZero = true;
                Caption = 'Prepayment Amount Incl. VAT';
                ToolTip = 'Specifies the value of the Prepayment Amount field.';
                trigger OnValidate()
                begin
                    RSSalesHeader.Validate("Prepmt. Amount Incl. VAT");
                    RSSalesHeader.Save();
                    CurrPage.Update();
                end;
            }
            field("NPR Applies-to Bank Entry"; RSSalesHeader."Applies-to Bank Entry")
            {
                ApplicationArea = NPRRSLocal;
                BlankZero = true;
                ToolTip = 'Specifies the value of the Applies-to Bank Entry field.';
                Caption = 'Applies-to Bank Entry';
                trigger OnDrillDown()
                var
                    EntryNo: Integer;
                begin
                    EntryNo := RSSalesHeader.DrillDownAppliesToBankEntry(Rec);
                    if EntryNo = 0 then
                        exit;
                    RSSalesHeader.Validate("Applies-to Bank Entry", EntryNo);
                    RSSalesHeader.Save();
                end;

                trigger OnValidate()
                begin
                    RSSalesHeader.CheckValidatedBankEntry(Rec);
                    RSSalesHeader.Validate("Applies-to Bank Entry");
                    RSSalesHeader.Save();
                    CurrPage.Update();
                end;
            }
            field("NPR Bank Prepayment Amount"; RSSalesHeader."Bank Prepayment Amount")
            {
                ApplicationArea = NPRRSLocal;
                BlankZero = true;
                Editable = false;
                Caption = 'Bank Prepayment Amount';
                ToolTip = 'Specifies the value of the Bank Prepayment Amount field.';
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
                ToolTip = 'Specifies the Shopify Order ID assigned to the document.';
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

        modify(Control1900316107)
        {
            Visible = false;
        }
    }
    actions
    {
        addafter(DocAttach)
        {
            action("NPR POS Entry")
            {
                Caption = 'POS Entry';
                Image = Entry;
                ToolTip = 'View the POS entry for this order.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSEntryNavigation: Codeunit "NPR POS Entry Navigation";
                begin
                    POSEntryNavigation.OpenPOSEntryListFromSalesDocument(Rec);
                end;
            }
        }
        addafter(History)
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
        addfirst("F&unctions")
        {
            action("NPR Import From Scanner")
            {
                Caption = 'Import From Scanner';
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
        addafter("Send IC Sales Order")
        {
            action("NPR SelectRecommendedItem")
            {
                Caption = 'Select Recommended Item';
                Image = SuggestLines;
                ToolTip = 'Select the item that is marked as Recommended.';
                ApplicationArea = NPRRetail;
            }
            action("NPR InsertLineItem ")
            {
                Caption = 'Insert Line with Item';
                Image = CoupledOrderList;
                ShortCutKey = 'Ctrl+I';
                ToolTip = 'Enable inserting multiple items by searching through the item list.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    Item: Record Item;
                    SalesLine: Record "Sales Line";
                    LastSalesLine: Record "Sales Line";
                    RetailItemList: Page "Item List";
                    InputDialog: Page "NPR Input Dialog";
                    ViewText: Text;
                    InputQuantity: Decimal;
                begin
                    Rec.TestField(Status, Rec.Status::Open);
                    Rec.TestField("Sell-to Customer No.");
                    RetailItemList.NPR_SetLocationCode(Rec."Location Code");
                    RetailItemList.NPR_SetBlocked(2);
                    RetailItemList.LookupMode := true;
                    while RetailItemList.RunModal() = ACTION::LookupOK do begin
                        RetailItemList.GetRecord(Item);

                        InputQuantity := 1;
                        InputDialog.SetAutoCloseOnValidate(true);
                        InputDialog.SetInput(1, InputQuantity, SalesLine.FieldCaption(Quantity));
                        InputDialog.RunModal();
                        InputDialog.InputDecimal(1, InputQuantity);
                        Clear(InputDialog);

                        LastSalesLine.Reset();
                        LastSalesLine.SetRange("Document Type", Rec."Document Type");
                        LastSalesLine.SetRange("Document No.", Rec."No.");
                        if not LastSalesLine.FindLast() then
                            LastSalesLine.Init();

                        SalesLine.Init();
                        SalesLine.Validate("Document Type", Rec."Document Type");
                        SalesLine.Validate("Document No.", Rec."No.");
                        SalesLine.Validate("Line No.", LastSalesLine."Line No." + 10000);
                        SalesLine.Insert(true);
                        SalesLine.Validate(Type, SalesLine.Type::Item);
                        SalesLine.Validate("No.", Item."No.");
                        SalesLine.Validate(Quantity, InputQuantity);
                        SalesLine.Modify(true);
                        Commit();
                        ViewText := RetailItemList.NPR_GetViewText();
                        Clear(RetailItemList);
                        RetailItemList.NPR_SetLocationCode(Rec."Location Code");
                        RetailItemList.NPR_SetVendorNo(Rec."NPR Buy-From Vendor No.");
                        Item.SetView(ViewText);
                        RetailItemList.SetTableView(Item);
                        RetailItemList.SetRecord(Item);
                        RetailItemList.LookupMode := true;
                    end;
                end;
            }
        }
        addafter("Request Approval")
        {
            group("NPR Retail Voucher")
            {
                Caption = 'Retail Voucher';
                Image = Voucher;
                action("NPR Issue Voucher")
                {
                    Caption = 'Issue Voucher';
                    Image = PostedPayableVoucher;
                    ToolTip = 'Enable viewing/editing the voucher list.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
                    begin
                        NpRvSalesDocMgt.IssueVoucherAction(Rec);
                    end;
                }
                action("NPR Redeem Voucher")
                {
                    Caption = 'Redeem Voucher';
                    Image = PostedReceivableVoucher;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Enable searching the list of vouchers by reference number and redeeming it.';

                    trigger OnAction()
                    var
                        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
                    begin
                        NpRvSalesDocMgt.RedeemVoucherAction(Rec);
                    end;
                }
            }
        }
        addafter("Pick Instruction")
        {
            action("NPR Consignor Label")
            {
                Caption = 'Consignor Label';
                ToolTip = 'Print the Consignor Label.';
                Image = Print;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ConsignorEntry: Record "NPR Consignor Entry";
                begin
                    ConsignorEntry.InsertFromSalesHeader(Rec."No.");
                end;
            }
            action("NPR PrintShippingLabel")
            {
                Caption = 'Shipping Label';
                Image = PrintCheck;
                ToolTip = 'Create a Shipping Label with all necessary information.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                    LabelManagement: Codeunit "NPR Label Management";
                    RecRef: RecordRef;
                begin
                    SalesHeader := Rec;
                    SalesHeader.SetRecFilter();
                    RecRef.GetTable(SalesHeader);
                    LabelManagement.PrintCustomShippingLabel(RecRef, '');
                end;
            }
            group("NPR SMS")
            {
                Caption = 'SMS';
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
            group("NPR Variants")
            {
                Caption = 'Variants';
                action("NPR Variety")
                {
                    Caption = 'Variety';
                    ShortCutKey = 'Ctrl+Alt+V';
                    ToolTip = 'View the variety matrix for the item used on the Purchase Order Line.';
                    Image = Edit;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        SalesLine: Record "Sales Line";
                        VRTWrapper: Codeunit "NPR Variety Wrapper";
                    begin
                        CurrPage.SalesLines.PAGE.GetRecord(SalesLine);
                        VRTWrapper.SalesLineShowVariety(SalesLine, 0);
                    end;
                }
            }
        }
        addafter(Documents)
        {
            action("NPR TransferOrders")
            {
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedCategory = Category12;
                Caption = 'Transfer Orders';
                ToolTip = 'Display Transfer Order which has External Document No. equal to Order No.';
                Image = TransferOrder;

                trigger OnAction()
                var
                    TransferHeader: Record "Transfer Header";
                begin
                    TransferHeader.SetRange("External Document No.", Rec."No.");
                    Page.Run(Page::"Transfer Orders", TransferHeader);
                end;
            }
        }
        addlast("&Print")
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
        CROAuxSalesHeader: Record "NPR CRO Aux Sales Header";
        RSSalesHeader: Record "NPR RS Sales Header";
#if not BC17
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
#endif
        AsyncEnabled: Boolean;
#if not BC17
        ShopifyIntegrationIsEnabled: Boolean;
#endif

    trigger OnAfterGetCurrRecord()
    begin
        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(Rec);
        RSSalesHeader.Read(Rec.SystemId);
        CROAuxSalesHeader.ReadCROAuxSalesHeaderFields(Rec);
    end;

    trigger OnOpenPage()
    var
        POSAsyncPostingMgt: Codeunit "NPR POS Async. Posting Mgt.";
#if not BC17
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
#endif
    begin
        AsyncEnabled := POSAsyncPostingMgt.SetVisibility();
#if not BC17
        ShopifyIntegrationIsEnabled := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders");
#endif
    end;
}
