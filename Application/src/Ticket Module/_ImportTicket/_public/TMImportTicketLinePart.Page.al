page 6151359 "NPR TM ImportTicketLinePart"
{
    Extensible = true;
    PageType = ListPart;
    Caption = 'Import Ticket Order Lines';
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    UsageCategory = Lists;
    SourceTable = "NPR TM ImportTicketLine";
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(TicketRequestTokenLine; Rec.TicketRequestTokenLine)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Request Token Line field.';
                }
                field(ItemReferenceNumber; Rec.ItemReferenceNumber)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Item Reference Number field.';
                }
                field(PreAssignedTicketNumber; Rec.PreAssignedTicketNumber)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Preassigned Ticket Number field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(ExpectedVisitDate; Rec.ExpectedVisitDate)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Expected Visit Date field.';
                }
                field(ExpectedVisitTime; Rec.ExpectedVisitTime)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Expected Visit Time field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field(AmountInclVat; Rec.AmountInclVat)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Amount Incl. VAT field.';
                }
                field(AmountLcyInclVat; Rec.AmountLcyInclVat)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Amount Incl. VAT (LCY) field.';
                }
                field(DiscountAmountInclVat; Rec.DiscountAmountInclVat)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Discount Amount Incl. VAT field.';
                }
                field(CurrencyCode; Rec.CurrencyCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                field(MemberNumber; Rec.MemberNumber)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Member Number field.';
                }
                field(MembershipNumber; Rec.MembershipNumber)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Membership Number field.';
                }
                field(TicketHolderEMail; Rec.TicketHolderEMail)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Holder Email Address field.';
                }
                field(TicketHolderName; Rec.TicketHolderName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Holder Name field.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }
            }
        }
    }

}