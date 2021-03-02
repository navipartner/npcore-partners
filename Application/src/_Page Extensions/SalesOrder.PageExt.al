pageextension 6014440 "NPR Sales Order" extends "Sales Order"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("NPR Sell-to Customer Name 2"; "Sell-to Customer Name 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Sell-to Customer Name 2 field';
            }
        }
        addafter("Ship-to Name")
        {
            field("NPR Ship-to Name 2"; "Ship-to Name 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Ship-to Name 2 field';
            }
        }
        addafter("Bill-to Name")
        {
            field("NPR Bill-to Name 2"; "Bill-to Name 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Bill-to Name 2 field';
            }
        }
        addafter(Control85)
        {
            field("NPR Bill-to Company"; "NPR Bill-to Company")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Bill-to Company field';
            }
            field("NPR Bill-To Vendor No."; "NPR Bill-To Vendor No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Bill-To Vendor No. field';
            }
            field("NPR Bill-to E-mail"; "NPR Bill-to E-mail")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Bill-to E-mail field';
            }
        }
        addafter("Shipping Advice")
        {
            field("NPR Delivery Location"; "NPR Delivery Location")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Delivery Location field';
            }
            field("NPR Delivery Instructions"; "NPR Delivery Instructions")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Delivery Instructions field';
            }
        }
        addafter("Outbound Whse. Handling Time")
        {
            field("NPR Kolli"; "NPR Kolli")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Kolli field';
            }
        }
        addafter("Attached Documents")
        {
            part("NPR NPAttributes"; "NPR NP Attributes FactBox")
            {
                Provider = SalesLines;
                SubPageLink = "No." = FIELD("No.");
                Visible = true;
                ApplicationArea = All;
            }
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
                        //-NPR5.55 [402013]
                        NpRvSalesDocMgt.ShowRelatedVouchersAction(Rec);
                        //+NPR5.55 [402013]
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
                        //-NPR5.55 [402014]
                        NpRvSalesDocMgt.IssueVoucherAction(Rec);
                        //+NPR5.55 [402014]
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
            }
            action("NPR PrintShippingLabel")
            {
                Caption = 'Shipping Label';
                Image = PrintCheck;
                ApplicationArea = All;
                ToolTip = 'Executes the Shipping Label action';
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
                        //-VRT1.00
                        CurrPage.SalesLines.PAGE.GetRecord(SalesLine);
                        VRTWrapper.SalesLineShowVariety(SalesLine, 0);
                        //+VRT1.00
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
        //-NPR5.55 [402015]
        if "No." = '' then
            exit;

        NpRvSaleLinePOSVoucher.SetRange("Document Type", "Document Type");
        NpRvSaleLinePOSVoucher.SetRange("Document No.", "No.");
        HasRetailVouchers := NpRvSaleLinePOSVoucher.FindFirst;
        //+NPR5.55 [402015]
    end;
}

