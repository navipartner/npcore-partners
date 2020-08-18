pageextension 6014472 pageextension6014472 extends "Sales Return Order" 
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
            field("Sell-to Customer Name 2";"Sell-to Customer Name 2")
            {
            }
        }
        addafter("VAT Bus. Posting Group")
        {
            field("Magento Payment Amount";"Magento Payment Amount")
            {
            }
        }
        addafter("Shipment Date")
        {
            field("Document Processing";"Document Processing")
            {
            }
        }
        addafter("Ship-to Name")
        {
            field("Ship-to Name 2";"Ship-to Name 2")
            {
            }
        }
        addafter("Ship-to Contact")
        {
            field("Shipment Method Code";"Shipment Method Code")
            {
            }
        }
        addafter("Bill-to Name")
        {
            field("Bill-to Name 2";"Bill-to Name 2")
            {
            }
        }
    }
    actions
    {
        addafter("Post and &Print")
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
        addafter("Request Approval")
        {
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
        }
    }
}

