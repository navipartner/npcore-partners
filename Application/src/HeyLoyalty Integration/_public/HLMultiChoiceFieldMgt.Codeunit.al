codeunit 6150954 "NPR HL MultiChoice Field Mgt."
{
    Access = Public;

    var
        HLIntegrationEvents: Codeunit "NPR HL Integration Events";

    procedure ShowAssignedHLMultiChoiceFieldOptionValues(AppliesToRecID: RecordID; MultiChoiceFieldCode: Code[20]; Editable: Boolean)
    var
        HLMultiChoiceFldOption: Record "NPR HL MultiChoice Fld Option";
        HLSelectedMCFOption: Record "NPR HL Selected MCF Option";
        HLSelectMCFOptions: Page "NPR HL Select MCF Options";
        ChangesFound: Boolean;
    begin
        if AssignedMCFOptionsExist(AppliesToRecID, MultiChoiceFieldCode, HLSelectedMCFOption) then
            MarkAssignedMCFOptions(HLSelectedMCFOption, HLMultiChoiceFldOption);
        HLMultiChoiceFldOption.FilterGroup(2);
        HLMultiChoiceFldOption.SetRange("Field Code", MultiChoiceFieldCode);
        HLMultiChoiceFldOption.FilterGroup(0);
        HLMultiChoiceFldOption.SetCurrentKey("Field Code", "Sort Order");

        HLIntegrationEvents.OnBeforeShowAssignedHLMCFOptionValues(AppliesToRecID, MultiChoiceFieldCode, Editable, HLMultiChoiceFldOption);
        Clear(HLSelectMCFOptions);
        HLSelectMCFOptions.SetDataset(HLMultiChoiceFldOption);
        HLSelectMCFOptions.LookupMode(Editable);
        HLSelectMCFOptions.Editable(Editable);
        if HLSelectMCFOptions.RunModal() <> ACTION::LookupOK then
            exit;

        HLSelectMCFOptions.GetDataset(HLMultiChoiceFldOption);
        HLMultiChoiceFldOption.MarkedOnly(true);
        if HLMultiChoiceFldOption.FindSet() then
            repeat
                if AssignMCFOption(AppliesToRecID, HLMultiChoiceFldOption, HLSelectedMCFOption) then
                    ChangesFound := true;
            until HLMultiChoiceFldOption.Next() = 0;

        if RemoveObsoleteAssignedMCFOptions(HLSelectedMCFOption) then
            ChangesFound := true;

        if ChangesFound then
            HLIntegrationEvents.OnAfterManuallyModifyAssignedHLMCFOptionValues(AppliesToRecID, MultiChoiceFieldCode);
    end;

    procedure GetAssignedHLMultiChoiceFieldOptionValuesAsString(AppliesToRecID: RecordID; MultiChoiceFieldCode: Code[20]; Use: Option "Option IDs",Descriptions,"Magento Names","HeyLoyalty Names"): Text
    var
        HLMultiChoiceFldOption: Record "NPR HL MultiChoice Fld Option";
        HLSelectedMCFOption: Record "NPR HL Selected MCF Option";
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
        AssignedValueString: TextBuilder;
        HeyLoyaltyName: Text;
    begin
        if not AssignedMCFOptionsExist(AppliesToRecID, MultiChoiceFieldCode, HLSelectedMCFOption) then
            exit('');
        MarkAssignedMCFOptions(HLSelectedMCFOption, HLMultiChoiceFldOption);
        HLMultiChoiceFldOption.SetRange("Field Code", MultiChoiceFieldCode);
        HLMultiChoiceFldOption.MarkedOnly(true);
        if HLMultiChoiceFldOption.IsEmpty() then
            exit('');
        HLMultiChoiceFldOption.SetCurrentKey("Field Code", "Sort Order");
        HLMultiChoiceFldOption.findset();
        repeat
            case Use of
                Use::"Option IDs":
                    AssignedValueString.Append(Format(HLMultiChoiceFldOption."Option ID") + ',');
                Use::Descriptions:
                    begin
                        if HLMultiChoiceFldOption.Description = '' then
                            HLMultiChoiceFldOption.Description := Format(HLMultiChoiceFldOption."Option ID");
                        AssignedValueString.Append(HLMultiChoiceFldOption.Description + ',');
                    end;
                Use::"Magento Names":
                    if HLMultiChoiceFldOption."Magento Description" <> '' then
                        AssignedValueString.Append(HLMultiChoiceFldOption."Magento Description" + ',');
                Use::"HeyLoyalty Names":
                    begin
                        HeyLoyaltyName := HLMappedValueMgt.GetMappedValue(HLMultiChoiceFldOption.RecordId(), HLMultiChoiceFldOption.FieldNo(Description), false);
                        if HeyLoyaltyName <> '' then
                            AssignedValueString.Append(HeyLoyaltyName + ',');
                    end;
            end;
        until HLMultiChoiceFldOption.Next() = 0;
        if AssignedValueString.Length = 0 then
            exit('');
        exit(AssignedValueString.ToText(1, AssignedValueString.Length - 1));
    end;

    procedure LookupMultiChoiceFieldCode(var SelectedValue: Text): Boolean
    var
        HLMultiChoiceField: Record "NPR HL MultiChoice Field";
    begin
        if SelectedValue <> '' then begin
            HLMultiChoiceField.Code := CopyStr(SelectedValue, 1, MaxStrLen(HLMultiChoiceField.Code));
            if HLMultiChoiceField.Find('=><') then;
        end;
        if Page.RunModal(0, HLMultiChoiceField) <> Action::LookupOK then
            exit(false);
        SelectedValue := HLMultiChoiceField.Code;
        exit(true);
    end;

    procedure LookupMultiChoiceFieldOption(MultiChoiceFieldCode: Code[20]; var SelectedValue: Text): Boolean
    var
        HLMultiChoiceFldOption: Record "NPR HL MultiChoice Fld Option";
    begin
        HLMultiChoiceFldOption.FilterGroup(2);
        HLMultiChoiceFldOption.SetRange("Field Code", MultiChoiceFieldCode);
        HLMultiChoiceFldOption.FilterGroup(0);
        if SelectedValue <> '' then
            if Evaluate(HLMultiChoiceFldOption."Option ID", SelectedValue, 9) then begin
                HLMultiChoiceFldOption."Field Code" := MultiChoiceFieldCode;
                if HLMultiChoiceFldOption.Find('=><') then;
            end;
        if Page.RunModal(0, HLMultiChoiceFldOption) <> Action::LookupOK then
            exit(false);
        SelectedValue := Format(HLMultiChoiceFldOption."Option ID", 0, 9);
        exit(true);
    end;

    procedure MCFOptionIsAssigned(AppliesToRecID: RecordID; MultiChoiceFieldCode: Code[20]; MultiChoiceFieldOptionID: Integer): Boolean
    var
        HLSelectedMCFOption: Record "NPR HL Selected MCF Option";
    begin
        FilterAssignedMCFOptions(AppliesToRecID, MultiChoiceFieldCode, HLSelectedMCFOption);
        HLSelectedMCFOption.SetRange("Field Option ID", MultiChoiceFieldOptionID);
        exit(not HLSelectedMCFOption.IsEmpty());
    end;

    procedure RemoveAssignedMCFOption(RecID: RecordId; MultiChoiceFieldCode: Code[20]; MultiChoiceFieldOptionID: Integer)
    var
        HLSelectedMCFOption: Record "NPR HL Selected MCF Option";
    begin
        FilterAssignedMCFOptions(RecID, MultiChoiceFieldCode, HLSelectedMCFOption);
        HLSelectedMCFOption.SetRange("Field Option ID", MultiChoiceFieldOptionID);
        if HLSelectedMCFOption.FindFirst() then
            HLSelectedMCFOption.Delete(true);
    end;

    procedure AssignMCFOption(RecID: RecordId; MultiChoiceFieldCode: Code[20]; MultiChoiceFieldOptionID: Integer): Boolean
    var
        HLMultiChoiceFldOption: Record "NPR HL MultiChoice Fld Option";
        HLSelectedMCFOption: Record "NPR HL Selected MCF Option";
    begin
        HLMultiChoiceFldOption."Field Code" := MultiChoiceFieldCode;
        HLMultiChoiceFldOption."Option ID" := MultiChoiceFieldOptionID;
        exit(AssignMCFOption(RecID, HLMultiChoiceFldOption, HLSelectedMCFOption));
    end;

    internal procedure UpdateHLMemberMCFOptionsFromMember(HLMember: Record "NPR HL HeyLoyalty Member"): Boolean
    var
        HLMultiChoiceField: Record "NPR HL MultiChoice Field";
        HLMember_SelectedMCFOption: Record "NPR HL Selected MCF Option";
        Member_SelectedMCFOption: Record "NPR HL Selected MCF Option";
        Member: Record "NPR MM Member";
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
        HeyLoyaltyName: Text;
        ChangesFound: Boolean;
    begin
        if (HLMember."Member Entry No." = 0) or HLMember.Deleted then
            exit(false);
        Member."Entry No." := HLMember."Member Entry No.";

        FilterAssignedMCFOptions(HLMember.RecordId(), '', HLMember_SelectedMCFOption);
        MarkSelectedMCFOptions(HLMember_SelectedMCFOption);

        if HLMultiChoiceField.FindSet() then
            repeat
                HeyLoyaltyName := HLMappedValueMgt.GetMappedValue(HLMultiChoiceField.RecordId(), HLMultiChoiceField.FieldNo(Description), false);
                if HeyLoyaltyName <> '' then
                    if AssignedMCFOptionsExist(Member.RecordId(), HLMultiChoiceField.Code, Member_SelectedMCFOption) then
                        ChangesFound := CopyAssignedMCFOptions(Member_SelectedMCFOption, HLMember.RecordId(), HLMember_SelectedMCFOption, false) or ChangesFound;
            until HLMultiChoiceField.Next() = 0;

        if RemoveObsoleteAssignedMCFOptions(HLMember_SelectedMCFOption) then
            ChangesFound := true;

        exit(ChangesFound);
    end;

    internal procedure UpdateMemberMCFOptionsFromHLMember(HLMember: Record "NPR HL HeyLoyalty Member")
    var
        HLMember_SelectedMCFOption: Record "NPR HL Selected MCF Option";
        Member_SelectedMCFOption: Record "NPR HL Selected MCF Option";
        Member: Record "NPR MM Member";
        DataLogMgt: Codeunit "NPR Data Log Management";
    begin
        if (HLMember."Member Entry No." = 0) or HLMember.Deleted then
            exit;
        Member."Entry No." := HLMember."Member Entry No.";

        FilterAssignedMCFOptions(Member.RecordId(), '', Member_SelectedMCFOption);
        MarkSelectedMCFOptions(Member_SelectedMCFOption);

        FilterAssignedMCFOptions(HLMember.RecordId(), '', HLMember_SelectedMCFOption);
        DataLogMgt.DisableDataLog(true);
        CopyAssignedMCFOptions(HLMember_SelectedMCFOption, Member.RecordId(), Member_SelectedMCFOption, false);
        DataLogMgt.DisableDataLog(false);

        RemoveObsoleteAssignedMCFOptions(Member_SelectedMCFOption);
    end;

    internal procedure UpdateHLMemberMCFOptionsFromHL(var HLMember: Record "NPR HL HeyLoyalty Member"; HLFieldName: Text[100]; HLMCFOptions: JsonArray): Boolean
    var
        HLMultiChoiceField: Record "NPR HL MultiChoice Field";
        HLMultiChoiceFldOption: Record "NPR HL MultiChoice Fld Option";
        HLSelectedMCFOption: Record "NPR HL Selected MCF Option";
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
        RecRef: RecordRef;
        HLMCFOptionValue: JsonToken;
        ChangesFound: Boolean;
        HLMultiChoiceFieldOptionValueNotFoundErr: Label 'There is no HeyLoyalty multiple choice field option with HeyLoyalty name %1 for HeyLoyalty field %2.';
    begin
        if not HLMappedValueMgt.FindMappedValue(Database::"NPR HL MultiChoice Field", HLMultiChoiceField.FieldNo(Description), HLFieldName, RecRef) then
            exit(false);
        RecRef.SetTable(HLMultiChoiceField);

        if AssignedMCFOptionsExist(HLMember.RecordId(), HLMultiChoiceField.Code, HLSelectedMCFOption) then
            MarkSelectedMCFOptions(HLSelectedMCFOption);

        foreach HLMCFOptionValue in HLMCFOptions do begin
            if not HLMappedValueMgt.FindMappedValue(
                Database::"NPR HL MultiChoice Fld Option", HLMultiChoiceFldOption.FieldNo(Description), CopyStr(HLMCFOptionValue.AsValue().AsText(), 1, 100), RecRef)
            then
                Error(HLMultiChoiceFieldOptionValueNotFoundErr, HLMCFOptionValue.AsValue().AsText(), HLFieldName);
            RecRef.SetTable(HLMultiChoiceFldOption);
            if AssignMCFOption(HLMember.RecordId(), HLMultiChoiceFldOption, HLSelectedMCFOption) then
                ChangesFound := true;
        end;

        if RemoveObsoleteAssignedMCFOptions(HLSelectedMCFOption) then
            ChangesFound := true;

        exit(ChangesFound);
    end;

    internal procedure AssignedMCFOptionsExist(AppliesToRecID: RecordID; MultiChoiceFieldCode: Code[20]; var HLSelectedMCFOption: Record "NPR HL Selected MCF Option"): Boolean
    begin
        FilterAssignedMCFOptions(AppliesToRecID, MultiChoiceFieldCode, HLSelectedMCFOption);
        exit(not HLSelectedMCFOption.IsEmpty());
    end;

    internal procedure MarkAssignedMCFOptions(var HLSelectedMCFOption: Record "NPR HL Selected MCF Option"; var HLMultiChoiceFldOption: Record "NPR HL MultiChoice Fld Option")
    begin
        Clear(HLMultiChoiceFldOption);
        if HLSelectedMCFOption.FindSet() then
            repeat
                if HLMultiChoiceFldOption.Get(HLSelectedMCFOption."Field Code", HLSelectedMCFOption."Field Option ID") then
                    HLMultiChoiceFldOption.Mark(true);
                HLSelectedMCFOption.Mark(true);
            until HLSelectedMCFOption.Next() = 0;
    end;

    local procedure FilterAssignedMCFOptions(AppliesToRecID: RecordID; MultiChoiceFieldCode: Code[20]; var HLSelectedMCFOption: Record "NPR HL Selected MCF Option")
    begin
        HLSelectedMCFOption.SetRange("Table No.", AppliesToRecID.TableNo());
        HLSelectedMCFOption.SetRange("BC Record ID", AppliesToRecID);
        if MultiChoiceFieldCode <> '' then
            HLSelectedMCFOption.SetRange("Field Code", MultiChoiceFieldCode);
    end;

    local procedure MarkSelectedMCFOptions(var HLSelectedMCFOption: Record "NPR HL Selected MCF Option")
    begin
        if HLSelectedMCFOption.FindSet(true) then
            repeat
                HLSelectedMCFOption.Mark(true);
            until HLSelectedMCFOption.Next() = 0;
    end;

    local procedure RemoveObsoleteAssignedMCFOptions(var HLSelectedMCFOption: Record "NPR HL Selected MCF Option"): Boolean
    begin
        HLSelectedMCFOption.MarkedOnly(true);
        if HLSelectedMCFOption.IsEmpty() then
            exit(false);
        HLSelectedMCFOption.DeleteAll();
        exit(true);
    end;

    local procedure AssignMCFOption(AppliesToRecID: RecordID; HLMultiChoiceFldOption: Record "NPR HL MultiChoice Fld Option"; var HLSelectedMCFOption: Record "NPR HL Selected MCF Option") NewSelectedOption: Boolean
    begin
        HLSelectedMCFOption."Table No." := AppliesToRecID.TableNo;
        HLSelectedMCFOption."BC Record ID" := AppliesToRecID;
        HLSelectedMCFOption."Field Code" := HLMultiChoiceFldOption."Field Code";
        HLSelectedMCFOption."Field Option ID" := HLMultiChoiceFldOption."Option ID";
        NewSelectedOption := not HLSelectedMCFOption.Find();
        if NewSelectedOption then begin
            HLSelectedMCFOption.Init();
            HLSelectedMCFOption.Insert();
        end;
        HLSelectedMCFOption.Mark(false);
    end;

    local procedure CopyAssignedMCFOptions(FromRecID: RecordId; ToRecID: RecordId): Boolean
    begin
        exit(CopyAssignedMCFOptions(FromRecID, ToRecID, '', false));
    end;

    local procedure CopyAssignedMCFOptions(FromRecID: RecordId; ToRecID: RecordId; MultiChoiceFieldCode: Code[20]; Move: Boolean) ChangesFound: Boolean
    var
        FromSelectedMCFOption: Record "NPR HL Selected MCF Option";
        ToSelectedMCFOption: Record "NPR HL Selected MCF Option";
    begin
        FilterAssignedMCFOptions(ToRecID, MultiChoiceFieldCode, ToSelectedMCFOption);
        MarkSelectedMCFOptions(ToSelectedMCFOption);

        if AssignedMCFOptionsExist(FromRecID, MultiChoiceFieldCode, FromSelectedMCFOption) then
            ChangesFound := CopyAssignedMCFOptions(FromSelectedMCFOption, ToRecID, ToSelectedMCFOption, Move);

        if RemoveObsoleteAssignedMCFOptions(ToSelectedMCFOption) then
            ChangesFound := true;
    end;

    local procedure CopyAssignedMCFOptions(var FromSelectedMCFOption: Record "NPR HL Selected MCF Option"; ToRecID: RecordID; var ToSelectedMCFOption: Record "NPR HL Selected MCF Option"; Move: Boolean) ChangesFound: Boolean
    var
        HLMultiChoiceFldOption: Record "NPR HL MultiChoice Fld Option";
    begin
        if not FromSelectedMCFOption.FindSet() then
            exit;
        repeat
            HLMultiChoiceFldOption."Field Code" := FromSelectedMCFOption."Field Code";
            HLMultiChoiceFldOption."Option ID" := FromSelectedMCFOption."Field Option ID";
            if AssignMCFOption(ToRecID, HLMultiChoiceFldOption, ToSelectedMCFOption) then
                ChangesFound := true;
        until FromSelectedMCFOption.Next() = 0;

        if Move then
            FromSelectedMCFOption.DeleteAll(true);
    end;

    local procedure RemoveAssignedMCFOptions(RecID: RecordId)
    var
        HLSelectedMCFOption: Record "NPR HL Selected MCF Option";
    begin
        if AssignedMCFOptionsExist(RecID, '', HLSelectedMCFOption) then
            HLSelectedMCFOption.DeleteAll(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Membership Events", 'OnBeforeApplyAttributeToMemberInfoCapture', '', false, false)]
    local procedure ReadMagentoIncomingMCFOptionValues(var MemberInfoCapture: Record "NPR MM Member Info Capture"; AttributeCode: Text; AttributeValue: Text; var Handled: Boolean)
    var
        HLMultiChoiceField: Record "NPR HL MultiChoice Field";
        HLMultiChoiceFldOption: Record "NPR HL MultiChoice Fld Option";
        HLSelectedMCFOption: Record "NPR HL Selected MCF Option";
        MagentoOptionValues: List of [Text];
        MagentoOptionValue: Text;
    begin
        HLMultiChoiceField.SetRange("Magento Field Name", CopyStr(AttributeCode, 1, MaxStrLen(HLMultiChoiceField."Magento Field Name")));
        if HLMultiChoiceField.IsEmpty() then
            exit;

        Handled := true;

        HLMultiChoiceField.SetCurrentKey("Magento Field Name");
        HLMultiChoiceField.FindFirst();

        if AssignedMCFOptionsExist(MemberInfoCapture.RecordId(), HLMultiChoiceField.Code, HLSelectedMCFOption) then
            MarkSelectedMCFOptions(HLSelectedMCFOption);

        HLMultiChoiceFldOption.SetCurrentKey("Magento Description");
        HLMultiChoiceFldOption.SetRange("Field Code", HLMultiChoiceField.Code);
        MagentoOptionValues := AttributeValue.Split(',');
        foreach MagentoOptionValue in MagentoOptionValues do
            if MagentoOptionValue <> '' then begin
                HLMultiChoiceFldOption.SetRange("Magento Description", CopyStr(MagentoOptionValue, 1, MaxStrLen(HLMultiChoiceFldOption."Magento Description")));
                HLMultiChoiceFldOption.FindFirst();
                AssignMCFOption(MemberInfoCapture.RecordId(), HLMultiChoiceFldOption, HLSelectedMCFOption);
            end;

        RemoveObsoleteAssignedMCFOptions(HLSelectedMCFOption);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Membership Events", 'OnAfterSetMemberFields', '', false, false)]
    local procedure UpdateMemberMCFOptionsFromMemberInfoCapture(var Member: Record "NPR MM Member"; MemberInfoCapture: Record "NPR MM Member Info Capture")
    begin
        if Member."Entry No." = 0 then
            exit;
        CopyAssignedMCFOptions(MemberInfoCapture.RecordId(), Member.RecordId());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Membership Events", 'OnAfterMemberCreateEvent', '', false, false)]
    local procedure UpdateMemberMCFOptionsFromMemberInfoCaptureOnMemberCreate(var Member: Record "NPR MM Member"; MemberInfoCapture: Record "NPR MM Member Info Capture")
    begin
        CopyAssignedMCFOptions(MemberInfoCapture.RecordId(), Member.RecordId());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Member", 'OnAfterDeleteEvent', '', false, false)]
    local procedure Member_RemoveAssignedMCFOptions(var Rec: Record "NPR MM Member"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        RemoveAssignedMCFOptions(Rec.RecordId());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Member", 'OnAfterRenameEvent', '', false, false)]
    local procedure Member_MoveAssignedMCFOptionValues(var Rec: Record "NPR MM Member"; var xRec: Record "NPR MM Member"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        CopyAssignedMCFOptions(xRec.RecordId(), Rec.RecordId(), '', true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Member Info Capture", 'OnAfterDeleteEvent', '', false, false)]
    local procedure MemberInfoCapture_RemoveAssignedMCFOptionValues(var Rec: Record "NPR MM Member Info Capture"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        RemoveAssignedMCFOptions(Rec.RecordId());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Member Info Capture", 'OnAfterRenameEvent', '', false, false)]
    local procedure MemberInfoCapture_MoveAssignedMCFOptionValues(var Rec: Record "NPR MM Member Info Capture"; var xRec: Record "NPR MM Member Info Capture"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        CopyAssignedMCFOptions(xRec.RecordId(), Rec.RecordId(), '', true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR HL HeyLoyalty Member", 'OnAfterDeleteEvent', '', false, false)]
    local procedure HLMember_RemoveAssignedMCFOptionValues(var Rec: Record "NPR HL HeyLoyalty Member"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        RemoveAssignedMCFOptions(Rec.RecordId());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR HL HeyLoyalty Member", 'OnAfterRenameEvent', '', false, false)]
    local procedure HLMember_MoveAssignedMCFOptionValues(var Rec: Record "NPR HL HeyLoyalty Member"; var xRec: Record "NPR HL HeyLoyalty Member"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        CopyAssignedMCFOptions(xRec.RecordId(), Rec.RecordId(), '', true);
    end;
}