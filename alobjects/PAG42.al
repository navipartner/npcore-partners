pageextension 6014435 pageextension6014435 extends "Sales Order" 
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //                     - Added Action Items: EmailLog and SendAsPDF
    //                     - Added Field 6014414 "Bill-to E-mail" for defining Recipient when sending E-mail using PDF2NAV (Billing-page)
    //                     - Added Field 6014415 "Document Processing" for defining Print action on Sales Doc. Posting (Billing-page)
    // PS1.01/LS/20141216   CASE 200974 : Added field Delivery Location to shipping tab
    // MAG1.03/MH/20150205  CASE 199932 Added NaviConnect Payment Amount
    // VRT1.00/JDH/20150304 CASE 201022 Added call to Variety Matrix
    // NPR4.10/TS/20150602  CASE 213397 Added field "Sell-to Customer Name 2" ,"Bill-to Name 2","Ship-to Name 2"
    // NPR4.14/BHR/20150811 CASE 220381 Change the property Importance of field "Sell-to Contact" to standard
    // NPR4.15/TS/20151013  CASE 224751 Added NpAttribute Factbox
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // PN1.10/MHA/20160314 CASE 236653 Updated Record Specific Pdf2Nav functions with general Variant functions
    // NPR5.23/RA/20160329  CASE 237639 Added Action Action6150629
    // NPR5.23/JDH /20160513 CASE 240916 Deleted old VariaX Matrix Action
    // NPR5.23/JLK /20160706 CASE 242052 Added Your Reference field
    // NPR5.23/TS/20160609 CASE 243598 Added Action Import from Scanner
    // NPR5.25/MMV /20160621 CASE 233533 Added action PrintShippingLabel
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // NPR5.29/BHR/20160929 CASE 248684 Displayed field Kolli(number of packages)
    // NPR5.29/TJ /20171301 CASE 262797 Removed local variable from action Consignor Label
    //                                  Restored standard values for property TooltipML on some actions
    //                                  Moved code from action Shipping Label to a subscriber function
    // NPR5.30/THRO/20170203 CASE 263182 Added action SendSMS
    // NPR5.30/BR  /20170215 CASE 252646 Added action SelectRecommendedItem
    // NPR5.30/BR  /20170906 CASE 252646 Added Factbox for recommended items
    // NPR5.32/BR  /20170523 CASE 252646 Moved code for action SelectRecommendedItem to subscriber Codeunit MCS Rec. Subscribers
    // NPR5.33/BR  /20170531 CASE 252646 Removed documentation code and local variable in Action SelectRecommendedItem
    // NPR5.36/THRO/201700908 CASE 285645 Added action PostAndSendPdf2Nav
    // NPR5.36/BHR/20170919  CASE 290780 Fiels Delivery Instructions for Pakkelabels
    // NPR5.38/BR  /20171117 CASE 295255 Added Action POS Entries
    // NPR5.38/BR  /20171201 CASE 298368 Added Action Insert Line with Item shortcut key Ctrl+I to Insert Line with Vendor Item action
    // NPR5.38/TJ  /20180117 CASE 302612 Field VAT Registration No. added to Invoicing tab
    // NPR5.42/THRO/20180516 CASE 308179 Removed code from Action SendAsPdf and EmailLog
    // NPR5.49/MHA /20190228 CASE 344166 Added Retail Vouchers action
    // NPR5.50/JAVA/20190607 CASE 359371 Remove "Your Reference" control (our control) as MS added in BC13 this field.
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("Sell-to Customer Name 2";"Sell-to Customer Name 2")
            {
            }
        }
        addafter("Payment Method Code")
        {
            field("Magento Payment Amount";"Magento Payment Amount")
            {
            }
            field("VAT Registration No.";"VAT Registration No.")
            {
            }
        }
        addafter("Ship-to Name")
        {
            field("Ship-to Name 2";"Ship-to Name 2")
            {
            }
        }
        addafter("Bill-to Name")
        {
            field("Bill-to Name 2";"Bill-to Name 2")
            {
            }
        }
        addafter(Control85)
        {
            field("Bill-to Company";"Bill-to Company")
            {
            }
            field("Bill-To Vendor No.";"Bill-To Vendor No.")
            {
            }
            field("Bill-to E-mail";"Bill-to E-mail")
            {
            }
            field("Document Processing";"Document Processing")
            {
            }
        }
        addafter("Shipping Advice")
        {
            field("Delivery Location";"Delivery Location")
            {
            }
            field("Delivery Instructions";"Delivery Instructions")
            {
            }
        }
        addafter("Outbound Whse. Handling Time")
        {
            field(Kolli;Kolli)
            {
            }
        }
        addafter("Attached Documents")
        {
            part(Control6150628;"NP Attributes FactBox")
            {
                Provider = SalesLines;
                SubPageLink = "No."=FIELD("No.");
                Visible = true;
            }
        }
        addafter(WorkflowStatus)
        {
            part("MCS Recom. Sales Factbox";"MCS Recom. Sales Factbox")
            {
                Caption = 'Recommendations';
                Provider = SalesLines;
                SubPageLink = "Document No."=FIELD("Document No."),
                              "Document Line No."=FIELD("Line No.");
                SubPageView = SORTING("Table No.","Document Type","Document No.","Document Line No.",Rating)
                              ORDER(Ascending)
                              WHERE("Table No."=CONST(37),
                                    "Document Type"=CONST(1));
                UpdatePropagation = Both;
            }
        }
    }
    actions
    {
        addafter(DocAttach)
        {
            action("POS Entry")
            {
                Caption = 'POS Entry';
                Image = Entry;
            }
        }
        addafter(History)
        {
            group(Retail)
            {
                Caption = 'Retail';
                action("Retail Vouchers")
                {
                    Caption = 'Retail Vouchers';
                    Image = Certificate;

                    trigger OnAction()
                    var
                        NpRvExtVoucherSalesLine: Record "NpRv Ext. Voucher Sales Line";
                        NpRvVoucher: Record "NpRv Voucher";
                        TempNpRvVoucher: Record "NpRv Voucher" temporary;
                    begin
                        //-NPR5.49 [344166]
                        NpRvExtVoucherSalesLine.SetRange("Document Type","Document Type");
                        NpRvExtVoucherSalesLine.SetRange("Document No.","No.");
                        if NpRvExtVoucherSalesLine.FindSet then
                          repeat
                            if NpRvVoucher.Get(NpRvExtVoucherSalesLine."Voucher No.") and (not TempNpRvVoucher.Get(NpRvVoucher."No.")) then begin
                              TempNpRvVoucher.Init;
                              TempNpRvVoucher := NpRvVoucher;
                              TempNpRvVoucher.Insert;
                            end;
                          until NpRvExtVoucherSalesLine.Next = 0;

                        PAGE.Run(0,TempNpRvVoucher);
                        //+NPR5.49 [344166]
                    end;
                }
            }
        }
        addfirst("F&unctions")
        {
            action("Import From Scanner")
            {
                Caption = 'Import From Scanner';
                Image = Import;
                Promoted = true;
            }
        }
        addafter("Send IC Sales Order")
        {
            action(SelectRecommendedItem)
            {
                Caption = 'Select Recommended Item';
                Image = SuggestLines;
            }
            action("InsertLineItem ")
            {
                Caption = 'Insert Line with Item';
                Image = CoupledOrderList;
                ShortCutKey = 'Ctrl+I';
            }
        }
        addafter(PostAndSend)
        {
            action(PostAndSendPdf2Nav)
            {
                Caption = 'Post and Pdf2Nav';
                Image = PostSendTo;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Post and handle as set up in ''Document Processing''';
            }
        }
        addafter("Pick Instruction")
        {
            action("Consignor Label")
            {
                Caption = 'Consignor Label';
            }
            action(PrintShippingLabel)
            {
                Caption = 'Shipping Label';
                Image = PrintCheck;
            }
            group(PDF2NAV)
            {
                Caption = 'PDF2NAV';
                action(EmailLog)
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                }
                action(SendAsPDF)
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                }
            }
            group(SMS)
            {
                Caption = 'SMS';
                action(SendSMS)
                {
                    Caption = 'Send SMS';
                    Image = SendConfirmation;
                }
            }
            group(Variants)
            {
                Caption = 'Variants';
                action(Variety)
                {
                    Caption = 'Variety';
                    ShortCutKey = 'Ctrl+Alt+V';

                    trigger OnAction()
                    var
                        SalesLine: Record "Sales Line";
                        VRTWrapper: Codeunit "Variety Wrapper";
                    begin
                        //-VRT1.00
                        CurrPage.SalesLines.PAGE.GetRecord(SalesLine);
                        VRTWrapper.SalesLineShowVariety(SalesLine,0);
                        //+VRT1.00
                    end;
                }
            }
        }
    }

    var
        HasRetailVouchers: Boolean;


    //Unsupported feature: Code Modification on "OnAfterGetCurrRecord".

    //trigger OnAfterGetCurrRecord()
    //>>>> ORIGINAL CODE:
    //begin
        /*
        DynamicEditable := CurrPage.Editable;
        CurrPage.IncomingDocAttachFactBox.PAGE.LoadDataFromRecord(Rec);
        CurrPage.ApprovalFactBox.PAGE.UpdateApprovalEntriesFromSourceRecord(RecordId);
        #4..12
          CheckItemAvailabilityInLines;
          CallNotificationCheck := false;
        end;
        */
    //end;
    //>>>> MODIFIED CODE:
    //begin
        /*
        #1..15

        //-NPR5.49 [344166]
        SetHasRetailVouchers();
        //+NPR5.49 [344166]
        */
    //end;

    local procedure SetHasRetailVouchers()
    var
        NpRvExtVoucherSalesLine: Record "NpRv Ext. Voucher Sales Line";
    begin
        //-NPR5.49 [344166]
        NpRvExtVoucherSalesLine.SetRange("Document Type","Document Type");
        NpRvExtVoucherSalesLine.SetRange("Document No.","No.");
        HasRetailVouchers := NpRvExtVoucherSalesLine.FindFirst;
        //+NPR5.49 [344166]
    end;
}

