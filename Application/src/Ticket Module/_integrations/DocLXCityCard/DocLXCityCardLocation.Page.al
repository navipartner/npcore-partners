page 6184580 "NPR DocLXCityCardLocation"
{
    Caption = 'DocLX City Card';
    Extensible = False;
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR DocLXCityCardLocation";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'City Card Location';

                field(CityCode; Rec.CityCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the City Code field.';
                    ShowMandatory = true;
                }
                field("Code"; Rec."Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Code field.';
                    ShowMandatory = true;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(CityCardLocationId; Rec.CityCardLocationId)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the City Card Location Id field.';
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
            part(Items; "NPR DocLXCityCardItemListPart")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Items';
                SubPageLink = CityCode = field(CityCode), LocationCode = field("Code");
            }
        }

    }

    actions
    {
        area(Processing)
        {
            action(SetupCities)
            {
                Caption = 'Setup Cities';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Shows the list of cities.';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Setup;

                RunObject = page "NPR DocLXCityCardSetupList";
            }

            action(ImportArticles)
            {
                Caption = 'Import City Card Articles';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Imports City Card Articles for this location from the their web site.';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Import;

                trigger OnAction()
                var
                    CityCard: Codeunit "NPR DocLXCityCard";
                begin
                    CityCard.AppendArticlesFromCityCard(Rec.CityCode, Rec."Code")
                end;
            }

            action(ShowHistory)
            {
                Caption = 'Show History';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Shows the history for this location.';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = History;

                RunObject = page "NPR DocLXCityCardHistoryList";
                RunPageLink = CityCode = field(CityCode), LocationCode = field("Code");
            }

            action(CheckHealth)
            {
                Caption = 'Check Service';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Checks the health of the City Card Service.';
                Image = Confirm;
                trigger OnAction()
                var
                    CityCard: Codeunit "NPR DocLXCityCard";
                    StateCode: Code[10];
                    StateMessage: Text;
                begin
                    CityCard.CheckServiceHealth(Rec.CityCode, StateCode, StateMessage);
                    Message('Service returned code: %1 - %2', StateCode, StateMessage)
                end;
            }


        }
    }
}