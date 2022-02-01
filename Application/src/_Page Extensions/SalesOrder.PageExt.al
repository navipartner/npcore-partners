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
        addafter(Control85)
        {
            field("NPR Bill-to Company"; Rec."NPR Bill-to Company")
            {

                ToolTip = 'Specifies the company that you will send the invoice to.';
                ApplicationArea = NPRRetail;
            }
            field("NPR Bill-To Vendor No."; Rec."NPR Bill-To Vendor No.")
            {

                ToolTip = 'Specifies the vendor number to whom you will send the sales invoice.';
                ApplicationArea = NPRRetail;
            }
            field("NPR Bill-to E-mail"; Rec."NPR Bill-to E-mail")
            {

                ToolTip = 'Specifies the e-mail address of the customer contact you are sending the invoice to.';
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
        addafter("Outbound Whse. Handling Time")
        {
            field("NPR Kolli"; Rec."NPR Kolli")
            {

                ToolTip = 'Specifies the number of packages';
                ApplicationArea = NPRRetail;
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
                    ImportfromScannerFileSO: XMLport "NPR Import from ScannerFileSO";
                begin
                    ImportfromScannerFileSO.SelectTable(Rec);
                    ImportfromScannerFileSO.SetTableView(Rec);
                    ImportfromScannerFileSO.Run();
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
                    LabelLibrary: Codeunit "NPR Label Library";
                    RecRef: RecordRef;
                begin
                    SalesHeader := Rec;
                    SalesHeader.SetRecFilter();
                    RecRef.GetTable(SalesHeader);
                    LabelLibrary.PrintCustomShippingLabel(RecRef, '');
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
                ApplicationArea = All;
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
    }
}