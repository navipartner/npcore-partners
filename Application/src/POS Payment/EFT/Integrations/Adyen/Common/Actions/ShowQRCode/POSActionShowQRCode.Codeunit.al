codeunit 6151113 "NPR POS Action Show QRCode" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescriptionLbl: Label 'This action shows QR Code on POS terminal screen.';
        QRCodeLinkParamCptLbl: Label 'QR Code Link';
        QRCodeLinkParamCptDescLbl: Label 'Specifies the link used to generate QR Code.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddTextParameter('qrCodeLink', '', QRCodeLinkParamCptLbl, QRCodeLinkParamCptDescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'showQRCodeOnTerminal':
                FrontEnd.WorkflowResponse(ShowQRCodeOnTerminal(Context, Sale));
        end;
    end;

    local procedure ShowQRCodeOnTerminal(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"): JsonObject
    var
        SalePOS: Record "NPR POS Sale";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSActionShowQRCodeB: Codeunit "NPR POS Action Show QRCode B";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        POSSession: Codeunit "NPR POS Session";
        Parameters: Dictionary of [Text, Text];
        TaskId: Integer;
        TimeoutIntervalSec: Integer;
        QRCodeSetupCode: Code[20];
    begin
        Sale.GetCurrentSale(SalePOS);
        if not POSActionShowQRCodeB.RequestShowQRCode(SalePOS, EFTTransactionRequest, QRCodeSetupCode, TimeoutIntervalSec) then
            exit;

        Parameters.Add('EntryNo', Format(EFTTransactionRequest."Entry No."));
        Parameters.Add('qrCodeLink', Context.GetStringParameter('qrCodeLink'));
        Parameters.Add('minimumDisplayTimeSec', Format(TimeoutIntervalSec));
        Parameters.Add('RegisterNo', EFTTransactionRequest."Register No.");
        Parameters.Add('ReferenceNumberInput', EFTTransactionRequest."Reference Number Input");
        Parameters.Add('HardwareID', EFTTransactionRequest."Hardware ID");
        Parameters.Add('Mode', Format(EFTTransactionRequest.Mode, 0, 9));
        Parameters.Add('OriginalPOSPaymentTypeCode', EFTTransactionRequest."Original POS Payment Type Code");
        Parameters.Add('QRCodeSetupCode', QRCodeSetupCode);

        POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
        POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::SHOW_TERMINAL_QRCODE, Parameters, 1000 * 60 * 5);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionShowQRCode.js###
'const main=async({workflow:a,parameters:n})=>{await a.respond("showQRCodeOnTerminal",{qrCodeLink:n.qrCodeLink})};'
        );
    end;
}
