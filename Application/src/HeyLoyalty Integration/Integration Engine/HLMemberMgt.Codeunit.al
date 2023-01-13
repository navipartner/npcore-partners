codeunit 6059995 "NPR HL Member Mgt."
{
    Access = Internal;
    TableNo = "NPR Data Log Record";

    trigger OnRun()
    begin
        if not HLIntegrationMgt.IsEnabled("NPR HL Integration Area"::Members) then
            exit;
        ProcessDataLogRecord(Rec);
        UpdateDataLogSubscriber(Rec);
    end;

    var
        HLIntegrationEvents: Codeunit "NPR HL Integration Events";
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        JsonHelper: Codeunit "NPR Json Helper";

    local procedure ProcessDataLogRecord(DataLogEntry: Record "NPR Data Log Record")
    var
        Member: Record "NPR MM Member";
        TempMembershipRole: Record "NPR MM Membership Role" temporary;
    begin
        if not HLIntegrationMgt.IsIntegratedTable("NPR HL Integration Area"::Members, DataLogEntry."Table ID") then
            exit;

        case true of
            DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Rename:
                exit;  //renames are not processed

            DataLogEntry."Table ID" = Database::"NPR MM Member":
                if FindMember(DataLogEntry, Member, TempMembershipRole) then
                    ProcessMember(Member, TempMembershipRole, DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Delete);

            DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Delete:
                exit;  //only member record deletes are processed

            else
                if FindRelatedMembers(DataLogEntry, TempMembershipRole) then
                    repeat
                        Member.Get(TempMembershipRole."Member Entry No.");
                        ProcessMember(Member, TempMembershipRole, false);
                    until TempMembershipRole.Next() = 0;
        end;
        Commit();
    end;

    local procedure ProcessMember(Member: Record "NPR MM Member"; MembershipRole: Record "NPR MM Membership Role"; MemberDeleted: Boolean)
    var
        HLMember: Record "NPR HL HeyLoyalty Member";
    begin
        if not UpdateHLMember(Member, MembershipRole, MemberDeleted, "NPR HL Auto Create HL Member"::Eligible, HLMember) then
            exit;
        ScheduleHLMemberProcessing(HLMember, not MemberIsEligibleForSubscription(Member, MembershipRole, false), CurrentDateTime());
    end;

    procedure ScheduleHLMemberProcessing(HLMember: Record "NPR HL HeyLoyalty Member"; NotBeforeDateTime: DateTime)
    begin
        ScheduleHLMemberProcessing(HLMember, false, NotBeforeDateTime);
    end;

    procedure ScheduleHLMemberProcessing(HLMember: Record "NPR HL HeyLoyalty Member"; Unsubscribe: Boolean; NotBeforeDateTime: DateTime)
    var
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR HL Schedule Send Tasks";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(HLMember);

        clear(NcTask);
        if Unsubscribe or HLMember.Deleted or HLMember.Anonymized then
            NcTask.Type := NcTask.Type::Delete
        else
            NcTask.Type := NcTask.Type::Modify;

        if SpfyScheduleSend.InitNcTask(RecRef, Format(HLMember."Entry No."), NcTask.Type, NcTask, false) then
            SpfyScheduleSend.Enqueue(NcTask, NotBeforeDateTime);

        //Create a second 'Delete' request
        if HLMember.Deleted or HLMember.Anonymized then
            if SpfyScheduleSend.InitNcTask(RecRef, Format(HLMember."Entry No."), NcTask.Type, NcTask, true) then
                SpfyScheduleSend.Enqueue(NcTask, NotBeforeDateTime);
    end;

    local procedure FindMember(DataLogEntry: Record "NPR Data Log Record"; var MemberOut: Record "NPR MM Member"; var MembershipRoleOut: Record "NPR MM Membership Role"): Boolean
    var
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        DataLogSubscriberMgt: Codeunit "NPR Data Log Sub. Mgt.";
        RecRef: RecordRef;
        ProcessRec: Boolean;
    begin
        RecRef := DataLogEntry."Record ID".GetRecord();
        RecRef.SetTable(Member);
        if not FindMembershipRole(Member, MembershipRole) then
            Clear(MembershipRole);
        ProcessRec := Member.Find() and TestRequiredFields(Member, MembershipRole, false);

        if not ProcessRec and (DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Delete) then
            if DataLogSubscriberMgt.RestoreRecordToRecRef(DataLogEntry."Entry No.", true, RecRef) then begin
                RecRef.SetTable(Member);
                ProcessRec := TestRequiredFields(Member, MembershipRoleOut, false);
            end;

        MemberOut := Member;
        MembershipRoleOut := MembershipRole;
        exit(ProcessRec);
    end;

    local procedure FindRelatedMembers(DataLogEntry: Record "NPR Data Log Record"; var TempMembershipRole: Record "NPR MM Membership Role"): Boolean
    var
        GDPRConsentLog: Record "NPR GDPR Consent Log";
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipRole2: Record "NPR MM Membership Role";
        DataLogSubscriberMgt: Codeunit "NPR Data Log Sub. Mgt.";
        RecRef: RecordRef;
        Handled: Boolean;
    begin
        if not TempMembershipRole.IsTemporary() then
            HLIntegrationMgt.NonTempParameterError();

        TempMembershipRole.Reset();
        TempMembershipRole.DeleteAll();

        HLIntegrationEvents.OnBeforeFindRelatedMembers(DataLogEntry, TempMembershipRole, Handled);
        if not Handled then begin
            case DataLogEntry."Table ID" of
                Database::"NPR MM Membership":
                    begin
                        RecRef := DataLogEntry."Record ID".GetRecord();
                        RecRef.SetTable(Membership);
                        if Membership.Find() then begin
                            MembershipRole.SetRange("Membership Entry No.", Membership."Entry No.");
                            if FindMembershipRole(MembershipRole, MembershipRole2) then
                                TouchMember(MembershipRole2, TempMembershipRole);
                        end;
                    end;
                Database::"NPR MM Membership Role":
                    begin
                        RecRef := DataLogEntry."Record ID".GetRecord();
                        RecRef.SetTable(MembershipRole);
                        if MembershipRole.Find() then
                            TouchMember(MembershipRole, TempMembershipRole);
                    end;
                Database::"NPR GDPR Consent Log":
                    if DataLogSubscriberMgt.RestoreRecordToRecRef(DataLogEntry."Entry No.", false, RecRef) then begin
                        RecRef.SetTable(GDPRConsentLog);
                        MembershipRole.SetRange("GDPR Agreement No.", GDPRConsentLog."Agreement No.");
                        MembershipRole.SetRange("GDPR Data Subject Id", GDPRConsentLog."Data Subject Id");
                        if FindMembershipRole(MembershipRole, MembershipRole2) then
                            TouchMember(MembershipRole2, TempMembershipRole);
                    end;
            end;
            HLIntegrationEvents.OnFindRelatedMembers(DataLogEntry, TempMembershipRole, Handled);
        end;

        exit(TempMembershipRole.FindSet());
    end;

    local procedure FindMembershipRole(var FilteredMembershipRoles: Record "NPR MM Membership Role"; var MembershipRoleOut: Record "NPR MM Membership Role"): Boolean
    var
        Found: Boolean;
    begin
        Clear(MembershipRoleOut);
        if not FilteredMembershipRoles.Find('-') then
            exit(false);

        Found := false;
        repeat
            Found := not FilteredMembershipRoles.Blocked;
            if Found then
                MembershipRoleOut := FilteredMembershipRoles;
        until Found or (FilteredMembershipRoles.Next(-1) = 0);
        if not Found then
            MembershipRoleOut := FilteredMembershipRoles;

        exit(true);
    end;

    local procedure TouchMember(MembershipRole: Record "NPR MM Membership Role"; var TempMembershipRole: Record "NPR MM Membership Role")
    var
        Member: Record "NPR MM Member";
    begin
        if not Member.get(MembershipRole."Member Entry No.") then
            exit;
        TempMembershipRole.SetCurrentKey("Member Entry No.");
        TempMembershipRole.SetRange("Member Entry No.", Member."Entry No.");
        if not TempMembershipRole.IsEmpty() then
            exit;
        TempMembershipRole := MembershipRole;
        if TempMembershipRole.Find() then
            exit;
        if TestRequiredFields(Member, MembershipRole, false) then
            TempMembershipRole.Insert();
    end;

    procedure TestRequiredFields(Member: Record "NPR MM Member"; MembershipRole: Record "NPR MM Membership Role"; WithError: Boolean): Boolean
    var
        HLMember: Record "NPR HL HeyLoyalty Member";
    begin
        if not GetHLMember(Member, MembershipRole, HLMember, "NPR HL Auto Create HL Member"::Never) then begin
            if not MemberIsEligibleForSubscription(Member, MembershipRole, false) then
                exit(false);
            Clear(HLMember);
        end;

        if WithError then begin
            Member.TestField("E-Mail Address");
            HLMember.TestField("Unsubscribed at", 0DT);
            exit(true);
        end;

        exit(
            (Member."E-Mail Address" <> '') and
            (HLMember."Unsubscribed at" = 0DT));
    end;

    procedure MemberIsEligibleForSubscription(Member: Record "NPR MM Member"; MembershipRole: Record "NPR MM Membership Role"; WithError: Boolean): Boolean
    var
        Membership: Record "NPR MM Membership";
    begin
        MembershipRole.CalcFields("GDPR Approval");
        if not Membership.Get(MembershipRole."Membership Entry No.") then
            Clear(Membership);

        if WithError then begin
            Member.TestField(Blocked, false);
            Membership.TestField(Blocked, false);
            MembershipRole.TestField(Blocked, false);
            MembershipRole.TestField("GDPR Approval", MembershipRole."GDPR Approval"::ACCEPTED);
            exit(true);
        end;

        exit(
            not (
                Member.Blocked or
                Membership.Blocked or
                MembershipRole.Blocked or
                (MembershipRole."GDPR Approval" <> MembershipRole."GDPR Approval"::ACCEPTED)));
    end;

    procedure UpdateHLMember(Member: Record "NPR MM Member"; MembershipRole: Record "NPR MM Membership Role"; var HLMember: Record "NPR HL HeyLoyalty Member"): Boolean
    begin
        exit(UpdateHLMember(Member, MembershipRole, false, "NPR HL Auto Create HL Member"::Always, HLMember));
    end;

    procedure UpdateHLMember(Member: Record "NPR MM Member"; MembershipRole: Record "NPR MM Membership Role"; MemberDeleted: Boolean; AutoInsert: Enum "NPR HL Auto Create HL Member"; var HLMember: Record "NPR HL HeyLoyalty Member"): Boolean
    var
        Membership: Record "NPR MM Membership";
        xHLMember: Record "NPR HL HeyLoyalty Member";
        AttributeMgt: Codeunit "NPR HL Attribute Mgt.";
        MemberAnonymized: Boolean;
        Updated: Boolean;
    begin
        MemberAnonymized := MemberIsAnonymized(Member);
        if MemberDeleted or MemberAnonymized then
            AutoInsert := AutoInsert::Never;
        if not GetHLMember(Member, MembershipRole, HLMember, AutoInsert) then
            exit(false);
        xHLMember := HLMember;
        if not Membership.Get(MembershipRole."Membership Entry No.") then
            Clear(Membership);

        HLMember."First Name" := Member."First Name";
        HLMember."Middle Name" := Member."Middle Name";
        HLMember."Last Name" := Member."Last Name";
        HLMember.Gender := Member.Gender;
        HLMember.Birthday := Member.Birthday;
        HLMember."E-Mail Address" := Member."E-Mail Address";
        HLMember."Phone No." := Member."Phone No.";
        HLMember.Address := Member.Address;
        HLMember.City := Member.City;
        HLMember."Post Code Code" := Member."Post Code Code";
        HLMember."Country Code" := Member."Country Code";
        HLMember."Member Created Datetime" := Member."Created Datetime";
        HLMember.Deleted := MemberDeleted;
        HLMember.Anonymized := MemberAnonymized;

        HLMember."Membership Entry No." := Membership."Entry No.";
        HLMember."Membership Code" := Membership."Membership Code";
        HLMember."HL Membership Name" := GetMembershipHLName(HLMember."Membership Code");

        if HLMember."Unsubscribed at" = 0DT then
            if HLMember.Deleted or HLMember.Anonymized or not MemberIsEligibleForSubscription(Member, MembershipRole, false) then
                HLMember."Unsubscribed at" := CurrentDateTime();

        Updated := AttributeMgt.UpdateHLMemberAttributesFromMember(HLMember);

        HLIntegrationEvents.OnUpdateHLMember(Member, MemberDeleted, HLMember);

        if format(xHLMember) <> format(HLMember) then begin
            Updated := true;
            HLMember.Modify(true);
        end;
        exit(Updated);
    end;

    procedure GetHLMember(Member: Record "NPR MM Member"; MembershipRole: Record "NPR MM Membership Role"; var HLMember: Record "NPR HL HeyLoyalty Member"; AutoInsert: Enum "NPR HL Auto Create HL Member"): Boolean
    begin
        Member.TestField("Entry No.");
        HLMember.SetCurrentKey("Member Entry No.");
        HLMember.SetRange("Member Entry No.", Member."Entry No.");
        if not HLMember.FindLast() then begin
            case AutoInsert of
                AutoInsert::Never:
                    begin
                        Clear(HLMember);
                        exit(false);
                    end;
                AutoInsert::Eligible:
                    if not MemberIsEligibleForSubscription(Member, MembershipRole, false) then
                        exit(false);
            end;

            HLMember.Init();
            HLMember."Entry No." := 0;
            HLMember."Member Entry No." := Member."Entry No.";
            HLMember."Membership Entry No." := MembershipRole."Membership Entry No.";
            HLMember.Insert(true);
        end;
        exit(true);
    end;

    procedure UpdateHLMemberWithDataFromHeyLoyalty(var HLMember: Record "NPR HL HeyLoyalty Member"; HLMemberJToken: JsonToken; OnlyEssentialFields: Boolean) Updated: Boolean
    var
        xHLMember: Record "NPR HL HeyLoyalty Member";
        MembershipSetup: Record "NPR MM Membership Setup";
        UpsertMemberBatch: Codeunit "NPR HL Upsert Member Batch";
        HLMemberFieldsJToken: JsonToken;
        ResponseFieldNames: List of [Text];
        HLCountryID: Text;
        MembershipHLFieldID: Text[50];
        ResponseFieldName: Text;
        AttributeUpdated: Boolean;
    begin
        xHLMember := HLMember;
        xHLMember.Find();

        if HLMemberJToken.AsObject().Keys().Count() > 0 then begin
            GetHLEssentialFieldValues(HLMember, HLMemberJToken, true);

            if not OnlyEssentialFields then begin
                if HLMemberJToken.SelectToken('fields', HLMemberFieldsJToken) then begin
                    MembershipHLFieldID := HLIntegrationMgt.HLMembershipCodeFieldID();
                    ResponseFieldNames := HLMemberFieldsJToken.AsObject().Keys();
                    foreach ResponseFieldName in ResponseFieldNames do begin
                        case ResponseFieldName of
                            'email', 'mobile':
                                ;
                            'firstname':
#pragma warning disable AA0139
                                HLMember."First Name" := JsonHelper.GetJText(HLMemberJToken, 'fields.firstname.value', MaxStrLen(HLMember."First Name"), false);
                            'lastname':
                                HLMember."Last Name" := JsonHelper.GetJText(HLMemberJToken, 'fields.lastname.value', MaxStrLen(HLMember."Last Name"), false);
#pragma warning restore
                            'birthdate':
                                HLMember.Birthday := JsonHelper.GetJDate(HLMemberJToken, 'fields.birthdate.value', false);
                            'sex':
                                Case JsonHelper.GetJText(HLMemberJToken, 'fields.sex.value', false) of
                                    '1':
                                        HLMember.Gender := HLMember.Gender::MALE;
                                    '2':
                                        HLMember.Gender := HLMember.Gender::FEMALE;
                                end;
                            'address':
#pragma warning disable AA0139
                                HLMember.Address := JsonHelper.GetJText(HLMemberJToken, 'fields.address.value', MaxStrLen(HLMember.Address), false);
                            'postalcode':
                                HLMember."Post Code Code" := JsonHelper.GetJText(HLMemberJToken, 'fields.postalcode.value', MaxStrLen(HLMember."Post Code Code"), false);
                            'city':
                                HLMember.City := JsonHelper.GetJText(HLMemberJToken, 'fields.city.value', MaxStrLen(HLMember.City), false);
#pragma warning restore
                            'country':
                                begin
                                    HLCountryID := JsonHelper.GetJText(HLMemberJToken, 'fields.country.value', false);
                                    HLMember."HL Country ID" := CopyStr(HLCountryID, 1, MaxStrLen(HLMember."HL Country ID"));
#pragma warning disable AA0139
                                    HLMember."HL Country Name" := JsonHelper.GetJText(HLMemberJToken, StrSubstNo('fields.country.options.%1', HLCountryID), MaxStrLen(HLMember."HL Country Name"), false);
#pragma warning restore
                                    HLMember."Country Code" := HLMember.FindCountryCode();
                                end;
                            MembershipHLFieldID:
                                begin
#pragma warning disable AA0139
                                    HLMember."HL Membership Name" :=
                                        JsonHelper.GetJText(HLMemberJToken, StrSubstNo('fields.%1.value', HLIntegrationMgt.HLMembershipCodeFieldID()), MaxStrLen(HLMember."HL Membership Name"), false);
#pragma warning restore
                                    MembershipSetup.SetRange("HeyLoyalty Name", HLMember."HL Membership Name");
                                    if MembershipSetup.FindFirst() then begin
                                        HLMember."Membership Code" := MembershipSetup.Code;
                                        HLMember."HL Membership Name" := MembershipSetup."HeyLoyalty Name";
                                    end;
                                end;
                            else
                                AttributeUpdated := ParseAttribute(HLMember, HLMemberJToken, ResponseFieldName) or AttributeUpdated;
                        end;
                        HLIntegrationEvents.OnReadHLResponseField_OnUpdateHLMember(HLMember, ResponseFieldName, HLMemberJToken);
                    end;
                end;

                if HLMember."Member Created Datetime" = 0DT then
                    HLMember."Member Created Datetime" := JsonHelper.GetJDT(HLMemberJToken, 'created_at', true);
            end;
        end;

        HLIntegrationEvents.OnUpdateHLMemberWithDataFromHeyLoyalty(HLMember, HLMemberJToken, OnlyEssentialFields);

        if (Format(xHLMember) <> Format(HLMember)) or AttributeUpdated then begin
            HLMember.Modify();
            Updated := true;
            if BCMemberUpdateIsRequired(xHLMember, HLMember) or AttributeUpdated then begin
                Commit();
                UpsertMemberBatch.UpsertOne(HLMember);
            end;
        end;
    end;

    local procedure ParseAttribute(var HLMember: Record "NPR HL HeyLoyalty Member"; var HLMemberJToken: JsonToken; ResponseFieldName: Text): Boolean
    var
        AttributeMgt: Codeunit "NPR HL Attribute Mgt.";
        AttributeJToken: JsonToken;
        AttributeValue: Text;
    begin
        if not HLMemberJToken.SelectToken(StrSubstNo('fields.%1', ResponseFieldName), AttributeJToken) then
            exit(false);
        AttributeValue := JsonHelper.GetJText(AttributeJToken, 'value', false);
        if AttributeValue = '' then
            exit(false);
        exit(AttributeMgt.UpdateHLMemberAttributeFromHL(HLMember, ResponseFieldName, AttributeValue, JsonHelper.GetJText(AttributeJToken, StrSubstNo('options.%1', AttributeValue), false)));
    end;

    procedure GetHLEssentialFieldValues(var HLMember: Record "NPR HL HeyLoyalty Member"; HLMemberJToken: JsonToken; Mandatory: Boolean)
    begin
        HLMember."HeyLoyalty Id" := GetHeyLoyaltyIDFromResponse(HLMemberJToken, HLMember."HeyLoyalty Id");
        HLMember."E-Mail Address" := GetEmailFromResponse(HLMemberJToken, Mandatory, HLMember."E-Mail Address");
#pragma warning disable AA0139
        HLMember."Phone No." := JsonHelper.GetJText(HLMemberJToken, 'fields.mobile.value', MaxStrLen(HLMember."Phone No."), false, HLMember."Phone No.");

        HLMember."HL Member Status" := LowerCase(JsonHelper.GetJText(HLMemberJToken, 'status.status', MaxStrLen(HLMember."HL Member Status"), false, HLMember."HL Member Status"));
#pragma warning restore
        case LowerCase(JsonHelper.GetJText(HLMemberJToken, 'status.email', false)) of
            '', 'active', 'null':
                HLMember."HL E-mail Status" := HLMember."HL E-mail Status"::Active;
            'complaint':
                HLMember."HL E-mail Status" := HLMember."HL E-mail Status"::"Spam Complaint";
            'hard_bounce':
                HLMember."HL E-mail Status" := HLMember."HL E-mail Status"::"Hard Bounce";
            else
                HLMember."HL E-mail Status" := HLMember."HL E-mail Status"::" ";
        end;
        HLMember."Unsubscribed at" := GetUnsubscribedAtFromResponse(HLMemberJToken, HLMember."Unsubscribed at");
    end;

    procedure GetHeyLoyaltyIDFromResponse(HeyLoyaltyResponse: JsonToken; DefaultID: Text[50]): Text[50]
    var
        HeyLoyaltyId: Text;
    begin
        HeyLoyaltyId := JsonHelper.GetJText(HeyLoyaltyResponse, 'id', DefaultID = '', DefaultID);
        CheckHeyLoyaltyIdMaxLength(HeyLoyaltyId);
        exit(CopyStr(HeyLoyaltyId, 1, 50));
    end;

    procedure GetEmailFromResponse(HeyLoyaltyResponse: JsonToken; Mandatory: Boolean; DefaultEmail: Text[80]): Text[80]
    begin
#pragma warning disable AA0139
        exit(JsonHelper.GetJText(HeyLoyaltyResponse, 'fields.email.value', 80, Mandatory and (DefaultEmail = ''), DefaultEmail));
#pragma warning restore
    end;

    procedure GetUnsubscribedAtFromResponse(HeyLoyaltyResponse: JsonToken; DefaultValue: DateTime): DateTime
    begin
        exit(JsonHelper.GetJDT(HeyLoyaltyResponse, 'unsubscribed_at', false, DefaultValue));
    end;

    local procedure BCMemberUpdateIsRequired(xHLMember: Record "NPR HL HeyLoyalty Member"; HLMember: Record "NPR HL HeyLoyalty Member"): Boolean
    var
        UpdatedIsRequired: Boolean;
    begin
        if HLMember.Deleted then
            exit(false);

        UpdatedIsRequired :=
            (xHLMember."First Name" <> HLMember."First Name") or
            (xHLMember."Middle Name" <> HLMember."Middle Name") or
            (xHLMember."Last Name" <> HLMember."Last Name") or
            (xHLMember.Gender <> HLMember.Gender) or
            (xHLMember.Birthday <> HLMember.Birthday) or
            (xHLMember."E-Mail Address" <> HLMember."E-Mail Address") or
            (xHLMember."Phone No." <> HLMember."Phone No.") or
            (xHLMember.Address <> HLMember.Address) or
            (xHLMember."Post Code Code" <> HLMember."Post Code Code") or
            (xHLMember.City <> HLMember.City) or
            (xHLMember."Country Code" <> HLMember."Country Code") or
            (xHLMember."Member Created Datetime" <> HLMember."Member Created Datetime") or
            (xHLMember."Unsubscribed at" <> HLMember."Unsubscribed at");

        HLIntegrationEvents.OnCheckIfBCMemberUpdateIsRequired(xHLMember, HLMember, UpdatedIsRequired);

        exit(UpdatedIsRequired);
    end;

    local procedure UpdateDataLogSubscriber(DataLogEntry: Record "NPR Data Log Record")
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        HLDataLogSubscrMgt: Codeunit "NPR HL Data Log Subscr. Mgt.";
    begin
        DataLogSubscriber.LockTable();
        if DataLogSubscriber.Get(HLDataLogSubscrMgt.GetSubscriberCode(DataLogEntry."Table ID", CurrCodeunitId()), DataLogEntry."Table ID", '') then
            if DataLogSubscriber."Last Log Entry No." < DataLogEntry."Entry No." then begin
                DataLogSubscriber."Last Log Entry No." := DataLogEntry."Entry No.";
                DataLogSubscriber."Last Date Modified" := CurrentDateTime;
                DataLogSubscriber.Modify(true);
            end;
        Commit();
    end;

    procedure FindMembershipRole(Member: Record "NPR MM Member"; var MembershipRole: Record "NPR MM Membership Role"): Boolean
    var
        Membership: Record "NPR MM Membership";
    begin
        Clear(MembershipRole);
        MembershipRole.SetRange("Member Entry No.", Member."Entry No.");
        MembershipRole.SetRange(Blocked, false);
        if MembershipRole.Find('-') then
            repeat
                if Membership.Get(MembershipRole."Membership Entry No.") and (not Membership.Blocked) then
                    exit(true);
            until MembershipRole.Next() = 0;

        MembershipRole.SetRange(Blocked);
        if MembershipRole.Find('+') then
            repeat
                if Membership.Get(MembershipRole."Membership Entry No.") then
                    exit(true);
            until MembershipRole.Next(-1) = 0;

        exit(false);
    end;

    procedure GetMembershipHLName(MembershipCode: Code[20]): Text[50]
    var
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        if not MembershipSetup.Get(MembershipCode) then
            Clear(MembershipSetup);
        exit(MembershipSetup."HeyLoyalty Name");
    end;

    local procedure MemberIsAnonymized(Member: Record "NPR MM Member"): Boolean
    begin
        exit(
            Member.Blocked and
            (Member."Block Reason" = Member."Block Reason"::ANONYMIZED)
        );
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR HL Member Mgt.");
    end;

    procedure CheckHeyLoyaltyIdMaxLength(HeyLoyaltyId: Text)
    var
        TooLongIDErr: Label 'Error reading HeyLoyalty ID "%1". Maximum allowed length for a HeyLoyalty ID is %2 characters.', Comment = '%1 - HeyLoyalty ID; %2 - Maximum number of characters';
    begin
        if StrLen(HeyLoyaltyId) > 50 then
            Error(TooLongIDErr, HeyLoyaltyId, 50);
    end;

    procedure DoInitialSync(var Member: Record "NPR MM Member"; WithDialog: Boolean)
    var
        HLMember: Record "NPR HL HeyLoyalty Member";
        MembershipRole: Record "NPR MM Membership Role";
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
        ConfirmQst: Label 'The function will reset all member synchronization between BC and HeyLoyalty. System will go through members in BC and send synchronization request for each of them to HeyLoyalty.\The process might take significant amount of time to complete. Are you sure you want to continue?';
        DoneLbl: Label 'Done. Sync. requests created for %1 member(s)';
        WindowTextLbl1: Label 'Creating member sync. requests...\\';
        WindowTextLbl2: Label 'Member record #1###### of #2######';
    begin
        if WithDialog then begin
            if not Confirm(ConfirmQst, false) then
                exit;
            Window.Open(
                WindowTextLbl1 +
                WindowTextLbl2);
            RecNo := 0;
            TotalRecNo := Member.Count();
            Window.Update(2, TotalRecNo);
        end;

        if Member.FindSet() then
            repeat
                if WithDialog then begin
                    RecNo += 1;
                    Window.Update(1, RecNo);
                end;

                Clear(HLMember);
                if Member."E-Mail Address" <> '' then
                    if FindMembershipRole(Member, MembershipRole) then
                        if UpdateHLMember(Member, MembershipRole, false, "NPR HL Auto Create HL Member"::Eligible, HLMember) or
                           ((HLMember."Member Entry No." = Member."Entry No.") and (HLMember."HeyLoyalty Id" = ''))
                        then begin
                            ScheduleHLMemberProcessing(HLMember, not MemberIsEligibleForSubscription(Member, MembershipRole, false), CurrentDateTime());
                            Commit();
                        end;
            until Member.Next() = 0;

        if WithDialog then begin
            Window.Close();
            Message(DoneLbl, TotalRecNo);
        end;
    end;
}