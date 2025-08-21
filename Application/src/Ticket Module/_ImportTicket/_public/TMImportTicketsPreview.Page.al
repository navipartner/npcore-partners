page 6151354 "NPR TM ImportTicketsPreview"
{
    Extensible = true;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR TM ImportTicketHeader";
    SourceTableTemporary = true;
    Caption = 'Import Tickets Preview';
    Editable = false;
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(OrderId; Rec.OrderId)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Order ID field.';
                }
                field(SalesDate; Rec.SalesDate)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Date field.';
                }
                field(CurrencyCode; Rec.CurrencyCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                field(TotalAmountInclVat; Rec.TotalAmountInclVat)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Total Amount Incl. VAT field.';
                }
                field(TicketHolderEMail; Rec.TicketHolderEMail)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Holder Email Address field.';
                }
                field(TotalAmount; Rec.TotalAmount)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Total Amount field.';
                }
                field(TotalDiscountAmountInclVat; Rec.TotalDiscountAmountInclVat)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Total Discount Amount Incl. VAT field.';
                }
                field(TotalAmountLcyInclVat; Rec.TotalAmountLcyInclVat)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Total Amount Incl. VAT (LCY) field.';
                }
                field(PaymentReference; Rec.PaymentReference)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Payment Reference field.';
                }
                field(TicketHolderName; Rec.TicketHolderName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Holder Name field.';
                }
                field(TicketHolderPreferredLang; Rec.TicketHolderPreferredLang)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Holder Preferred Language field.';
                }
                field(TicketRequestToken; Rec.TicketRequestToken)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Request Token field.';
                }
                field(JobId; Rec.JobId)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Job ID field.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        Rec.FindSet();
    end;

    internal procedure LoadData(var TempTicketImport: Record "NPR TM ImportTicketHeader" temporary; var TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary)
    begin
        if (not Rec.IsTemporary) then
            Error('Page must use a temporary record. This is a programming bug and not a user error.');

        TempTicketImport.Reset();
        Rec.Copy(TempTicketImport, true);
        //_TempTicketImportLine.Copy(TempTicketImportLine, true);
    end;
}