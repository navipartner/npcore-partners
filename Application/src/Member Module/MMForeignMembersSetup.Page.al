page 6060146 "NPR MM Foreign Members. Setup"
{

    Caption = 'Foreign Membership Setup';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Foreign Members. Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Community Code"; "Community Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Community Code field';
                }
                field("Manager Code"; "Manager Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Manager Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Invokation Priority"; "Invokation Priority")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invokation Priority field';
                }
                field(Disabled; Disabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Disabled field';
                }
                field("Append Local Prefix"; "Append Local Prefix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Append Local Prefix field';
                }
                field("Remove Local Prefix"; "Remove Local Prefix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remove Local Prefix field';
                }
                field("Append Local Suffix"; "Append Local Suffix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Append Local Suffix field';
                }
                field("Remove Local Suffix"; "Remove Local Suffix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remove Local Suffix field';
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
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Show Setup action';

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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Show Dashboard action';

                trigger OnAction()
                begin

                    ShowDashboard();
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
        ForeignMembershipMgr: Codeunit "NPR MM Foreign Members. Mgr.";
    begin

        ForeignMembershipMgr.ShowSetup(Rec);
    end;

    local procedure ShowDashboard()
    begin

        ForeignMembershipMgr.ShowDashboard(Rec);
    end;
}

