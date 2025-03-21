codeunit 6248278 "NPR POS Action SG Admission" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        InputTxt: Label 'SpeedGate Admission';
        InputTxtDescrTxt: Label 'Input Reference No. Ticket/Member';

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
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        ReferenceNo: Text[100];
    begin
        case Step of
            'try_admit':
                TryAdmitToken(Context, ReferenceNo);
            'admit_token':
                FrontEnd.WorkflowResponse(OnActionAdmit(Context));
            'membercard_validation':
                FrontEnd.WorkflowResponse(OnActionMemberCardValidation(Context));
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSGAdmission.Codeunit.js###
'let main = async ({workflow , parameters, context, popup, captions}) => {let memberCardDetails;windowTitle = captions.Welcome;if (!parameters.input_reference_no) {context.input_reference_no = await popup.input({ title: captions.InputReferenceNoTitle, caption: captions.InputReferenceNo });if (!context.input_reference_no) { return }; } else {context.input_reference_no = parameters.input_reference_no;  }await workflow.respond("try_admit"); const actionResponse = await workflow.respond("admit_token"); memberCardDetails = await workflow.respond("membercard_validation");if (actionResponse.success) {if (memberCardDetails.MemberScanned){toast.memberScanned({memberImg: memberCardDetails.MemberScanned.ImageDataUrl,memberName: memberCardDetails.MemberScanned.Name,validForAdmission: memberCardDetails.MemberScanned.Valid,memberExpiry: memberCardDetails.MemberScanned.ExpiryDate,  });}else{ toast.success (`Welcome ${actionResponse.table_capt} ${actionResponse.reference_no}`, {title: windowTitle}); } }};'
);
    end;

    local procedure TryAdmitToken(Context: Codeunit "NPR POS JSON Helper"; var ReferenceNo: Text[100]): Boolean
    var
        AdmissionCodeParam: Code[20];
        ScannerIdParam: Code[10];
        AdmitToken: Guid;
    begin
        ReferenceNo := CopyStr(Context.GetString('input_reference_no'), 1, MaxStrLen(ReferenceNo));
        if ReferenceNo = '' then
            exit;

        AdmissionCodeParam := CopyStr(Context.GetStringParameter(AdmissionCodeParamName()), 1, MaxStrLen(AdmissionCodeParam));
        ScannerIdParam := CopyStr(Context.GetStringParameter(ScannerIdParamName()), 1, MaxStrLen(ScannerIdParam));
        CreateAdmitToken(ReferenceNo, AdmissionCodeParam, ScannerIdParam, AdmitToken);
        Context.SetContext('token', AdmitToken);
    end;

    local procedure OnActionAdmit(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        AdmitToken: Guid;
        BlankGuid: Guid;
        ReasonMessage: Text;
        ReferenceNo: Text[100];
    begin
        ReferenceNo := CopyStr(Context.GetString('input_reference_no'), 1, MaxStrLen(ReferenceNo));
        AdmitToken := Context.GetString('token');
        if AdmitToken = BlankGuid then
            exit;

        if (not SpeedGate.CheckAdmit(AdmitToken, 1, ReasonMessage)) then begin
            Commit(); // commit the transactions log entry before showing the error message
            Error(ReasonMessage);
        end else begin
            Response.Add('success', true);
            Response.Add('reference_no', ReferenceNo);
            Response.Add('table_capt', GetTableCaption(ReferenceNo));
            Response.Add('welcome_message', WelcomeMsg)
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
    begin
        MemberCard.SetRange("External Card No.", CopyStr(ReferenceNo, 1, MaxStrLen(MemberCard."External Card No.")));
        if not MemberCard.IsEmpty() then
            exit(MemberCard.TableCaption);

        Ticket.SetRange("External Ticket No.", CopyStr(ReferenceNo, 1, MaxStrLen(Ticket."External Ticket No.")));
        if not Ticket.IsEmpty() then
            exit(Ticket.TableCaption);

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
        MMMemberCard: Record "NPR MM Member Card";
        AdmissionCodeParam: Code[20];
        ScannerIdParam: Code[10];
        AdmitToken: Guid;
        BlankGuid: Guid;
    begin
        if EanBoxSetupEvent."Event Code" <> ActionCode() then
            exit;
        if StrLen(EanBoxValue) > MaxStrLen(MMMemberCard."External Card No.") then
            exit;
        if GetTableCaption(EanBoxValue) <> '' then
            Inscope := true;

        AdmissionCodeParam := CopyStr(GetParameterValue(EanBoxSetupEvent, 'ADMISSION_CODE'), 1, MaxStrLen(AdmissionCodeParam));
        ScannerIdParam := CopyStr(GetParameterValue(EanBoxSetupEvent, 'SCANNER_ID'), 1, MaxStrLen(ScannerIdParam));

        if CreateAdmitToken(CopyStr(EanBoxValue, 1, 100), AdmissionCodeParam, ScannerIdParam, AdmitToken) then
            InScope := true;

        if AdmitToken <> BlankGuid then begin
            ValidationRequest.SetCurrentKey(Token);
            ValidationRequest.SetFilter(Token, '=%1', AdmitToken);
            if (not ValidationRequest.IsEmpty()) then
                ValidationRequest.DeleteAll();
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