page 6059866 "NPR TM Dynamic Price Rules"
{
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR TM Dynamic Price Rule";
    DelayedInsert = true;
    Extensible = False;
    RefreshOnActivate = true;
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/explanation/pricing/';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(ProfileCode; Rec.ProfileCode)
                {
                    ToolTip = 'Specifies the value of the Profile Code field.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    Visible = false;
                }
                field(LineNo; Rec.LineNo)
                {
                    ToolTip = 'Specifies the value of the Line No. field. Used as bias when multiple rules has equal selectivity.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }

                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a short description of the intention of this rule.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field. Blocked rules are ignored during rule selection.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field(BookingDateFrom; Rec.BookingDateFrom)
                {
                    ToolTip = 'Specifies the value of the Booking Date From field. It is the lowest booking date this rule can be valid from. For an unbound lower date limit it can be empty.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field(BookingDateUntil; Rec.BookingDateUntil)
                {
                    ToolTip = 'Specifies the value of the Booking Date Until field. It is the highest booking date this rule can be valid for. For an unbound upper date limit it can be empty.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field(RelativeBookingDateFormula; Rec.RelativeBookingDateFormula)
                {
                    ToolTip = 'Specifies the value of the Relative Booking Date Formula field. With this date formula, relative characteristics of the booking date can be specified, such as weekday, week number or similar.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }

                field(EventDateFrom; Rec.EventDateFrom)
                {
                    ToolTip = 'Specifies the value of the Event Date From field. It is the lowest event date this rule can apply to. May be left empty for an unbound lower date limit.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field(EventDateUntil; Rec.EventDateUntil)
                {
                    ToolTip = 'Specifies the value of the Event Date Until field. It is the highest event date this rule can apply to. May be left empty for an unbound upper date limit.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field(RelativeEventDateFormula; Rec.RelativeEventDateFormula)
                {
                    ToolTip = 'Specifies the value of the Relative Event Date Formula field. With this date formula, relative characteristics of the event date can be specified, such as weekday, week number or similar.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }

                field(RelativeUntilEventDate; Rec.RelativeUntilEventDate)
                {
                    ToolTip = 'Specifies the value of the Relative Until Event Date field. This date formula specifies how many days apart booking date and event date must be, to make the rule valid.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }

                field(PricingOption; Rec.PricingOption)
                {
                    ToolTip = 'Specifies the value of the Pricing Option field. A list of options to determine how to alter the ERP price. Fixed Amount: Replace original amount with value in Amount field. Relative Amount: Add amount from Amount field. Percentage: Add a percentage of original amount.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field(Percentage; Rec.Percentage)
                {
                    ToolTip = 'Specifies the percentage added when Price Option is "Percentage". The percentage to apply to original amount.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field. The amount to change or replace the original amount with.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field(AmountIncludesVAT; Rec.AmountIncludesVAT)
                {
                    ToolTip = 'Specifies the value of the Amount Includes VAT field. The original amount may or may not include VAT and it is required to compensate when the settings do not match.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field(VatPercentage; Rec.VatPercentage)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the VAT Percentage field.';
                }
                field(RoundingPrecision; Rec.RoundingPrecision)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Rounding Precision field.';
                }
                field(RoundingDirection; Rec.RoundingDirection)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Rounding Direction field.';
                }
            }
        }
    }
}