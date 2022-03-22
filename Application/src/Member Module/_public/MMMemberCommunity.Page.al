﻿page 6060132 "NPR MM Member Community"
{

    Caption = 'Member Community';
    PageType = List;
    SourceTable = "NPR MM Member Community";
    UsageCategory = Administration;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External No. Search Order"; Rec."External No. Search Order")
                {

                    ToolTip = 'Specifies the value of the External No. Search Order field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Membership No. Series"; Rec."External Membership No. Series")
                {

                    ToolTip = 'Specifies the value of the External Membership No. Series field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Member No. Series"; Rec."External Member No. Series")
                {

                    ToolTip = 'Specifies the value of the External Member No. Series field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Customer No. Series"; Rec."Customer No. Series")
                {

                    ToolTip = 'Specifies the value of the Customer No. Series field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Unique Identity"; Rec."Member Unique Identity")
                {

                    ToolTip = 'Specifies the value of the Member Unique Identity field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Create Member UI Violation"; Rec."Create Member UI Violation")
                {

                    ToolTip = 'Specifies the value of the Create Member UI Violation field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Logon Credentials"; Rec."Member Logon Credentials")
                {

                    ToolTip = 'Specifies the value of the Member Logon Credentials field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership to Cust. Rel."; Rec."Membership to Cust. Rel.")
                {

                    ToolTip = 'Specifies the value of the Membership to Cust. Rel. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Create Renewal Notifications"; Rec."Create Renewal Notifications")
                {

                    ToolTip = 'Specifies the value of the Create Renewal Notifications field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Activate Loyalty Program"; Rec."Activate Loyalty Program")
                {

                    ToolTip = 'Specifies the value of the Activate Loyalty Program field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Foreign Membership"; Rec."Foreign Membership")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Foreign Membership field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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

                ToolTip = 'Executes the Membership Setup action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action("Loyalty Setup")
            {
                Caption = 'Loyalty Setup';
                Image = SalesLineDisc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR MM Loyalty Setup";

                ToolTip = 'Executes the Loyalty Setup action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action("Notification Setup")
            {
                Caption = 'Notification Setup';
                Image = SetupList;
                RunObject = Page "NPR MM Member Notific. Setup";
                RunPageLink = "Community Code" = FIELD(Code);

                ToolTip = 'Executes the Notification Setup action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            separator(Separator6150626)
            {
            }
            action("Process Auto Renew")
            {
                Caption = 'Auto Renew Process';
                Ellipsis = true;
                Image = AutoReserve;
                RunObject = Page "NPR MM Members. AutoRenew List";
                RunPageLink = "Community Code" = FIELD(Code);

                ToolTip = 'Executes the Auto Renew Process action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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

                ToolTip = 'Executes the Memberships action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            separator(Separator6014405)
            {
            }
            action(Notifications)
            {
                Caption = 'Notifications';
                Image = InteractionLog;
                RunObject = Page "NPR MM Membership Notific.";

                ToolTip = 'Executes the Notifications action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action("Foreign Membership Setup")
            {
                Caption = 'Foreign Membership Setup';
                Ellipsis = true;
                Image = ElectronicBanking;
                RunObject = Page "NPR MM Foreign Members. Setup";
                RunPageLink = "Community Code" = FIELD(Code);

                ToolTip = 'Executes the Foreign Membership Setup action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
        area(processing)
        {
            action("Update Memberships Customer")
            {
                Caption = 'Update Memberships Customer';
                Image = CreateInteraction;
                RunObject = Report "NPR MM Sync. Community Cust.";

                ToolTip = 'Executes the Update Memberships Customer action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }

            action(CreateDemoData)
            {
                Caption = 'Create Demo Data';

                ToolTip = 'Executes the Create Demo Data action';
                Image = Action;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                var
                    CreateDemo: Codeunit "NPR MM Member Create Demo Data";
                begin
                    CreateDemo.CreateDemoData(false);
                end;

            }
        }

    }
}

