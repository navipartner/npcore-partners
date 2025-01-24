page 6151381 "NPR Members. Alter. Setup Step"
{
    Extensible = False;
    Caption = 'Membership Alteration Setup';
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR MM Members. Alter. Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Alteration Type"; Rec."Alteration Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Alteration Type field.';
                }
                field("From Membership Code"; Rec."From Membership Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the From Membership Code field.';
                }
                field("Sales Item No."; Rec."Sales Item No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sales Item No. field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description 2 field.';
                    Visible = false;
                }
                field("To Membership Code"; Rec."To Membership Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the To Membership Code field.';
                }
                field("Alteration Activate From"; Rec."Alteration Activate From")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Alteration Activate From field.';
                }
                field("Alteration Date Formula"; Rec."Alteration Date Formula")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Alteration Date Formula field.';
                }
                field("Membership Duration"; Rec."Membership Duration")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Membership Duration field.';
                }
                field("Auto-Renew To"; Rec."Auto-Renew To")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Auto-Renew To field.';
                }
            }
        }
    }

    internal procedure CopyLiveData()
    var
        MembershipAlterationSetups: Record "NPR MM Members. Alter. Setup";
    begin
        Rec.DeleteAll();

        if MembershipAlterationSetups.FindSet() then
            repeat
                Rec := MembershipAlterationSetups;
                if not Rec.Insert() then
                    Rec.Modify();
            until MembershipAlterationSetups.Next() = 0;
    end;

    internal procedure MembershipAlterationSetupsToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreateMembershipAlterationSetups()
    var
        MembershipAlterationSetups: Record "NPR MM Members. Alter. Setup";
    begin
        if Rec.FindSet() then
            repeat
                MembershipAlterationSetups := Rec;
                if not MembershipAlterationSetups.Insert() then
                    MembershipAlterationSetups.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure CopyTempMembershipAlterationSetups(var TempMembershipAlterationSetups: Record "NPR MM Members. Alter. Setup")
    begin
        TempMembershipAlterationSetups.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempMembershipAlterationSetups := Rec;
                if not TempMembershipAlterationSetups.Insert() then
                    TempMembershipAlterationSetups.Modify();
            until Rec.Next() = 0;
    end;
}
