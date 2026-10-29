page 6150990 "NPR CMOrderData"
{
    Extensible = false;
    Caption = 'Channel Manager Order Data';
    PageType = List;
    SourceTable = "NPR CMOrder";
    SourceTableView = sorting(ReceivedAt) order(descending);
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(OrderId; Rec.OrderId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Order Id field.';
                }
                field(DocumentNo; Rec.DocumentNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Buy-from Order Reference field.';
                }
                field(PartnerId; Rec.PartnerId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Partner Id field.';
                }
                field(PartnerType; Rec.PartnerType)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Partner Type field.';
                }
                field(SellToOrderReference; Rec.SellToOrderReference)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sell-to Order Reference field.';
                }
                field(SellToCustomerNo; Rec.SellToCustomerNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sell-to Customer No. field.';
                }
                field(SellToName; Rec.SellToName)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sell-to Name field.';
                }
                field(SellToEmail; Rec.SellToEmail)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sell-to Email field.';
                }
                field(SellToLanguage; Rec.SellToLanguage)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sell-to Language field.';
                }
                field(PaymentOption; Rec.PaymentOption)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Payment Option field.';
                }
                field(PaymentReference; Rec.PaymentReference)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Payment Reference field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field(StatusMessage; Rec.StatusMessage)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Status Message field.';
                }
                field(ReceivedAt; Rec.ReceivedAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Received At field.';
                }
                field(JobId; Rec.JobId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Job Id field.';
                }
                field(ManifestId; Rec.ManifestId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Manifest Id field.';
                }
                field(ManifestUrl; Rec.ManifestUrl)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Manifest URL field.';
                }
            }
        }
    }
}
