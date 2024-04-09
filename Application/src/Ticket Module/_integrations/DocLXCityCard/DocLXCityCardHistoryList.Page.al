page 6184576 "NPR DocLXCityCardHistoryList"
{
    Caption = 'DocLX Card History List';
    Extensible = False;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR DocLXCityCardHistory";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(EntryNo; Rec.EntryNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field(CardNumber; Rec.CardNumber)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Card Number field.';
                }
                field(CityCode; Rec.CityCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the City Code field.';
                }
                field(LocationCode; Rec.LocationCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Location Code field.';
                }
                field(POSUnitNo; Rec.POSUnitNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the POS Unit No. field.';
                }
                field(SalesTicketNo; Rec.SalesDocumentNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field.';
                }
                field(ValidationResultCode; Rec.ValidationResultCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Validation Result Code field.';
                }
                field(ValidationResultMessage; Rec.ValidationResultMessage)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Validation Result Message field.';
                }
                field(ValidatedAtDateTime; Rec.ValidatedAtDateTime)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Validated At Date Time field.';
                }
                field(ValidatedAtDateTimeUtc; Rec.ValidatedAtDateTimeUtc)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Validated At Date Time (UTC) field.';
                }
                field(RedeemedAtDateTime; Rec.RedeemedAtDateTime)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Redeemed At Date Time field.';
                }
                field(RedemptionResultCode; Rec.RedemptionResultCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Redemption Result Code field.';
                }
                field(RedemptionResultMessage; Rec.RedemptionResultMessage)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Redemption Result Message field.';
                }
                field(CouponResultCode; Rec.CouponResultCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Result Code field.';
                }
                field(CouponResultMessage; Rec.CouponResultMessage)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Result Message field.';
                }

                field(CouponType; Rec.CouponType)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Type field.';
                }
                field(CouponNo; Rec.CouponNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon No. field.';
                }
                field(CouponReferenceNo; Rec.CouponReferenceNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Reference No. field.';
                }

                field(ArticleId; Rec.ArticleId)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Article ID field.';
                }
                field(ArticleName; Rec.ArticleName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Article Name field.';
                }
                field(CategoryName; Rec.CategoryName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Category Name field.';
                }
                field(ActivationDate; Rec.ActivationDate)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Activation Date field.';
                }
                field(ValidUntilDate; Rec.ValidUntilDate)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Valid Until Date field.';
                }
                field(ValidTimeSpan; Rec.ValidTimeSpan)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Valid Time Span field.';
                }

                field(ShopKey; Rec.ShopKey)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Shop Key field.';
                }
            }
        }
    }
}