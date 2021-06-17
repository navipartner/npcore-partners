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
                field("Community Code"; Rec."Community Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Community Code field';
                }
                field("Manager Code"; Rec."Manager Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Manager Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Invokation Priority"; Rec."Invokation Priority")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invokation Priority field';
                }
                field(Disabled; Rec.Disabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Disabled field';
                }
                field("Append Local Prefix"; Rec."Append Local Prefix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Append Local Prefix field';
                }
                field("Remove Local Prefix"; Rec."Remove Local Prefix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remove Local Prefix field';
                }
                field("Append Local Suffix"; Rec."Append Local Suffix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Append Local Suffix field';
                }
                field("Remove Local Suffix"; Rec."Remove Local Suffix")
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
                PromotedOnly = true;
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
                PromotedOnly = true;
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
        MMForeignMembershipMgr: Codeunit "NPR MM Foreign Members. Mgr.";
    begin

        MMForeignMembershipMgr.ShowSetup(Rec);
    end;

    local procedure ShowDashboard()
    begin

        ForeignMembershipMgr.ShowDashboard(Rec);
    end;
}

