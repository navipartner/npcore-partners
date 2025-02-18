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

        WorkflowConfig.AddLabel('InputReferenceNoTitle', InputTxt);
        WorkflowConfig.AddLabel('InputReferenceNo', InputTxtDescrTxt);
        WorkflowConfig.AddLabel('Welcome', WelcomeMsg);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'validate_reference':
                FrontEnd.WorkflowResponse(OnActionValidateReference(Context));
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
'let main = async ({workflow , context, popup, captions}) => {windowTitle = captions.Welcome; context.input_reference_no = await popup.input({ title: captions.InputReferenceNoTitle, caption: captions.InputReferenceNo });if (context.input_reference_no === null) return;const actionResponse = await workflow.respond("validate_reference");if (actionResponse.success) {toast.success (`Welcome ${actionResponse.table_capt} ${actionResponse.reference_no}`, {title: windowTitle});}};'
);
    end;

    local procedure OnActionValidateReference(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        ReferenceNo: Text[100];
        AdmissionCodeParam: Code[20];
        ScannerIdParam: Code[10];
        AdmitToken: Guid;
        ReasonMessage: Text;
    begin
        ReferenceNo := CopyStr(Context.GetString('input_reference_no'), 1, MaxStrLen(ReferenceNo));
        if ReferenceNo = '' then
            exit;

        AdmissionCodeParam := CopyStr(Context.GetStringParameter(AdmissionCodeParamName()), 1, MaxStrLen(AdmissionCodeParam));
        ScannerIdParam := CopyStr(Context.GetStringParameter(ScannerIdParamName()), 1, MaxStrLen(ScannerIdParam));

        AdmitToken := SpeedGate.CreateAdmitToken(ReferenceNo, AdmissionCodeParam, ScannerIdParam);
        Commit();

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
        MMMemberCard: Record "NPR MM Member Card";
    begin
        if EanBoxSetupEvent."Event Code" <> ActionCode() then
            exit;
        if StrLen(EanBoxValue) > MaxStrLen(MMMemberCard."External Card No.") then
            exit;
        if GetTableCaption(EanBoxValue) <> '' then
            Inscope := true;
    end;

    var
        AdmissionCodeLbl: Label 'Admission Code';
        AdmissionCodeDescLbl: Label 'Admission Code to be sent to SpeedGate';
        ScannerIdLbl: Label 'Scanner ID';
        ScannerIdDescLbl: Label 'Scanner ID Parameter';
        WelcomeMsg: Label 'Welcome';
}