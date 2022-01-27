codeunit 6014656 "NPR MM Request Member Upd Mgr"
{
    Access = Internal;
    procedure UpdateMemberField(EntryNo: Integer; CurrentValue: Text[200]; NewValue: Text[200]; MembershipEntryNo: Integer)
    var
        Member: Record "NPR MM Member";
        RequestMemberUpdate: Record "NPR MM Request Member Update";
        Membership: Record "NPR MM Membership";
        NPRMembership: Codeunit "NPR MM NPR Membership";
        NotValidReasonXml: Text;
        FaultString: Text;
        RecRef: RecordRef;
        FldRef: FieldRef;
        DateType: Date;
        OptionType: Option;
    begin
        if (not RequestMemberUpdate.Get(EntryNo)) then
            exit;

        if (RequestMemberUpdate.Handled) then
            exit;

        if (not Member.Get(RequestMemberUpdate."Member Entry No.")) then
            exit;

        RequestMemberUpdate."New Value" := NewValue;
        RequestMemberUpdate."Response Datetime" := CurrentDateTime();
        RequestMemberUpdate.Handled := true;
        RequestMemberUpdate.Modify();

        if (RequestMemberUpdate."Current Value" <> CurrentValue) then
            exit; // Value has already been changed by someone else.

        if (CurrentValue <> NewValue) then begin
            RecRef.GetTable(Member);
            FldRef := RecRef.Field(RequestMemberUpdate."Field No.");

            case FldRef.Type of
                FldRef.Type::Code:
                    FldRef.Value := CopyStr(NewValue, 1, FldRef.Length);
                FldRef.Type::Text:
                    FldRef.Value := CopyStr(NewValue, 1, FldRef.Length);
                FldRef.Type::Date:
                    begin
                        Evaluate(DateType, CopyStr(NewValue, 1, 10), 9);
                        FldRef.Value := DateType;
                    end;
                FldRef.Type::Option:
                    begin
                        Evaluate(OptionType, CopyStr(NewValue, 1, 10), 9);
                        FldRef.Value := DateType;
                    end;
            end;
            RecRef.SetTable(Member);

            case RequestMemberUpdate."Field No." of
                35, Member.FieldNo("E-Mail Address"):
                    Member."E-Mail Address" := ValidateEmail(Member, Member."E-Mail Address");
            end;

            Member.Modify();
        end;

        // Update the remote request as handled and update to new value
        if (RequestMemberUpdate."Remote Entry No." <> 0) then begin
            if (not Membership.Get(MembershipEntryNo)) then
                //Error ('Invalid membership entry number specified for update member field function. Update of remote not possible.');
                exit;

            if (not NPRMembership.UpdateMemberField(Membership."Community Code", RequestMemberUpdate, NotValidReasonXml)) then begin
                if (TryGetMessage(NotValidReasonXml, FaultString)) then
                    Error(FaultString);
                Error(NotValidReasonXml);
            end;
        end;
    end;

    procedure RequestFieldUpdate(CardNumber: Text[50]; FieldId: Code[10]; ScannerStationId: Code[10])
    var
        MemberCard: Record "NPR MM Member Card";
    begin
        MemberCard.SetFilter("External Card No.", '=%1', CardNumber);
        if (not MemberCard.FindFirst()) then
            exit;

        if (MemberCard."Member Entry No." = 0) then
            exit;

        AddSelectedMemberFields(MemberCard."Member Entry No.");
    end;

    procedure AddSelectedMemberFields(MemberEntryNo: Integer)
    var
        Member: Record "NPR MM Member";
    begin
        AddFieldUpdateRequest(MemberEntryNo, Member.FieldNo("First Name"));
        AddFieldUpdateRequest(MemberEntryNo, Member.FieldNo("Middle Name"));
        AddFieldUpdateRequest(MemberEntryNo, Member.FieldNo("Last Name"));
        AddFieldUpdateRequest(MemberEntryNo, Member.FieldNo("Phone No."));
        AddFieldUpdateRequest(MemberEntryNo, Member.FieldNo(Address));
        AddFieldUpdateRequest(MemberEntryNo, Member.FieldNo("Post Code Code"));
        AddFieldUpdateRequest(MemberEntryNo, Member.FieldNo(City));
        AddFieldUpdateRequest(MemberEntryNo, Member.FieldNo("Country Code"));
        AddFieldUpdateRequest(MemberEntryNo, Member.FieldNo(Gender));
        AddFieldUpdateRequest(MemberEntryNo, Member.FieldNo(Birthday));
        AddFieldUpdateRequest(MemberEntryNo, Member.FieldNo("E-Mail Address"));
        AddFieldUpdateRequest(MemberEntryNo, Member.FieldNo("Store Code"));
    end;

    procedure AddFieldUpdateRequest(MemberEntryNo: Integer; FieldNo: Integer): Integer
    var
        Member: Record "NPR MM Member";
        RequestMemberUpdate: Record "NPR MM Request Member Update";
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        Member.Get(MemberEntryNo);
        RecRef.GetTable(Member);
        FldRef := RecRef.Field(FieldNo);

        RequestMemberUpdate.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        RequestMemberUpdate.SetFilter("Field No.", '=%1', FieldNo);
        RequestMemberUpdate.SetFilter(Handled, '=%1', false);
        if (not RequestMemberUpdate.FindFirst()) then begin
            RequestMemberUpdate."Entry No." := 0;
            RequestMemberUpdate."Member Entry No." := MemberEntryNo;
            RequestMemberUpdate."Member No." := Member."External Member No.";
            RequestMemberUpdate."Field No." := FieldNo;

            RequestMemberUpdate."Current Value" := CopyStr(FORMAT(FldRef.Value, 0, 9), 1, MaxStrLen(RequestMemberUpdate."Current Value"));
            RequestMemberUpdate.Caption := CopyStr(FldRef.Caption(), 1, MaxStrLen(RequestMemberUpdate.Caption));
            RequestMemberUpdate."Request Datetime" := CurrentDateTime();
            RequestMemberUpdate.Insert();
        end else begin
            RequestMemberUpdate."Current Value" := CopyStr(FORMAT(FldRef.Value, 0, 9), 1, MaxStrLen(RequestMemberUpdate."Current Value"));
            RequestMemberUpdate.Caption := CopyStr(FldRef.Caption(), 1, MaxStrLen(RequestMemberUpdate.Caption));
            RequestMemberUpdate."Request Datetime" := CurrentDateTime();
            RequestMemberUpdate.Modify();
        end;

        exit(RequestMemberUpdate."Entry No.");
    end;

    local procedure ValidateEmail(Member: Record "NPR MM Member"; "E-Mail": Text[80]): Text[80]
    var
        ValidEmail: Boolean;
        TempMemberCommunity: Record "NPR MM Member Community" temporary;
        MemberCommunity: Record "NPR MM Member Community";
        MembershipRole: Record "NPR MM Membership Role";
        Membership: Record "NPR MM Membership";
        Member2: Record "NPR MM Member";
        NOT_BLANK: Label 'Value cannot be blank.';
        INVALID_VALUE: Label 'The %1 is invalid.';
    begin

        if ("E-Mail" = '') then
            Error(NOT_BLANK);

        ValidEmail := (StrPos("E-Mail", '@') > 1);
        if (ValidEmail) then
            ValidEmail := (StrPos(CopyStr("E-Mail", STRPOS("E-Mail", '@')), '.') > 1);

        if (not ValidEmail) then
            Error(INVALID_VALUE, Member.FIELDCAPTION("E-Mail Address"));

        // Add all communities target member belongs to
        MembershipRole.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
        if (MembershipRole.FindSet()) then begin
            repeat
                Membership.Get(MembershipRole."Membership Entry No.");
                MemberCommunity.Get(Membership."Community Code");
                if (MemberCommunity."Member Unique Identity" IN [MemberCommunity."Member Unique Identity"::EMAIL,
                                                                 MemberCommunity."Member Unique Identity"::EMAIL_AND_PHONE,
                                                                 MemberCommunity."Member Unique Identity"::EMAIL_OR_PHONE]) then begin
                    TempMemberCommunity.TransferFields(MemberCommunity, true);
                    TempMemberCommunity.Insert();
                end;
            until (MembershipRole.Next() = 0);
        end;

        // Find other members with same email and check if they belong to the same community with email constraint
        Member2.SetFilter("E-Mail Address", '=%1', LowerCase("E-Mail"));
        if (Member2.FindSet()) then begin
            repeat
                if (Member."Entry No." <> Member2."Entry No.") then begin
                    MembershipRole.SetFilter("Member Entry No.", '=%1', Member2."Entry No.");
                    if (MembershipRole.FindSet()) then begin
                        repeat
                            Membership.Get(MembershipRole."Membership Entry No.");
                            if (TempMemberCommunity.Get(Membership."Community Code")) then begin
                                if (TempMemberCommunity."Member Unique Identity" = TempMemberCommunity."Member Unique Identity"::EMAIL) then
                                    Error('E-Mail is not valid. The E-Mail is already in use.');
                                if (TempMemberCommunity."Member Unique Identity" = TempMemberCommunity."Member Unique Identity"::EMAIL_AND_PHONE) then
                                    if (Member."Phone No." = Member2."Phone No.") then
                                        Error('E-Mail is not valid. Combination of E-Mail and phone number is already in use.');
                                if (TempMemberCommunity."Member Unique Identity" = TempMemberCommunity."Member Unique Identity"::EMAIL_OR_PHONE) then
                                    Error('E-Mail is not valid. Combination of E-Mail or phone number is already in use.');
                            end;

                        until (MembershipRole.Next() = 0);
                    end;
                end;
            until (Member2.Next() = 0);
        end;

        exit(LowerCase("E-Mail"));

    end;

    [TryFunction]
    local procedure TryGetMessage(ReasonText: Text; var FaultMessage: Text)
    var
        Document: XmlDocument;
        Node: XmlNode;
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
    begin
        FaultMessage := ReasonText;
        if (XmlDocument.ReadFrom(FaultMessage, Document)) then
            if (NpXmlDomMgt.FindNode(Document.AsXmlNode(), '//faultstring', Node)) then
                FaultMessage := Node.AsXmlElement().InnerText();
    end;

}
