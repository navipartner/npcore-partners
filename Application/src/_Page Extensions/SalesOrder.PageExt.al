pageextension 6014440 "NPR Sales Order" extends "Sales Order"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("NPR Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Sell-to Customer Name 2 field';
            }
        }
        addafter("Ship-to Name")
        {
            field("NPR Ship-to Name 2"; Rec."Ship-to Name 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Ship-to Name 2 field';
            }
        }
        addafter("Bill-to Name")
        {
            field("NPR Bill-to Name 2"; Rec."Bill-to Name 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Bill-to Name 2 field';
            }
        }
        addafter(Control85)
        {
            field("NPR Bill-to Company"; Rec."NPR Bill-to Company")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Bill-to Company field';
            }
            field("NPR Bill-To Vendor No."; Rec."NPR Bill-To Vendor No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Bill-To Vendor No. field';
            }
            field("NPR Bill-to E-mail"; Rec."NPR Bill-to E-mail")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Bill-to E-mail field';
            }
        }
        addafter("Shipping Advice")
        {
            field("NPR Delivery Location"; Rec."NPR Delivery Location")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Delivery Location field';
            }
            field("NPR Delivery Instructions"; Rec."NPR Delivery Instructions")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Delivery Instructions field';
            }
        }
        addafter("Outbound Whse. Handling Time")
        {
            field("NPR Kolli"; Rec."NPR Kolli")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Kolli field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the POS Entry action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail Vouchers action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Import From Scanner action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Select Recommended Item action';
            }
            action("NPR InsertLineItem ")
            {
                Caption = 'Insert Line with Item';
                Image = CoupledOrderList;
                ShortCutKey = 'Ctrl+I';
                ApplicationArea = All;
                ToolTip = 'Executes the Insert Line with Item action';

                trigger OnAction()
                var
                    Item: Record Item;
                    SalesLine: Record "Sales Line";
                    LastSalesLine: Record "Sales Line";
                    RetailItemList: Page "Item List";
                    InputDialog: Page "NPR Input Dialog";
                    ReturntoSO: Boolean;
                    ViewText: Text;
                    InputQuantity: Decimal;
                begin
                    Rec.TestField(Status, Rec.Status::Open);
                    Rec.TestField("Sell-to Customer No.");
                    RetailItemList.NPR_SetLocationCode(Rec."Location Code");
                    RetailItemList.NPR_SetBlocked(2);
                    RetailItemList.LookupMode := true;
                    while RetailItemList.RunModal = ACTION::LookupOK do begin
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
                        ViewText := RetailItemList.NPR_GetViewText;
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Issue Voucher action';

                    trigger OnAction()
                    var
                        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
                    begin
                        NpRvSalesDocMgt.IssueVoucherAction(Rec);
                    end;
                }
            }
        }
        addafter(PostAndSend)
        {
            action("NPR PostAndSendPdf2Nav")
            {
                Caption = 'Post and Pdf2Nav';
                Image = PostSendTo;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Post and handle as set up in ''Document Processing''';
                ApplicationArea = All;
            }
        }
        addafter("Pick Instruction")
        {
            action("NPR Consignor Label")
            {
                Caption = 'Consignor Label';
                ApplicationArea = All;
                ToolTip = 'Executes the Consignor Label action';
                Image = Print;

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
                ApplicationArea = All;
                ToolTip = 'Executes the Shipping Label action';

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
            group("NPR PDF2NAV")
            {
                Caption = 'PDF2NAV';
                action("NPR EmailLog")
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                    ApplicationArea = All;
                    ToolTip = 'Executes the E-mail Log action';
                }
                action("NPR SendAsPDF")
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send as PDF action';
                }
            }
            group("NPR SMS")
            {
                Caption = 'SMS';
                action("NPR SendSMS")
                {
                    Caption = 'Send SMS';
                    Image = SendConfirmation;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send SMS action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Variety action';
                    Image = Edit;

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

    var
        HasRetailVouchers: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        SetHasRetailVouchers();
    end;

    local procedure SetHasRetailVouchers()
    var
        NpRvSaleLinePOSVoucher: Record "NPR NpRv Sales Line";
    begin
        if Rec."No." = '' then
            exit;

        NpRvSaleLinePOSVoucher.SetRange("Document Type", Rec."Document Type");
        NpRvSaleLinePOSVoucher.SetRange("Document No.", Rec."No.");
        HasRetailVouchers := not NpRvSaleLinePOSVoucher.IsEmpty();
    end;
}