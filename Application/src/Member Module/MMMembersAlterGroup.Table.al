table 6059871 "NPR MM Members. Alter. Group"
{
    Access = Internal;

    Caption = 'Membership Alteration Group';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(12; "No. of Alterations in Group"; Integer)
        {
            Caption = 'No. of Alterations in Group';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("NPR MM Members. Alter. Line" where("Group Code" = field("Code")));
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        MMMembersAlterLine: Record "NPR MM Members. Alter. Line";
    begin
        MMMembersAlterLine.SetRange("Group Code", Rec."Code");
        MMMembersAlterLine.DeleteAll(true);
    end;

    procedure AddAlterationsToGroup(AlterationGroup: Code[10])
    var
        MMMembersAlterSetup: Record "NPR MM Members. Alter. Setup";
        MMMembersAlterLine: Record "NPR MM Members. Alter. Line";
        MMMembersAlter: Page "NPR MM Membership Alter.";

    begin
        MMMembersAlter.LookupMode(true);
        if MMMembersAlter.RunModal() = Action::LookupOK then begin
            MMMembersAlter.SetSelectionFilter(MMMembersAlterSetup);
            if MMMembersAlterSetup.FindSet() then
                repeat
                    if not MMMembersAlterLine.Get(AlterationGroup, MMMembersAlterSetup.SystemId) then begin
                        MMMembersAlterLine."Group Code" := AlterationGroup;
                        MMMembersAlterLine."Alteration Id" := MMMembersAlterSetup.SystemId;
                        MMMembersAlterLine.Insert(true);
                    end;
                until MMMembersAlterSetup.Next() = 0;
        end;
    end;

    procedure AddAlterationToGroups(Id: Guid)
    var
        MMMembersAlterGroup: Record "NPR MM Members. Alter. Group";
        MMMembersAlterLine: Record "NPR MM Members. Alter. Line";
        MMMembersAlterGroups: Page "NPR MM Members. Alter. Groups";
    begin
        MMMembersAlterGroups.LookupMode(true);
        if MMMembersAlterGroups.RunModal() = Action::LookupOK then begin
            MMMembersAlterGroups.SetSelectionFilter(MMMembersAlterGroup);
            if MMMembersAlterGroup.FindSet() then
                repeat
                    if not MMMembersAlterLine.Get(MMMembersAlterGroup.Code, Id) then begin
                        MMMembersAlterLine."Group Code" := MMMembersAlterGroup.Code;
                        MMMembersAlterLine."Alteration Id" := Id;
                        MMMembersAlterLine.Insert(true);
                    end;
                until MMMembersAlterGroup.Next() = 0;
        end;
    end;

}
