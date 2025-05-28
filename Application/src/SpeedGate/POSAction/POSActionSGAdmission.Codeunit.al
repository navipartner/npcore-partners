codeunit 6248278 "NPR POS Action SG Admission" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        InputTxt: Label 'SpeedGate Admission';
        InputTxtDescrTxt: Label 'Input Reference No. Ticket/Member';
        QtyToAdmitLbl: Label 'Quantity to Admit';

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(InputTxt);
        WorkflowConfig.AddTextParameter(AdmissionCodeParamName(), '', AdmissionCodeLbl, AdmissionCodeDescLbl);
        WorkflowConfig.AddTextParameter(ScannerIdParamName(), '', ScannerIdLbl, ScannerIdDescLbl);
        WorkflowConfig.AddTextParameter('input_reference_no', '', InputTxt, InputTxtDescrTxt);
        WorkflowConfig.AddLabel('InputReferenceNoTitle', InputTxt);
        WorkflowConfig.AddLabel('InputReferenceNo', InputTxtDescrTxt);
        WorkflowConfig.AddLabel('Welcome', WelcomeMsg);
        WorkflowConfig.AddLabel('QuantityAdmitLbl', QtyToAdmitLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        ReferenceNo: Text[100];
    begin
        case Step of
            'try_admit':
                FrontEnd.WorkflowResponse(TryAdmitToken(Context, Setup.GetPOSUnitNo(), ReferenceNo));
            'admit_token':
                FrontEnd.WorkflowResponse(OnActionAdmit(Context));
            'membercard_validation':
                FrontEnd.WorkflowResponse(OnActionMemberCardValidation(Context));
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:SpeedGateAdmission.js###
'let main=async({workflow:a,parameters:r,context:n,popup:m,captions:i})=>{let e;if(windowTitle=i.Welcome,r.input_reference_no)n.input_reference_no=r.input_reference_no;else if(n.input_reference_no=await m.input({title:i.InputReferenceNoTitle,caption:i.InputReferenceNo}),!n.input_reference_no)return;const d=await a.respond("try_admit");d.isUnconfirmedGroup?n.quantityToAdmUnconfirmedGroup=await m.numpad({caption:i.QuantityAdmitLbl,title:i.QuantityAdmitLbl,value:d.defaultQuantity}):n.quantityToAdmUnconfirmedGroup=0;const t=await a.respond("admit_token");e=await a.respond("membercard_validation"),t.success&&(e.MemberScanned?toast.memberScanned({memberImg:e.MemberScanned.ImageDataUrl,memberName:e.MemberScanned.Name,validForAdmission:e.MemberScanned.Valid,memberExpiry:e.MemberScanned.ExpiryDate}):t.confirmedGroup?toast.success(`Welcome group of ${t.qtyToAdmit} people`,{title:windowTitle}):toast.success(`Welcome ${t.table_capt} ${t.reference_no}`,{title:windowTitle}))};'
);
    end;

    local procedure TryAdmitToken(Context: Codeunit "NPR POS JSON Helper"; POSUnitNo: Code[10]; var ReferenceNo: Text[100]) Response: JsonObject
    var
        ValidationRequest: Record "NPR SGEntryLog";
        DetAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        Ticket: Record "NPR TM Ticket";
        AccessEntry: Record "NPR TM Ticket Access Entry";
        AdmitToken: Guid;
        BlankGuid: Guid;
        AdmissionCodeParam: Code[20];
        ScannerIdParam: Code[10];
        AdmitCount: Integer;
        GroupQuantity: Integer;
        ConfirmedGroup: Boolean;
        UnconfirmedGroup: Boolean;
        IsGroup: Boolean;
    begin
        ReferenceNo := CopyStr(Context.GetString('input_reference_no'), 1, MaxStrLen(ReferenceNo));
        if ReferenceNo = '' then
            exit;

        AdmissionCodeParam := CopyStr(Context.GetStringParameter(AdmissionCodeParamName()), 1, MaxStrLen(AdmissionCodeParam));
        ScannerIdParam := CopyStr(Context.GetStringParameter(ScannerIdParamName()), 1, MaxStrLen(ScannerIdParam));

        if (ScannerIdParam = '') then
            ScannerIdParam := POSUnitNo;

        CreateAdmitToken(ReferenceNo, AdmissionCodeParam, ScannerIdParam, AdmitToken);

        if AdmitToken <> BlankGuid then begin
            ValidationRequest.SetCurrentKey(Token);
            ValidationRequest.SetFilter(Token, '=%1', AdmitToken);
            if ValidationRequest.FindFirst() then
                if (Ticket.GetBySystemId(ValidationRequest.EntityId)) then begin
                    AccessEntry.SetCurrentKey("Ticket No.");
                    AccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                    AccessEntry.SetFilter("Admission Code", '=%1', ValidationRequest.AdmissionCode);
                    if AccessEntry.FindFirst() then begin
                        DetAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', AccessEntry."Entry No.");
                        DetAccessEntry.SetFilter(Type, '=%1', DetAccessEntry.Type::ADMITTED);
                        DetAccessEntry.SetFilter(Quantity, '>%1', 0);
                        AdmitCount := DetAccessEntry.Count;
                        GroupQuantity := AccessEntry.Quantity;
                        if (GroupQuantity > 1) then begin
                            IsGroup := true;
                            if (AdmitCount > 0) then
                                ConfirmedGroup := true
                            else
                                UnconfirmedGroup := true;
                        end;
                    end;
                end;
        end;
        Response.Add('isUnconfirmedGroup', UnconfirmedGroup);
        Response.Add('defaultQuantity', ValidationRequest.SuggestedQuantity);

        Context.SetContext('token', AdmitToken);
        Context.SetContext('suggestedQty', ValidationRequest.SuggestedQuantity);
        Context.SetContext('confirmedGroup', ConfirmedGroup);
        Context.SetContext('isGroup', IsGroup);
    end;

    local procedure OnActionAdmit(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        AdmitToken: Guid;
        BlankGuid: Guid;
        ReasonMessage: Text;
        ReferenceNo: Text[100];
        ConfirmedGroup: Boolean;
        IsGroup: Boolean;
        SuggestedQuantity: Integer;
        QuantityToAdmitUnconfirmed: Decimal;
        QtyToAdmit: Integer;
    begin
        ReferenceNo := CopyStr(Context.GetString('input_reference_no'), 1, MaxStrLen(ReferenceNo));
        AdmitToken := Context.GetString('token');
        if AdmitToken = BlankGuid then
            exit;

        ConfirmedGroup := Context.GetBoolean('confirmedGroup');
        IsGroup := Context.GetBoolean('isGroup');
        SuggestedQuantity := Context.GetInteger('suggestedQty');
        QuantityToAdmitUnconfirmed := Context.GetInteger('quantityToAdmUnconfirmedGroup');

        if IsGroup then begin
            if ConfirmedGroup then
                QtyToAdmit := SuggestedQuantity
            else
                QtyToAdmit := QuantityToAdmitUnconfirmed;
        end else
            QtyToAdmit := 1;

        if QtyToAdmit = 0 then
            QtyToAdmit := 1;


        if (not SpeedGate.CheckAdmit(AdmitToken, QtyToAdmit, ReasonMessage)) then begin
            Commit(); // commit the transactions log entry before showing the error message
            Error(ReasonMessage);
        end else begin
            Response.Add('success', true);
            Response.Add('reference_no', ReferenceNo);
            Response.Add('table_capt', GetTableCaption(ReferenceNo));
            Response.Add('welcome_message', WelcomeMsg);
            Response.Add('confirmedGroup', ConfirmedGroup);
            Response.Add('qtyToAdmit', QtyToAdmit);
        end;
    end;

    local procedure CreateAdmitToken(ReferenceNo: Text[100]; AdmissionCode: Code[20]; ScannerId: Code[10]; var AdmitToken: Guid): Boolean
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        HaveError: Boolean;
        ErrorMessage: Text;
    begin
        AdmitToken := SpeedGate.CreateAdmitToken(ReferenceNo, AdmissionCode, ScannerId, false, HaveError, ErrorMessage);
        Commit();
        if HaveError then
            exit(false)
        else
            exit(true);
    end;

    local procedure OnActionMemberCardValidation(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        MemberCard: Record "NPR MM Member Card";
        POSActionMemberArrival: Codeunit "NPR POS Action: MM Member ArrB";
        ReferenceNo: Text[100];
    begin
        ReferenceNo := CopyStr(Context.GetString('input_reference_no'), 1, MaxStrLen(ReferenceNo));
        if ReferenceNo = '' then
            exit;

        MemberCard.SetRange("External Card No.", CopyStr(ReferenceNo, 1, MaxStrLen(MemberCard."External Card No.")));
        if not MemberCard.FindFirst() then
            exit;

        POSActionMemberArrival.AddToastMemberScannedData(MemberCard."Entry No.", 0, Response);
    end;

    procedure AdmissionCodeParamName(): Text[30];
    begin
        exit('ADMISSION_CODE');
    end;

    procedure ScannerIdParamName(): Text[30]
    begin
        exit('SCANNER_ID');
    end;

    local procedure GetTableCaption(ReferenceNo: Text): Text
    var
        MemberCard: Record "NPR MM Member Card";
        Ticket: Record "NPR TM Ticket";
        AttractionWallet: Record "NPR AttractionWallet";
        WalletExternalReference: Record "NPR AttractionWalletExtRef";
    begin
        MemberCard.SetRange("External Card No.", CopyStr(ReferenceNo, 1, MaxStrLen(MemberCard."External Card No.")));
        if not MemberCard.IsEmpty() then
            exit(MemberCard.TableCaption);

        Ticket.SetRange("External Ticket No.", CopyStr(ReferenceNo, 1, MaxStrLen(Ticket."External Ticket No.")));
        if not Ticket.IsEmpty() then
            exit(Ticket.TableCaption);

        WalletExternalReference.SetRange(ExternalReference, CopyStr(ReferenceNo, 1, MaxStrLen(WalletExternalReference.ExternalReference)));
        if (not WalletExternalReference.IsEmpty()) then
            exit(AttractionWallet.TableCaption());

        AttractionWallet.SetRange(ReferenceNumber, CopyStr(ReferenceNo, 1, MaxStrLen(AttractionWallet.ReferenceNumber)));
        if not AttractionWallet.IsEmpty() then
            exit(AttractionWallet.TableCaption);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        Text000: Label 'SpeedGate Admission';
    begin
        if not EanBoxEvent.Get(ActionCode()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := ActionCode();
            EanBoxEvent."Module Name" := CopyStr(Text000, 1, MaxStrLen(EanBoxEvent."Module Name"));
            EanBoxEvent.Description := CopyStr(Text000, 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        case EanBoxEvent.Code of
            ActionCode():
                Sender.SetNonEditableParameterValues(EanBoxEvent, 'input_reference_no', true, '');
        end;
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::SPEEDGATE_ADMISSSION));
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR POS Action SG Admission");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, false)]
    local procedure SetEanBoxEventInScope(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        ValidationRequest: Record "NPR SGEntryLog";
        DummyMemberCard: Record "NPR MM Member Card";
        AdmissionCodeParam: Code[20];
        ScannerIdParam: Code[10];
        AdmitToken: Guid;
        BlankGuid: Guid;
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        if EanBoxSetupEvent."Event Code" <> ActionCode() then
            exit;
        // Member Card is the longest value we support
        if StrLen(EanBoxValue) > MaxStrLen(DummyMemberCard."External Card No.") then
            exit;
        if GetTableCaption(EanBoxValue) <> '' then begin
            Inscope := true;
            exit;
        end;

        AdmissionCodeParam := CopyStr(GetParameterValue(EanBoxSetupEvent, 'ADMISSION_CODE'), 1, MaxStrLen(AdmissionCodeParam));
        ScannerIdParam := CopyStr(GetParameterValue(EanBoxSetupEvent, 'SCANNER_ID'), 1, MaxStrLen(ScannerIdParam));

        if (ScannerIdParam = '') then begin
            POSSession.GetSetup(POSSetup);
            ScannerIdParam := POSSetup.GetPOSUnitNo();
        end;

        if CreateAdmitToken(CopyStr(EanBoxValue, 1, 100), AdmissionCodeParam, ScannerIdParam, AdmitToken) then
            InScope := true;

        if AdmitToken <> BlankGuid then begin
            ValidationRequest.SetCurrentKey(Token);
            ValidationRequest.SetFilter(Token, '=%1', AdmitToken);
            if (not ValidationRequest.IsEmpty()) then begin
                ValidationRequest.DeleteAll();
                /**
                 * TODO:
                 * This commit should be removed, in general, we should rewrite this entire section
                 * so we don't do any database operations and instead do a simple "could this number be valid"-function
                 */
                Commit();
            end;
        end;
    end;

    local procedure GetParameterValue(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; ParameterName: Text): Text
    var
        EanBoxParameter: Record "NPR Ean Box Parameter";
    begin
        if not EanBoxParameter.Get(EanBoxSetupEvent."Setup Code", EanBoxSetupEvent."Event Code", EanBoxSetupEvent."Action Code", ParameterName) then
            exit('');

        exit(EanBoxParameter.Value);
    end;

    var
        AdmissionCodeLbl: Label 'Admission Code';
        AdmissionCodeDescLbl: Label 'Admission Code to be sent to SpeedGate';
        ScannerIdLbl: Label 'Scanner ID';
        ScannerIdDescLbl: Label 'Scanner ID Parameter';
        WelcomeMsg: Label 'Welcome';
}