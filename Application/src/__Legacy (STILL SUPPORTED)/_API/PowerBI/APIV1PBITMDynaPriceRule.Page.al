page 6150786 "NPR APIV1 PBITMDynaPriceRule"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'tmDynamicPriceRule';
    EntitySetName = 'tmDynamicPriceRule';
    Caption = 'PowerBI TM Dynamic Price Rule ';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR TM Dynamic Price Rule";
    Extensible = false;
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field(profileCode; Rec.ProfileCode)
                {
                    Caption = 'Profile Code';
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount';
                }
                field(amountIncludesVAT; Rec.AmountIncludesVAT)
                {
                    Caption = 'Amount Includes VAT';
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';
                }
                field(bookingDateFrom; Rec.BookingDateFrom)
                {
                    Caption = 'Booking Date From';
                }
                field(bookingDateUntil; Rec.BookingDateUntil)
                {
                    Caption = 'Booking Date Until';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(percentage; Rec.Percentage)
                {
                    Caption = 'Percentage';
                }
                field(pricingOption; Rec.PricingOption)
                {
                    Caption = 'Pricing Option';
                }
                field(vatPercentage; Rec.VatPercentage)
                {
                    Caption = 'VAT Percentage';
                }
                field(lineNo; Rec.LineNo)
                {
                    Caption = 'Line No.';
                }
                field(eventDateFrom; Rec.EventDateFrom)
                {
                    Caption = 'Event Date From';
                }
                field(eventDateUntil; Rec.EventDateUntil)
                {
                    Caption = 'Event Date Until';
                }
#if not (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'System Row Version', Locked = true;
                }
#endif
            }
        }
    }
}