page 6184581 "NPR DocLXCityCardItemListPart"
{
    Caption = ' DocLX City Card Item List';
    Extensible = False;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR DocLXCityCardItem";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(CityCode; Rec.CityCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the City Code field.';
                    ShowMandatory = true;
                }
                field(LocationCode; Rec.LocationCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Code field.';
                    ShowMandatory = true;
                }
                field(ArticleId; Rec.ArticleId)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Article ID field.';
                    ShowMandatory = true;
                }
                field(ArticleName; Rec.ArticleName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Article Name field.';
                }
                field(CouponType; Rec.CouponType)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Type field.';
                    ShowMandatory = true;
                }
                field(CategoryName; Rec.CategoryName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Category Name field.';
                }
                field(ShopKey; Rec.ShopKey)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Shop Key field.';
                }
                field(ValidTimeSpan; Rec.ValidTimeSpan)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Valid Time Span field.';
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowHistory)
            {
                Caption = 'Show History';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Shows the history for this location and article.';
                Scope = Repeater;
                Image = History;

                RunObject = page "NPR DocLXCityCardHistoryList";
                RunPageLink = CityCode = field(CityCode), LocationCode = field(LocationCode), ArticleId = field(ArticleId);
            }
        }
    }
}