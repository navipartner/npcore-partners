pageextension 6014440 "NPR Sales Order" extends "Sales Order"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("NPR Sell-to Customer Name 2"; "Sell-to Customer Name 2")
            {
                ApplicationArea = All;
            }
        }
        addafter("Payment Method Code")
        {
            field("NPR Magento Payment Amount"; "NPR Magento Payment Amount")
            {
                ApplicationArea = All;
            }
            field("NPR VAT Registration No."; "VAT Registration No.")
            {
                ApplicationArea = All;
            }
        }
        addafter("Ship-to Name")
        {
            field("NPR Ship-to Name 2"; "Ship-to Name 2")
            {
                ApplicationArea = All;
            }
        }
        addafter("Bill-to Name")
        {
            field("NPR Bill-to Name 2"; "Bill-to Name 2")
            {
                ApplicationArea = All;
            }
        }
        addafter(Control85)
        {
            field("NPR Bill-to Company"; "NPR Bill-to Company")
            {
                ApplicationArea = All;
            }
            field("NPR Bill-To Vendor No."; "NPR Bill-To Vendor No.")
            {
                ApplicationArea = All;
            }
            field("NPR Bill-to E-mail"; "NPR Bill-to E-mail")
            {
                ApplicationArea = All;
            }
            field("NPR Document Processing"; "NPR Document Processing")
            {
                ApplicationArea = All;
            }
        }
        addafter("Shipping Advice")
        {
            field("NPR Delivery Location"; "NPR Delivery Location")
            {
                ApplicationArea = All;
            }
            field("NPR Delivery Instructions"; "NPR Delivery Instructions")
            {
                ApplicationArea = All;
            }
        }
        addafter("Outbound Whse. Handling Time")
        {
            field("NPR Kolli"; "NPR Kolli")
            {
                ApplicationArea = All;
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
        addafter(WorkflowStatus)
        {
            part("NPR MCS Recom. Sales Factbox"; "NPR MCS Recom. Sales Factbox")
            {
                Caption = 'Recommendations';
                Provider = SalesLines;
                SubPageLink = "Document No." = FIELD("Document No."),
                              "Document Line No." = FIELD("Line No.");
                SubPageView = SORTING("Table No.", "Document Type", "Document No.", "Document Line No.", Rating)
                              ORDER(Ascending)
                              WHERE("Table No." = CONST(37),
                                    "Document Type" = CONST(1));
                UpdatePropagation = Both;
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
            }
            action("NPR RFID Document")
            {
                Caption = 'RFID Document';
                Image = Delivery;
                Visible = ShowCaptureService;
                ApplicationArea = All;

                trigger OnAction()
                var
                    CSRfidHeader: Record "NPR CS Rfid Header";
                begin
                    CSRfidHeader.OpenRfidSalesDoc(0, "No.", "Sell-to Customer No.", '');
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
                    ApplicationArea = All;

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
                ApplicationArea = All;
            }
        }
        addafter("Send IC Sales Order")
        {
            action("NPR SelectRecommendedItem")
            {
                Caption = 'Select Recommended Item';
                Image = SuggestLines;
                ApplicationArea = All;
            }
            action("NPR InsertLineItem ")
            {
                Caption = 'Insert Line with Item';
                Image = CoupledOrderList;
                ShortCutKey = 'Ctrl+I';
                ApplicationArea = All;
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
            }
            action("NPR PrintShippingLabel")
            {
                Caption = 'Shipping Label';
                Image = PrintCheck;
                ApplicationArea = All;
            }
            group("NPR PDF2NAV")
            {
                Caption = 'PDF2NAV';
                action("NPR EmailLog")
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                    ApplicationArea = All;
                }
                action("NPR SendAsPDF")
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                    ApplicationArea = All;
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
        ShowCaptureService: Boolean;
        CSHelperFunctions: Codeunit "NPR CS Helper Functions";


    trigger OnAfterGetCurrRecord()
    begin
        SetHasRetailVouchers();
    end;


    trigger OnOpenPage()
    begin
        ShowCaptureService := CSHelperFunctions.CaptureServiceStatus();
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

