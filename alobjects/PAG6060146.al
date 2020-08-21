page 6060146 "MM Foreign Membership Setup"
{
    // MM1.23/TSA /20171025 CASE 257011 Initial Version
    // #334163/JDH /20181109 CASE 334163 Added Caption to Actions
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019

    Caption = 'Foreign Membership Setup';
    PageType = List;
    SourceTable = "MM Foreign Membership Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Community Code"; "Community Code")
                {
                    ApplicationArea = All;
                }
                field("Manager Code"; "Manager Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Invokation Priority"; "Invokation Priority")
                {
                    ApplicationArea = All;
                }
                field(Disabled; Disabled)
                {
                    ApplicationArea = All;
                }
                field("Append Local Prefix"; "Append Local Prefix")
                {
                    ApplicationArea = All;
                }
                field("Remove Local Prefix"; "Remove Local Prefix")
                {
                    ApplicationArea = All;
                }
                field("Append Local Suffix"; "Append Local Suffix")
                {
                    ApplicationArea = All;
                }
                field("Remove Local Suffix"; "Remove Local Suffix")
                {
                    ApplicationArea = All;
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
        ForeignMembershipMgr: Codeunit "MM Foreign Membership Mgr.";

    local procedure ShowSetup()
    var
        ForeignMembershipMgr: Codeunit "MM Foreign Membership Mgr.";
    begin

        ForeignMembershipMgr.ShowSetup(Rec);
    end;

    local procedure ShowDashboard()
    begin

        ForeignMembershipMgr.ShowDashboard(Rec);
    end;
}

