page 6184930 "NPR MM Members. Alter. Groups"
{
    Extensible = False;

    Caption = 'Membership Alteration Groups';
    PageType = List;
    SourceTable = "NPR MM Members. Alter. Group";
    UsageCategory = Administration;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies a value to identify the alteration group.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text to describe the the alteration group.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("No. of Alterations in Group"; Rec."No. of Alterations in Group")
                {
                    ToolTip = 'Specifies the number of alterations in the group.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    trigger OnDrillDown()
                    var
                        MMMembersAlterLine: Record "NPR MM Members. Alter. Line";
                        MMMembersAlterLines: Page "NPR MM Members. Alter. Lines";
                    begin
                        MMMembersAlterLine.SetRange("Group Code", Rec."Code");
                        MMMembersAlterLines.SetTableView(MMMembersAlterLine);
                        MMMembersAlterLines.RunModal();
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(AddAlterations)
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Caption = 'Add Alterations to Group';
                ToolTip = 'Let you select one or more Alterations to add to the group';
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                begin
                    Rec.AddAlterationsToGroup(Rec."Code");
                    CurrPage.Update(false);
                end;

            }
        }
    }
}
