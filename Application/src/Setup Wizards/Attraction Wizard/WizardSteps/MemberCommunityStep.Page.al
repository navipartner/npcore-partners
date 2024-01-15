page 6151380 "NPR Member Community Step"
{
    Extensible = False;
    Caption = 'Member Community';
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR MM Member Community";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Member Community Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("External Membership No. Series"; Rec."External Membership No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the External Membership No. Series field';
                }
                field("External Member No. Series"; Rec."External Member No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the External Member No. Series field';
                }
            }
        }
    }

    internal procedure CopyLiveData()
    var
        MemberCommunities: Record "NPR MM Member Community";
    begin
        Rec.DeleteAll();

        if MemberCommunities.FindSet() then
            repeat
                Rec := MemberCommunities;
                if not Rec.Insert() then
                    Rec.Modify();
            until MemberCommunities.Next() = 0;
    end;

    internal procedure MemberCommunitiesToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreateMemberCommunities()
    var
        MemberCommunities: Record "NPR MM Member Community";
    begin
        if Rec.FindSet() then
            repeat
                MemberCommunities := Rec;
                if not MemberCommunities.Insert() then
                    MemberCommunities.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure CopyTempMemberCommunities(var TempMemberCommunities: Record "NPR MM Member Community")
    begin
        TempMemberCommunities.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempMemberCommunities := Rec;
                if not TempMemberCommunities.Insert() then
                    TempMemberCommunities.Modify();
            until Rec.Next() = 0;
    end;
}
