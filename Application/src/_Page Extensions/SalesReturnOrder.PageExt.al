pageextension 6014472 "NPR Sales Return Order" extends "Sales Return Order"
{
    // NPR4.10/TS/20150602 CASE 213397 Added field "Sell-to Customer Name 2" ,"Bill-to Name 2","Ship-to Name 2"
    // NPR5.36/THRO/20170908 CASE 285645 Added action PostAndSendPdf2Nav
    // NPR5.38/TS  /20171120  CASE 296907 Added Action PDF2NAV
    //                                    Added field Document Processing.
    // MAG2.12/MHA /20180425  CASE 309647 Added fields 6151400 "Magento Payment Amount" under Invoicing Tab
    // NPR5.42/THRO/20180518 CASE 308179 Removed code from Action SendAsPdf and EmailLog
    // NPR5.51/ZESO/20190618 CASE 353560 Added fields Shipment Method Code and Shipping Agent Code.
    // NPR5.51/JAVA/20190906 CASE 353560 Removed fields Shipping Agent Code as 2017 includes the same by default.
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
        addafter("VAT Bus. Posting Group")
        {
            field("NPR Magento Payment Amount"; "NPR Magento Payment Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Magento Payment Amount field';
            }
        }
        addafter("Shipment Date")
        {
            field("NPR Document Processing"; "NPR Document Processing")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Document Processing field';
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
        addafter("Ship-to Contact")
        {
            field("NPR Shipment Method Code"; "Shipment Method Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Shipment Method Code field';
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
    }
    actions
    {
        addafter("Post and &Print")
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
        addafter("Request Approval")
        {
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
        }
    }
}

