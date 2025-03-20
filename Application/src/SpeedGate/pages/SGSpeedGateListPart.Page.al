page 6184879 "NPR SG SpeedGateListPart"
{
    Extensible = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR SG SpeedGate";
    Caption = 'Speedgate List Part';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(ScannerId; Rec.ScannerId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                    NotBlank = true;
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enabled field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field(ImageProfileCode; Rec.ImageProfileCode)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Image Profile Code field.', Comment = '%';
                }

                field(NumberWhiteList; Rec.AllowedNumbersList)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Number White List field.', Comment = '%';
                }

                field(AllowAdmitTickets; Rec.PermitTickets)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Allow Tickets field.', Comment = '%';
                }
                field(TicketProfileCode; Rec.TicketProfileCode)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Default Ticket Profile field.', Comment = '%';
                }

                field(AllowAdmitMemberCards; Rec.PermitMemberCards)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Allow Member Cards field.', Comment = '%';
                }
                field(MembershipProfile; Rec.MemberCardProfileCode)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Default Member Card Profile field.', Comment = '%';
                }
                field(AllowAdmitWallets; Rec.PermitWallets)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Allow Wallets field.', Comment = '%';
                }
                field(EnabledDocLxCityCard; Rec.PermitDocLxCityCard)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enabled DocLx City Card field.', Comment = '%';

                    trigger OnValidate()
                    begin
                        if (not xRec.PermitDocLxCityCard and Rec.PermitDocLxCityCard) then
                            SelectCityCardProfile();

                        if (xRec.PermitDocLxCityCard and not Rec.PermitDocLxCityCard) then
                            ClearCityCardProfile();
                    end;
                }
                field(_DocLxCityCardProfileName; _DocLxCityCardProfileName)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the DocLx City Card Profile field.', Comment = '%';
                    Caption = 'City Card Profile';
                    Editable = false;
                }
                field(ItemsProfileCode; Rec.ItemsProfileCode)
                {
                    ToolTip = 'Specifies the value of the Additional Items Profile Code field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(EntryLog)
            {
                Caption = 'Entry Log';
                Tooltip = 'This action navigates to the Entry Log for the gate';
                ApplicationArea = NPRRetail;
                Image = Log;
                Scope = Repeater;
                RunObject = page "NPR SG EntryLogList";
                RunPageLink = ScannerId = field(ScannerId);
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        RefreshCityCardProfileName();
    end;

    local procedure SelectCityCardProfile()
    var
        CityCardLookupPage: Page "NPR DocLXCityCardLocationList";
        CityCardProfile: Record "NPR DocLXCityCardLocation";
    begin
        CityCardLookupPage.LookupMode(true);
        if (CityCardLookupPage.RunModal() <> Action::LookupOK) then begin
            Rec.PermitDocLxCityCard := not IsNullGuid(Rec.DocLxCityCardProfileId);
            CurrPage.Update(true);
            exit;
        end;

        CityCardLookupPage.GetRecord(CityCardProfile);
        Rec.DocLxCityCardProfileId := CityCardProfile.SystemId;
        Rec.PermitDocLxCityCard := true;
        CurrPage.Update(true);

        RefreshCityCardProfileName();
    end;


    local procedure RefreshCityCardProfileName()
    var
        CityCardProfile: Record "NPR DocLXCityCardLocation";
    begin
        _DocLxCityCardProfileName := '';
        if (IsNullGuid(Rec.DocLxCityCardProfileId)) then
            exit;

        if ((Rec.PermitDocLxCityCard) and (CityCardProfile.GetBySystemId(Rec.DocLxCityCardProfileId))) then begin
            _DocLxCityCardProfileName := CityCardProfile.Description;
            if (_DocLxCityCardProfileName = '') then
                _DocLxCityCardProfileName := StrSubstNo('CityCard: %1 / %2', CityCardProfile.CityCode, CityCardProfile.Code);
        end;

        if ((Rec.PermitDocLxCityCard) and (not CityCardProfile.GetBySystemId(Rec.DocLxCityCardProfileId))) then
            ClearCityCardProfile();
    end;

    local procedure ClearCityCardProfile()
    begin
        Clear(Rec.DocLxCityCardProfileId);
        Rec.PermitDocLxCityCard := false;
        CurrPage.Update(true);
    end;

    var
        _DocLxCityCardProfileName: Text;
}