page 6060132 "NPR MM Member Community"
{

    Caption = 'Member Community';
    PageType = List;
    SourceTable = "NPR MM Member Community";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("External No. Search Order"; "External No. Search Order")
                {
                    ApplicationArea = All;
                }
                field("External Membership No. Series"; "External Membership No. Series")
                {
                    ApplicationArea = All;
                }
                field("External Member No. Series"; "External Member No. Series")
                {
                    ApplicationArea = All;
                }
                field("Customer No. Series"; "Customer No. Series")
                {
                    ApplicationArea = All;
                }
                field("Member Unique Identity"; "Member Unique Identity")
                {
                    ApplicationArea = All;
                }
                field("Create Member UI Violation"; "Create Member UI Violation")
                {
                    ApplicationArea = All;
                }
                field("Member Logon Credentials"; "Member Logon Credentials")
                {
                    ApplicationArea = All;
                }
                field("Membership to Cust. Rel."; "Membership to Cust. Rel.")
                {
                    ApplicationArea = All;
                }
                field("Create Renewal Notifications"; "Create Renewal Notifications")
                {
                    ApplicationArea = All;
                }
                field("Activate Loyalty Program"; "Activate Loyalty Program")
                {
                    ApplicationArea = All;
                }
                field("Foreign Membership"; "Foreign Membership")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Membership Setup")
            {
                Caption = 'Membership Setup';
                Image = SetupList;
                RunObject = Page "NPR MM Membership Setup";
                RunPageLink = "Community Code" = FIELD(Code);
                ApplicationArea = All;
            }
            action("Loyalty Setup")
            {
                Caption = 'Loyalty Setup';
                Image = SalesLineDisc;
                Promoted = true;
                RunObject = Page "NPR MM Loyalty Setup";
                ApplicationArea = All;
            }
            action("Notification Setup")
            {
                Caption = 'Notification Setup';
                Image = SetupList;
                RunObject = Page "NPR MM Member Notific. Setup";
                RunPageLink = "Community Code" = FIELD(Code);
                ApplicationArea = All;
            }
            separator(Separator6150626)
            {
            }
            action("Process Auto Renew")
            {
                Caption = 'Auto Renew Process';
                Ellipsis = true;
                Image = AutoReserve;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                RunObject = Page "NPR MM Members. AutoRenew List";
                RunPageLink = "Community Code" = FIELD(Code);
                ApplicationArea = All;
            }
            separator(Separator6014406)
            {
            }
            action(Memberships)
            {
                Caption = 'Memberships';
                Image = List;
                RunObject = Page "NPR MM Memberships";
                RunPageLink = "Community Code" = FIELD(Code);
                ApplicationArea = All;
            }
            separator(Separator6014405)
            {
            }
            action(Notifications)
            {
                Caption = 'Notifications';
                Image = InteractionLog;
                RunObject = Page "NPR MM Membership Notific.";
                ApplicationArea = All;
            }
            action("Foreign Membership Setup")
            {
                Caption = 'Foreign Membership Setup';
                Ellipsis = true;
                Image = ElectronicBanking;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                RunObject = Page "NPR MM Foreign Members. Setup";
                RunPageLink = "Community Code" = FIELD(Code);
                ApplicationArea = All;
            }
        }
        area(processing)
        {
            action("Update Memberships Customer")
            {
                Caption = 'Update Memberships Customer';
                Image = CreateInteraction;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                RunObject = Report "NPR MM Sync. Community Cust.";
                ApplicationArea = All;
            }
        }
    }
}

