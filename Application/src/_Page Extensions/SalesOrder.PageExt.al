pageextension 6014440 "NPR Sales Order" extends "Sales Order"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("NPR Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
            {

                ToolTip = 'Specifies the value of the Sell-to Customer Name 2 field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Ship-to Name")
        {
            field("NPR Ship-to Name 2"; Rec."Ship-to Name 2")
            {

                ToolTip = 'Specifies the value of the Ship-to Name 2 field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Bill-to Name")
        {
            field("NPR Bill-to Name 2"; Rec."Bill-to Name 2")
            {

                ToolTip = 'Specifies the value of the Bill-to Name 2 field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter(Control85)
        {
            field("NPR Bill-to Company"; Rec."NPR Bill-to Company")
            {

                ToolTip = 'Specifies the value of the NPR Bill-to Company field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Bill-To Vendor No."; Rec."NPR Bill-To Vendor No.")
            {

                ToolTip = 'Specifies the value of the NPR Bill-To Vendor No. field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Bill-to E-mail"; Rec."NPR Bill-to E-mail")
            {

                ToolTip = 'Specifies the value of the NPR Bill-to E-mail field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Shipping Advice")
        {
            field("NPR Delivery Location"; Rec."NPR Delivery Location")
            {

                ToolTip = 'Specifies the value of the NPR Delivery Location field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Delivery Instructions"; Rec."NPR Delivery Instructions")
            {

                ToolTip = 'Specifies the value of the NPR Delivery Instructions field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Outbound Whse. Handling Time")
        {
            field("NPR Kolli"; Rec."NPR Kolli")
            {

                ToolTip = 'Specifies the value of the NPR Kolli field';
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

                ToolTip = 'Executes the POS Entry action';
                ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Retail Vouchers action';
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

                ToolTip = 'Executes the Import From Scanner action';
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

                ToolTip = 'Executes the Select Recommended Item action';
                ApplicationArea = NPRRetail;
            }
            action("NPR InsertLineItem ")
            {
                Caption = 'Insert Line with Item';
                Image = CoupledOrderList;
                ShortCutKey = 'Ctrl+I';

                ToolTip = 'Executes the Insert Line with Item action';
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

                    ToolTip = 'Executes the Issue Voucher action';
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
                    ToolTip = 'Executes the Redeem Voucher action';

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

                ToolTip = 'Executes the Consignor Label action';
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

                ToolTip = 'Executes the Shipping Label action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    LabelLibrary: Codeunit "NPR Label Library";
                    RecRef: RecordRef;
                    SalesHeader: Record "Sales Header";
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

                    ToolTip = 'Executes the Send SMS action';
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

                    ToolTip = 'Executes the Variety action';
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
    }
}