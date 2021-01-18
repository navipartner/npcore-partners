page 6060132 "NPR MM Member Community"
{

    Caption = 'Member Community';
    PageType = List;
    SourceTable = "NPR MM Member Community";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("External No. Search Order"; "External No. Search Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External No. Search Order field';
                }
                field("External Membership No. Series"; "External Membership No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Membership No. Series field';
                }
                field("External Member No. Series"; "External Member No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Member No. Series field';
                }
                field("Customer No. Series"; "Customer No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. Series field';
                }
                field("Member Unique Identity"; "Member Unique Identity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Unique Identity field';
                }
                field("Create Member UI Violation"; "Create Member UI Violation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Member UI Violation field';
                }
                field("Member Logon Credentials"; "Member Logon Credentials")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Logon Credentials field';
                }
                field("Membership to Cust. Rel."; "Membership to Cust. Rel.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership to Cust. Rel. field';
                }
                field("Create Renewal Notifications"; "Create Renewal Notifications")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Renewal Notifications field';
                }
                field("Activate Loyalty Program"; "Activate Loyalty Program")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Activate Loyalty Program field';
                }
                field("Foreign Membership"; "Foreign Membership")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Foreign Membership field';
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
                ToolTip = 'Executes the Membership Setup action';
            }
            action("Loyalty Setup")
            {
                Caption = 'Loyalty Setup';
                Image = SalesLineDisc;
                Promoted = true;
                RunObject = Page "NPR MM Loyalty Setup";
                ApplicationArea = All;
                ToolTip = 'Executes the Loyalty Setup action';
            }
            action("Notification Setup")
            {
                Caption = 'Notification Setup';
                Image = SetupList;
                RunObject = Page "NPR MM Member Notific. Setup";
                RunPageLink = "Community Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Notification Setup action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Auto Renew Process action';
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
                ToolTip = 'Executes the Memberships action';
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
                ToolTip = 'Executes the Notifications action';
            }
            action("Foreign Membership Setup")
            {
                Caption = 'Foreign Membership Setup';
                Ellipsis = true;
                Image = ElectronicBanking;
                RunObject = Page "NPR MM Foreign Members. Setup";
                RunPageLink = "Community Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Foreign Membership Setup action';
            }
        }
        area(processing)
        {
            action("Update Memberships Customer")
            {
                Caption = 'Update Memberships Customer';
                Image = CreateInteraction;
                RunObject = Report "NPR MM Sync. Community Cust.";
                ApplicationArea = All;
                ToolTip = 'Executes the Update Memberships Customer action';
            }

            action(CreateDemoData)
            {
                Caption = 'Create Demo Data';
                ApplicationArea = All;
                ToolTip = 'Executes the Create Demo Data action';
                Image = Action; 

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

