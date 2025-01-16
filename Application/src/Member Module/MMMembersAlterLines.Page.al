page 6150851 "NPR MM Members. Alter. Lines"
{
    Extensible = False;

    Caption = 'MM Members. Alter. Lines';
    PageType = List;
    SourceTable = "NPR MM Members. Alter. Line";
    UsageCategory = None;
    InsertAllowed = false;
    ModifyAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Group Code"; Rec."Group Code")
                {
                    ToolTip = 'Specifies the value of the Group field.';
                    Visible = false;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Alteration Id"; Rec."Alteration Id")
                {
                    ToolTip = 'Specifies the value of the Alteration Id field.';
                    Visible = false;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Alteration Type"; MMMembersAlterSetup."Alteration Type")
                {
                    ToolTip = 'Specifies the value of the Alteration Type field.';
                    Editable = false;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("From Membership Code"; MMMembersAlterSetup."From Membership Code")
                {
                    ToolTip = 'Specifies the value of the From Membership Code field.';
                    Editable = false;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Sales Item No."; MMMembersAlterSetup."Sales Item No.")
                {
                    ToolTip = 'Specifies the value of the Sales Item No. field.';
                    Editable = false;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; MMMembersAlterSetup.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    Editable = false;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("To Membership Code"; MMMembersAlterSetup."To Membership Code")
                {
                    ToolTip = 'Specifies the value of the To Membership Code field.';
                    Editable = false;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
                Caption = 'Add Alterations';
                ToolTip = 'Let you select one or more Alterations to add to the group';
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                trigger OnAction()
                begin
                    AddToGroup();
                end;
            }
        }
    }


    trigger OnAfterGetRecord()
    begin
        if not MMMembersAlterSetup.GetBySystemId(Rec."Alteration Id") then
            MMMembersAlterSetup.Init();
    end;

    local procedure AddToGroup()
    var
        MMMembersAlterGroup: Record "NPR MM Members. Alter. Group";
        AlterationGroup: Code[10];
    begin
        if Rec."Group Code" <> '' then
            AlterationGroup := Rec."Group Code"
        else
            TryGetGroupFromFilter(AlterationGroup);
        if AlterationGroup = '' then
            exit;
        MMMembersAlterGroup.AddAlterationsToGroup(AlterationGroup);
    end;

    [TryFunction]
    local procedure TryGetGroupFromFilter(AlterationGroup: Code[10])
    begin
        if Rec.GetFilter("Group Code") = '' then
            exit;
        if Rec.GetRangeMin("Group Code") <> Rec.GetRangeMax("Group Code") then
            exit;
        AlterationGroup := CopyStr(Rec.GetFilter("Group Code"), 1, MaxStrLen(Rec."Group Code"));
    end;

    var
        MMMembersAlterSetup: Record "NPR MM Members. Alter. Setup";
}
