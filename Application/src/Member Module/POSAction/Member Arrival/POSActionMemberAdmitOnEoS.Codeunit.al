codeunit 6248566 "NPR POSAction MemberAdmitOnEoS" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        _ActionDescription: Label 'Admit Member on End of Sale';

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ToastTitle: Label 'Admitting Member on End of Sale';
        ToastBody: Label 'Admitting Member: %1...';
    begin
        WorkflowConfig.AddActionDescription(_ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('ToastTitle', ToastTitle);
        WorkflowConfig.AddLabel('ToastBody', ToastBody);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'HandleMemberAdmitOnEoS':
                FrontEnd.WorkflowResponse(HandleMemberAdmitOnEoS(Context));
        end;
    end;

    local procedure HandleMemberAdmitOnEoS(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        CustomParameters: JsonObject;
        JsonToken: JsonToken;
        PosUnitNo: Code[10];
        AdmitMethod: Text;
        MemberCards: JsonArray;
        Card: JsonToken;
        MembersAdmittedArray, MembersRejectedArray : JsonArray;
    begin
        CustomParameters := Context.GetJsonObject('customParameters');

        CustomParameters.Get('posUnitNo', JsonToken);
        PosUnitNo := CopyStr(JsonToken.AsValue().AsCode(), 1, MaxStrLen(PosUnitNo));

        CustomParameters.Get('admitMethod', JsonToken);
        AdmitMethod := JsonToken.AsValue().AsText();

        CustomParameters.Get('cardsToAdmit', JsonToken);
        MemberCards := JsonToken.AsArray();

        case AdmitMethod of
            'WORKFLOW_LEGACY':
                foreach Card in MemberCards do
                    AdmitMemberLegacy(Card.AsObject(), PosUnitNo, MembersAdmittedArray, MembersRejectedArray);

            'WORKFLOW_SPEED_GATE':
                AdmitMembersSpeedGate(MemberCards, PosUnitNo, MembersAdmittedArray, MembersRejectedArray);

            'LEGACY':
                ; // Handled in legacy code

            else
                Error('This is a programming error - Invalid admit mode: %1', AdmitMethod);
        end;

        Response.Add('admitMethod', AdmitMethod);
        Response.Add('posUnitNo', PosUnitNo);
        Response.Add('cardsAdmitted', MembersAdmittedArray);
        Response.Add('cardsRejected', MembersRejectedArray);
    end;

    internal procedure GetAdmitMethod(POSUnitNo: Code[10]) AdmitMethod: Enum "NPR MM AdmitMemberOnEoSMethod";
    var
        MemberProfile: Record "NPR MM POS Member Profile";
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.SetLoadFields("POS Member Profile");
        if (not POSUnit.Get(POSUnitNo)) then
            exit(AdmitMethod::LEGACY); // Default

        if (not MemberProfile.Get(POSUnit."POS Member Profile")) then
            exit(AdmitMethod::LEGACY); // Default

        AdmitMethod := MemberProfile.EndOfSaleAdmitMethod;
    end;

    internal procedure GetSpeedgateScannerCode(POSUnitNo: Code[10]) ScannerCode: Code[10];
    var
        MemberProfile: Record "NPR MM POS Member Profile";
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.SetLoadFields("POS Member Profile");
        if (not POSUnit.Get(POSUnitNo)) then
            exit(POSUnitNo); // Default

        MemberProfile.SetAutoCalcFields(ScannerIdForUnitAdmitOnEndSale);
        if (not MemberProfile.Get(POSUnit."POS Member Profile")) then
            exit(POSUnitNo); // Default

        ScannerCode := MemberProfile.ScannerIdForUnitAdmitOnEndSale;
        if (ScannerCode = '') then
            exit(POSUnitNo); // Default

    end;

    internal procedure AdmitMemberLegacy(CardDetails: JsonObject; POSUnitNo: Code[10]; var MembersAdmittedArray: JsonArray; var MembersRejectedArray: JsonArray)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        JToken: JsonToken;
        AdmittedCount: Integer;
        ReasonCode: Integer;
        ReasonText: Text;
    begin

        // extract infoCaptureEntryNo from CardDetails
        CardDetails.Get('infoCaptureEntryNo', JToken);
        MemberInfoCapture.Get(JToken.AsValue().AsInteger());
        MemberInfoCapture.SetRecFilter();

        if (AdmitMembersOnEndOfSalesWorkerLegacy(MemberInfoCapture, AdmittedCount, POSUnitNo, ReasonCode, ReasonText)) then begin
            MembersAdmittedArray.Add(CardDetails);
        end else begin
            CardDetails.Add('reasonCode', ReasonCode);
            CardDetails.Add('reasonText', ReasonText);
            MembersRejectedArray.Add(CardDetails);
        end;

        MemberInfoCapture.Delete();
    end;

    internal procedure AdmitMembersSpeedGate(MemberCards: JsonArray; POSUnitNo: Code[10]; var MembersAdmittedArray: JsonArray; var MembersRejectedArray: JsonArray)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembersTriedArray: JsonArray;
        AdmitToken: Guid;
        Card, EntryNo : JsonToken;
    begin
        foreach Card in MemberCards do
            if (TryMemberCardSpeedGate(Card.AsObject(), PosUnitNo, MembersRejectedArray, AdmitToken)) then begin
                Card.AsObject().Add('admitToken', Format(AdmitToken, 0, 4).toLower());
                MembersTriedArray.Add(Card.AsObject());
            end;

        foreach Card in MembersTriedArray do
            if (AdmitMemberCardSpeedGate(Card.AsObject(), 1, MembersRejectedArray)) then
                MembersAdmittedArray.Add(Card.AsObject());

        foreach Card in MemberCards do
            if (Card.AsObject().Get('infoCaptureEntryNo', EntryNo)) then
                if (MemberInfoCapture.Get(EntryNo.AsValue().AsInteger())) then
                    MemberInfoCapture.Delete();
    end;


    internal procedure TryMemberCardSpeedGate(CardDetails: JsonObject; POSUnitNo: Code[10]; var MembersRejectedArray: JsonArray; var AdmitToken: Guid) Success: Boolean
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        MemberCard: Record "NPR MM Member Card";
        JToken: JsonToken;
        EntryLog: Record "NPR SGEntryLog";
    begin
        // extract cardNo from CardDetails
        CardDetails.Get('cardEntryNo', JToken);
        if (not MemberCard.Get(JToken.AsValue().AsInteger())) then begin
            CardDetails.Add('reasonCode', 1);
            CardDetails.Add('reasonText', StrSubstNo('Member card %1 not found', JToken.AsValue().AsCode()));
            MembersRejectedArray.Add(CardDetails);
            exit;
        end;

        AdmitToken := SpeedGate.CreateAdmitToken(MemberCard."External Card No.", '', GetSpeedgateScannerCode(POSUnitNo));

        EntryLog.SetCurrentKey(Token);
        EntryLog.SetFilter(Token, '=%1', AdmitToken);
        EntryLog.SetFilter(ExtraEntityTableId, '=%1', 0); // Only consider entry created for the member card - not guests);
        Success := (EntryLog.FindFirst());

        if (Success) then begin
            if (EntryLog.EntryStatus <> EntryLog.EntryStatus::PERMITTED_BY_GATE) then
                exit(false);

            // TODO Add guests admitTokens to CardDetails
            // AdmitToken := Speedgate.CreateMemberGuestAdmissionToken(EntryLog, MembershipGuest);
            exit(true);
        end;

        if (not Success) then begin
            CardDetails.Add('reasonCode', 2);
            CardDetails.Add('reasonText', StrSubstNo('Failed to create admit token for member card %1', MemberCard."External Card No."));
            MembersRejectedArray.Add(CardDetails);
            exit(false);
        end;

        SetApiErrorText(EntryLog);
        CardDetails.Add('reasonCode', EntryLog.ApiErrorNumber);
        CardDetails.Add('reasonText', EntryLog.ApiErrorMessage);
        MembersRejectedArray.Add(CardDetails);
        exit(false);
    end;

    internal procedure AdmitMemberCardSpeedGate(CardDetails: JsonObject; Quantity: Integer; var MembersRejectedArray: JsonArray): Boolean
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        EntryLog: Record "NPR SGEntryLog";
        JToken: JsonToken;
        Success: Boolean;
        AdmitToken: Guid;
    begin
        CardDetails.Get('admitToken', JToken);
        Evaluate(AdmitToken, JToken.AsValue().AsText());

        Commit();
        ClearLastError();

        SpeedGate.SetAdmitToken(AdmitToken, Quantity);
        Success := SpeedGate.Run();

        if (Success) then begin
            EntryLog.SetCurrentKey(Token);
            EntryLog.SetFilter(Token, '=%1', AdmitToken);
            EntryLog.SetFilter(ExtraEntityTableId, '=%1', 0); // Only consider entry created for the member card - not guests);
            Success := (EntryLog.FindFirst());
        end;

        if (Success) then begin
            if (EntryLog.EntryStatus = EntryLog.EntryStatus::ADMITTED) then begin
                PrintTicket(EntryLog);
                exit(true);
            end;

            SetApiErrorText(EntryLog);
            CardDetails.Add('reasonCode', EntryLog.ApiErrorNumber);
            CardDetails.Add('reasonText', EntryLog.ApiErrorMessage);
            MembersRejectedArray.Add(CardDetails);
            SpeedGate.MarkAsDenied(AdmitToken, Enum::"NPR API Error Code".FromInteger(EntryLog.ApiErrorNumber), EntryLog.ApiErrorMessage);
            exit(false);
        end;

        CardDetails.Add('reasonCode', 'generic_error');
        CardDetails.Add('reasonText', GetLastErrorText());
        MembersRejectedArray.Add(CardDetails);
        SpeedGate.MarkAsDenied(AdmitToken, Enum::"NPR API Error Code"::generic_error, GetLastErrorText());
        exit(false);
    end;


    local procedure PrintTicket(EntryLog: Record "NPR SGEntryLog")
    var
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        PrintHandler: Codeunit "NPR MM Member Ticket Manager";
        Ticket: Record "NPR TM Ticket";
    begin
        if (EntryLog.EntryStatus <> EntryLog.EntryStatus::ADMITTED) then
            exit;

        if (EntryLog.ReferenceNumberType = EntryLog.ReferenceNumberType::MEMBER_CARD) then
            if (not MemberCard.GetBySystemId(EntryLog.EntityId)) then
                exit;

        if (not Ticket.GetBySystemId(EntryLog.AdmittedReferenceId)) then
            exit;

        Ticket.SetRecFilter();

        Membership.Get(MemberCard."Membership Entry No.");
        MembershipSetup.Get(Membership."Membership Code");
        PrintHandler.PrintTicket(MembershipSetup, Ticket);
    end;

    local procedure SetApiErrorText(var EntryLog: Record "NPR SGEntryLog")
    var
        ApiError: Enum "NPR API Error Code";
    begin
        if (EntryLog.ApiErrorMessage = '') then
            if (EntryLog.ApiErrorNumber <> 0) then begin
                ApiError := Enum::"NPR API Error Code".FromInteger(EntryLog.ApiErrorNumber);
                EntryLog.ApiErrorMessage := CopyStr(Format(ApiError, 0, 1), 1, MaxStrLen(EntryLog.ApiErrorMessage));
            end;
    end;


    internal procedure AddPostEndOfSaleWorkflow(Sale: Codeunit "NPR POS Sale"; var PostWorkflows: JsonObject)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        POSSale: Record "NPR POS Sale";
        ActionParameters, MemberInfo : JsonObject;
        CardsToAdmit: JsonArray;
        CustomerParameters: JsonObject;
        AdmitMethod: Enum "NPR MM AdmitMemberOnEoSMethod";
    begin
        Sale.GetCurrentSale(POSSale);
        AdmitMethod := GetAdmitMethod(POSSale."Register No.");
        if (AdmitMethod = AdmitMethod::LEGACY) then
            exit; // Nothing to do here - handled in legacy code

        MemberInfoCapture.SetCurrentKey("Receipt No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', POSSale."Sales Ticket No.");
        if (not MemberInfoCapture.FindSet()) then
            exit;

        if (not MemberInfoCapture."Auto-Admit Member") then
            exit; // Is consistent for all members on the same sales line

        if (not (MemberInfoCapture."Information Context" in [MemberInfoCapture."Information Context"::NEW,
                                              MemberInfoCapture."Information Context"::RENEW,
                                              MemberInfoCapture."Information Context"::UPGRADE,
                                              MemberInfoCapture."Information Context"::EXTEND])) then
            exit; // Nothing to do

        repeat
            Clear(MemberInfo);
            MemberInfo.Add('cardNo', MemberInfoCapture."External Card No.");
            MemberInfo.Add('cardEntryNo', MemberInfoCapture."Card Entry No.");
            MemberInfo.Add('firstName', MemberInfoCapture."First Name");
            MemberInfo.Add('lastName', MemberInfoCapture."Last Name");
            MemberInfo.Add('infoCaptureEntryNo', MemberInfoCapture."Entry No.");
            CardsToAdmit.Add(MemberInfo);
        until (MemberInfoCapture.Next() = 0);

        CustomerParameters.Add('salesTicketNo', POSSale."Sales Ticket No.");
        CustomerParameters.Add('posUnitNo', POSSale."Register No.");
        CustomerParameters.Add('cardsToAdmit', CardsToAdmit);
        CustomerParameters.Add('admitMethod', AdmitMethod.Names.Get(AdmitMethod.Ordinals.IndexOf(AdmitMethod.AsInteger())));
        ActionParameters.Add('customParameters', CustomerParameters);

        PostWorkflows.Add(Format(Enum::"NPR POS Workflow"::MM_MEMBER_ADMIT_EOS), ActionParameters);
    end;

    internal procedure AdmitMembersOnEndOfSalesWorkerLegacy(var MemberInfoCapture: Record "NPR MM Member Info Capture"; var AdmittedCount: Integer; PosUnitNo: Code[10]; var ReasonCode: Integer; var ReasonText: Text) MemberArrivalOk: Boolean
    var
        MemberCard: Record "NPR MM Member Card";
        AttemptArrival: Codeunit "NPR MM Attempt Member Arrival";
        MemberLimitationMgr: Codeunit "NPR MM Member Lim. Mgr.";
        LogEntryNo: Integer;
    begin
        MemberInfoCapture.FindSet();

        if (not MemberInfoCapture."Auto-Admit Member") then
            exit(true); // Is consistent for all members on the same sales line

        if (not (MemberInfoCapture."Information Context" in [MemberInfoCapture."Information Context"::NEW,
                                              MemberInfoCapture."Information Context"::RENEW,
                                              MemberInfoCapture."Information Context"::UPGRADE,
                                              MemberInfoCapture."Information Context"::EXTEND])) then
            exit(true); // Nothing to do

        // Check that member limitations allow arrival
        repeat
            MemberCard.Get(MemberInfoCapture."Card Entry No.");
            MemberLimitationMgr.POS_CheckLimitMemberCardArrival(MemberCard."External Card No.", '', '<auto>', LogEntryNo, ReasonText, ReasonCode);
            if (ReasonCode <> 0) then
                exit(false);
        until (MemberInfoCapture.Next() = 0);

        // Batch register arrival creating tickets.
        Commit();
        AttemptArrival.AttemptMemberArrival(MemberInfoCapture, '', PosUnitNo, '<auto>');
        MemberArrivalOk := AttemptArrival.Run();

        // Log arrival message. 
        ReasonCode := AttemptArrival.GetAttemptMemberArrivalResponse(ReasonText);
        MemberLimitationMgr.UpdateLogEntry(LogEntryNo, ReasonCode, ReasonText); // TODO: Add LogEntryNo to InfoCapture and update all entries ... 

        AdmittedCount += MemberInfoCapture.Count();
        exit(MemberArrivalOk);

    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionMemberAdmitOnEoS.Codeunit.js### 
'const main=async({workflow:r,captions:e})=>{try{const s=await r.respond("HandleMemberAdmitOnEoS"),{cardsAdmitted:o=[],cardsRejected:a=[]}=s;if(o.length>0&&o.forEach(t=>{t&&typeof t=="object"&&t.cardNo?toast.success(`${t.cardNo}`,{title:`${t.firstName||""} ${t.lastName||""}`}):(console.warn("Missing information in membersAdmitted json:",t),toast.success(`${e.ToastBody.substitute("OK")}`,{title:e.ToastTitle}))}),a.length>0)for(const t of a)toast.error(`${t.reasonCode||"0"} - ${t.reasonText||"There was no error reason specified."} `,{title:e.ToastTitle})}catch(s){toast.error(s.message,{title:e.ToastTitle})}};'
        );
    end;

}