page 6184878 "NPR SG SpeedGateDefault"
{
    Extensible = false;

    PageType = Card;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR SG SpeedGateDefault";
    DeleteAllowed = false;
    Caption = 'Speedgate Setup';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'Defaults';
                field(RequireScannerId; Rec.RequireScannerId)
                {
                    ToolTip = 'Specifies the value of the Require Scanner Id field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(ImageProfileCode; Rec.ImageProfileCode)
                {
                    ToolTip = 'Specifies the value of the Image Profile Code field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }

                field(NumberWhiteList; Rec.AllowedNumbersList)
                {
                    ToolTip = 'Specifies the value of the Number White List field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(ItemsProfileCode; Rec.ItemsProfileCode)
                {
                    ToolTip = 'Specifies the value of the Additional Items Profile Code field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }

                Group(Tickets)
                {
                    field(AllowAdmitTickets; Rec.PermitTickets)
                    {
                        ToolTip = 'Specifies the value of the Allow Tickets field.', Comment = '%';
                        ApplicationArea = NPRRetail;
                    }
                    field(DefaultTicketProfileCode; Rec.DefaultTicketProfileCode)
                    {
                        ToolTip = 'Specifies the value of the Default Ticket Profile field.', Comment = '%';
                        ApplicationArea = NPRRetail;
                    }
                }

                Group(MemberCards)
                {
                    field(AllowAdmitMemberCards; Rec.PermitMemberCards)
                    {
                        ToolTip = 'Specifies the value of the Allow Member Cards field.', Comment = '%';
                        ApplicationArea = NPRRetail;
                    }
                    field(DefaultMembershipProfileCode; Rec.DefaultMemberCardProfileCode)
                    {
                        ToolTip = 'Specifies the value of the Default Member Card Profile field.', Comment = '%';
                        ApplicationArea = NPRRetail;
                    }
                }

                Group(Wallets)
                {
                    field(AllowAdmitWallets; Rec.PermitWallets)
                    {
                        ToolTip = 'Specifies the value of the Allow Wallets field.', Comment = '%';
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            part(SpeedGates; "NPR SG SpeedGateListPart")
            {
                Caption = 'Scanner Id';
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(AllowedNumbers)
            {
                Caption = 'Allowed Numbers';
                Tooltip = 'This action navigates to the Allowed Numbers setup';
                ApplicationArea = NPRRetail;
                Image = NumberGroup;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "NPR SG AllowedNumbersLists";
            }
            action(ImageProfiles)
            {
                Caption = 'Image Profiles';
                Tooltip = 'This action navigates to the Image Profile Lists setup';
                ApplicationArea = NPRRetail;
                Image = Picture;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "NPR SG ImageProfileList";
            }

            action(TicketProfiles)
            {
                Caption = 'Ticket Profiles';
                Tooltip = 'This action navigates to the Ticket Profiles setup';
                ApplicationArea = NPRRetail;
                Image = ResourceGroup;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "NPR SG TicketProfiles";
            }
            action(MemberCardProfiles)
            {
                Caption = 'Member Card Profiles';
                Tooltip = 'This action navigates to the Member Card Profiles setup';
                ApplicationArea = NPRRetail;
                Image = Card;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "NPR SG MemberCardProfiles";
            }

            action(CityCardLocations)
            {
                Caption = 'City Card Locations';
                Tooltip = 'This action navigates to the City Card Locations';
                ApplicationArea = NPRRetail;
                Image = List;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "NPR DocLXCityCardLocationList";
            }

            action(ItemProfiles)
            {
                Caption = 'Item Profiles';
                Tooltip = 'This action navigates to the Item Profiles setup';
                ApplicationArea = NPRRetail;
                Image = List;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "NPR SG ItemsProfiles";
            }
        }
    }


    trigger OnInit()
    var
        Setup: Record "NPR SG SpeedGateDefault";
    begin
        if (not Setup.Get('')) then
            Setup.Insert();
    end;
}