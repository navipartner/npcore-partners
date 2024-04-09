page 6184575 "NPR DocLXCityCardLocationList"
{
    Caption = 'DocLX City Card';
    Extensible = False;
    PageType = List;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    UsageCategory = Lists;
    SourceTable = "NPR DocLXCityCardLocation";
    CardPageID = "NPR DocLXCityCardLocation";
    DelayedInsert = true;


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Code field.';
                    ShowMandatory = true;
                }
                field(CityCode; Rec.CityCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the City Code field.';
                    ShowMandatory = true;
                }
                field(CityCardLocationId; Rec.CityCardLocationId)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the City Card Location Id field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(CouponSelection; Rec.CouponSelection)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Selection field.';
                }
                field(CouponType; Rec.CouponType)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Type field.';
                    ShowMandatory = true;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(ShowHistory)
            {
                Caption = 'Show History';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Shows the history for this location.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;
                Image = History;

                RunObject = page "NPR DocLXCityCardHistoryList";
                RunPageLink = CityCode = field(CityCode), LocationCode = field("Code");
            }
        }
    }

}