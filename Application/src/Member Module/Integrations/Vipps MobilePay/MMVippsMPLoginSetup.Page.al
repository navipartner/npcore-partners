page 6184873 "NPR MM VippsMP Login Setup"
{
    Extensible = False;
    Caption = 'Vipps MobilePay Login Setup';
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    UsageCategory = Administration;
    DelayedInsert = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    ShowFilter = false;
    SourceTable = "NPR MM VippsMP Login Setup";

    layout
    {
        area(Content)
        {
            group(Scopes)
            {
                Caption = 'Scopes';

                group("Customer Card Scopes")
                {
                    Caption = 'Customer Card Request Scopes';
                    field("Cust. Card Name"; Rec."Cust. Card Name")
                    {
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                        ToolTip = 'Specifies whether the user''s name is part of the communication request.';
                    }
                    field("Cust. Card Birthdate"; Rec."Cust. Card Birthdate")
                    {
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                        ToolTip = 'Specifies whether the user''s birthdate is part of the communication request.';
                    }
                    field("Cust. Card E-Mail"; Rec."Cust. Card E-Mail")
                    {
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                        ToolTip = 'Specifies whether the user''s email is part of the communication request.';
                    }
                    field("Cust. Card Address"; Rec."Cust. Card Address")
                    {
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                        ToolTip = 'Specifies whether the user''s adress is part of the communication request.';
                    }
                    field("Cust. Card Delegated Consents"; Rec."Cust. Card Delegated Consents")
                    {
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                        ToolTip = 'Specifies whether asking for marketing consents is part of the communication request.';
                    }
                }
                group("Member Card Scopes")
                {
                    Caption = 'Member Card Request Scopes';
                    field("Member Card Name"; Rec."Member Card Name")
                    {
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                        ToolTip = 'Specifies whether the user''s name is part of the communication request.';
                    }
                    field("Member Card Birthdate"; Rec."Member Card Birthdate")
                    {
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                        ToolTip = 'Specifies whether the user''s birthdate is part of the communication request.';
                    }
                    field("Member Card E-Mail"; Rec."Member Card E-Mail")
                    {
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                        ToolTip = 'Specifies whether the user''s email is part of the communication request.';
                    }
                    field("Member Card Address"; Rec."Member Card Address")
                    {
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                        ToolTip = 'Specifies whether the user''s adress is part of the communication request.';
                    }
                    field("Member Card Delegated Consents"; Rec."Member Card Delegated Consents")
                    {
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                        ToolTip = 'Specifies whether asking for marketing consents is part of the communication request.';
                    }
                }
            }
            group(Setup)
            {
                ShowCaption = false;
                field(Environment; Rec.Environment)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the type of envinroment used for fetching the communication configuration.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
