page 6060146 "NPR MM Foreign Members. Setup"
{
    Extensible = False;

    Caption = 'Foreign Membership Setup';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Foreign Members. Setup";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Community Code"; Rec."Community Code")
                {

                    ToolTip = 'Specifies the value of the Community Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Manager Code"; Rec."Manager Code")
                {

                    ToolTip = 'Specifies the value of the Manager Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Invokation Priority"; Rec."Invokation Priority")
                {

                    ToolTip = 'Specifies the value of the Invokation Priority field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Disabled; Rec.Disabled)
                {

                    ToolTip = 'Specifies the value of the Disabled field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Append Local Prefix"; Rec."Append Local Prefix")
                {

                    ToolTip = 'Specifies the value of the Append Local Prefix field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Remove Local Prefix"; Rec."Remove Local Prefix")
                {

                    ToolTip = 'Specifies the value of the Remove Local Prefix field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Append Local Suffix"; Rec."Append Local Suffix")
                {

                    ToolTip = 'Specifies the value of the Append Local Suffix field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Remove Local Suffix"; Rec."Remove Local Suffix")
                {

                    ToolTip = 'Specifies the value of the Remove Local Suffix field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Show Setup")
            {
                Caption = 'Show Setup';
                Ellipsis = true;
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Show Setup action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin
                    ShowSetup();
                end;
            }
            action("Show Dashboard")
            {
                Caption = 'Show Dashboard';
                Ellipsis = true;
                Image = Statistics;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Show Dashboard action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin
                    ShowDashboard();
                end;
            }
            action(SearchForeignMembers)
            {
                Caption = 'Search Foreign Members';
                Ellipsis = true;
                Image = Find;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Performs the remote member search functionality.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                var
                    RemoteMembershipMgt: Codeunit "NPR MM NPR Membership";
                    SelectedRemoteMemberCardNumber: Text[100];
                begin
                    RemoteMembershipMgt.SearchForeignMembers(Rec."Community Code", SelectedRemoteMemberCardNumber);
                    if (SelectedRemoteMemberCardNumber <> '') then
                        Message('The remote member card number selected is %1', SelectedRemoteMemberCardNumber);
                end;
            }
        }
    }

    trigger OnInit()
    begin
        ForeignMembershipMgr.RediscoverNewManagers();
    end;

    trigger OnOpenPage()
    begin

        if (Rec.GetFilter("Community Code") = '') then
            Rec.SetFilter("Community Code", '<>%1', '');
    end;

    var
        ForeignMembershipMgr: Codeunit "NPR MM Foreign Members. Mgr.";

    local procedure ShowSetup()
    var
        MMForeignMembershipMgr: Codeunit "NPR MM Foreign Members. Mgr.";
    begin

        MMForeignMembershipMgr.ShowSetup(Rec);
    end;

    local procedure ShowDashboard()
    begin
        ForeignMembershipMgr.ShowDashboard(Rec);
    end;
}

