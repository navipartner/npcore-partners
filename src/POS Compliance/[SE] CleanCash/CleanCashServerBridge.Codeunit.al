codeunit 6184504 "NPR CleanCash Server Bridge"
{
    // NPR5.31/JHL/20170223 CASE 256695 CU created to handle the server site communication with CleanCash


    trigger OnRun()
    begin
    end;

    var
        CleanCashBridge: DotNet NPRNetCleanCashBridge;
        CCCommunicationResult: DotNet NPRNetCommunicationResult;
        CCCommunicationStatus: DotNet NPRNetCommunicationStatus;
        ControlCode: Text[100];
        SerialNo: Text[100];
        LastExtendedError: Text[100];
        LastUnitStatusList: Text[100];
        EventStatus: Option NotSet,FailOpen,FailCheckStatusEX,FailRegisterPos,FailCheckStatus,FailStartReceipt,FailSendReceiptEX,FailSendReceipt,ReceiptSend;

    procedure SendReceiptByBridge(var EnumCommResult: DotNet NPRNetCommunicationResult; var EventResponse: Option NotSet,FailOpen,FailCheckStatusEX,FailRegisterPos,FailCheckStatus,FailStartReceipt,FailSendReceiptEX,FailSendReceipt,ReceiptSend; OrganisationNumber: Text[10]; PosId: Text[16]; DateTime: Text[12]; ReceiptNo: Text[30]; ReceiptType: DotNet NPRNetCommunicationReceipt; ReceiptTotal: Text[30]; NegativeTotal: Text[30]; Vat: array[4] of Text[30]; ConnectionString: Text[100]; MultiOrganizationIDPerPOS: Boolean; ShowErrorMessage: Boolean)
    begin
        CleanCashBridge := CleanCashBridge.CleanCashBridge();

        Open(ConnectionString);
        EventResponse := EventStatus;
        if IsCCFailed(EnumCommResult, EventResponse) then
            exit;

        if MultiOrganizationIDPerPOS then begin
            //CheckStatusEx
            CheckStatusEX(OrganisationNumber, PosId);
            if IsCCFailed(EnumCommResult, EventResponse) then
                exit;

            //SendReceiptEX
            SendReceiptEX(OrganisationNumber,
                          PosId,
                          DateTime,
                          ReceiptNo,
                          ReceiptType,
                          ReceiptTotal,
                          NegativeTotal,
                          Vat);
            if IsCCFailed(EnumCommResult, EventResponse) then
                exit;

        end else begin
            //RegisterPos
            RegisterPos(OrganisationNumber, PosId);
            if IsCCFailed(EnumCommResult, EventResponse) then
                exit;
            //CheckStatus
            CheckStatus();

            if IsCCFailed(EnumCommResult, EventResponse) then
                exit;
            //StartReceipt
            StartReceipt();
            if IsCCFailed(EnumCommResult, EventResponse) then
                exit;
            //Sendreceipt
            SendReceipt(DateTime,
                        ReceiptNo,
                        ReceiptType,
                        ReceiptTotal,
                        NegativeTotal,
                        Vat);
            if IsCCFailed(EnumCommResult, EventResponse) then
                exit;
        end;
        SerialNo := CleanCashBridge.UnitId;
        ControlCode := CleanCashBridge.LastControlCode;

        EventResponse := EventResponse::NotSet;
    end;

    local procedure IsCCFailed(var EnumCommResult: DotNet NPRNetCommunicationResult; var EventResponse: Option NotSet,FailOpen,FailCheckStatusEX,FailRegisterPos,FailCheckStatus,FailStartReceipt,FailSendReceiptEX,FailSendReceipt,ReceiptSend): Boolean
    var
        EnumCommResultInt: Integer;
    begin
        EnumCommResultInt := EnumCommResult.RC_SUCCESS;
        EnumCommResult := CCCommunicationResult;
        EventResponse := EventStatus;
        exit(not (CCCommunicationResult = EnumCommResultInt));
    end;

    local procedure Open(ConnectionString: Text[100])
    begin
        CCCommunicationResult := CleanCashBridge.Open(ConnectionString);
        EventStatus := EventStatus::FailOpen;
    end;

    local procedure CheckStatusEX(OrganisationNumber: Text[10]; PosId: Text[16]): Boolean
    begin
        CCCommunicationResult := CleanCashBridge.CheckStatusEX(OrganisationNumber, PosId);
        EventStatus := EventStatus::FailCheckStatusEX;
    end;

    local procedure SendReceiptEX(OrganisationNumber: Text[10]; PosId: Text[16]; DateTime: Text[12]; ReceiptNo: Text[30]; ReceiptType: DotNet NPRNetCommunicationReceipt; ReceiptTotal: Text[30]; NegativeTotal: Text[30]; Vat: array[4] of Text[30])
    begin
        CCCommunicationResult := CleanCashBridge.SendReceiptEx(OrganisationNumber,
                                                               PosId,
                                                               DateTime,
                                                               ReceiptNo,
                                                               ReceiptType,
                                                               ReceiptTotal,
                                                               NegativeTotal,
                                                               Vat[1],
                                                               Vat[2],
                                                               Vat[3],
                                                               Vat[4]);
        EventStatus := EventStatus::FailSendReceiptEX;
    end;

    local procedure RegisterPos(OrganisationNumber: Text[10]; PosId: Text[16])
    begin
        CCCommunicationResult := CleanCashBridge.RegisterPos(OrganisationNumber, PosId);
        EventStatus := EventStatus::FailRegisterPos;
    end;

    local procedure CheckStatus()
    begin
        CCCommunicationResult := CleanCashBridge.CheckStatus();
        EventStatus := EventStatus::FailCheckStatus;
    end;

    local procedure StartReceipt()
    begin
        CCCommunicationResult := CleanCashBridge.StartReceipt();
        EventStatus := EventStatus::FailStartReceipt;
    end;

    local procedure SendReceipt(DateTime: Text[12]; ReceiptNo: Text[30]; ReceiptType: DotNet NPRNetCommunicationReceipt; ReceiptTotal: Text[30]; NegativeTotal: Text[30]; Vat: array[4] of Text[30])
    begin
        CCCommunicationResult := CleanCashBridge.SendReceipt(DateTime,
                                                             ReceiptNo,
                                                             ReceiptType,
                                                             ReceiptTotal,
                                                             NegativeTotal,
                                                             Vat[1],
                                                             Vat[2],
                                                             Vat[3],
                                                             Vat[4]);
        EventStatus := EventStatus::FailSendReceipt;
    end;

    procedure GetCCCommunicationStatus(var EnumCommStatus: DotNet NPRNetCommunicationStatus)
    begin
        EnumCommStatus := CleanCashBridge.LastUnitStatus;
    end;

    procedure GetLastUnitStatusList(): Text[100]
    begin
        exit(CleanCashBridge.LastUnitStatusCodeList);
    end;

    procedure GetControlCode(): Text[100]
    begin
        exit(ControlCode);
    end;

    procedure GetSerialNo(): Text[100]
    begin
        exit(SerialNo);
    end;

    procedure GetLastExtendedError(): Integer
    begin
        exit(CleanCashBridge.LastExtendedError);
    end;
}

