// TODO: CTRLUPGRADE - this codeunit is remnants of the old Proxy Manager based Stargate v1 protocol - INVESTIGATE

codeunit 6184503 "NPR CleanCash Proxy"
{
    // NPR5.26/JHL/20160705  CASE 242776 CU started to handle the communication with CleanCash through Stargate

    SingleInstance = true;

    var
        SerialNo: Text[100];
        ControlCode: Text[100];
        CCCommunicationResult: DotNet NPRNetCommunicationResult;
        CCCommunicationStatus: DotNet NPRNetCommunicationStatus;
        LastUnitStatusList: Text[250];
        LastExtendedError: Integer;
        OrganisationNumber: Text[10];
        PosID: Text[16];
        DateTime: Text[12];
        ReceiptNo: Text[30];
        ReceiptType: DotNet NPRNetCommunicationReceipt;
        ReceiptTotal: Text[30];
        NegativeTotal: Text[30];
        Vat: array[4] of Text[30];
        ConnectionString: Text[100];
        MultiOrganizationIDPerPOS: Boolean;
        ShowErrorMessage: Boolean;
        EventResponse: Option NotSet,FailOpen,FailCheckStatusEX,FailRegisterPos,FailCheckStatus,FailStartReceipt," FailSendReceiptEX"," FailSendReceipt",ReceiptSend;

    procedure InitializeProtocol()
    begin
        ClearAll();
    end;

    procedure Init(pOrganisationNumber: Text[10]; pPosId: Text[16]; pDateTime: Text[12]; pReceiptNo: Text[30]; pReceiptType: DotNet NPRNetCommunicationReceipt; pReceiptTotal: Text[30]; pNegativeTotal: Text[30]; pVat: array[4] of Text[30]; pConnectionString: Text[100]; pMultiOrganizationIDPerPOS: Boolean; pShowErrorMessage: Boolean)
    begin
        OrganisationNumber := pOrganisationNumber;
        PosID := pPosId;
        DateTime := pDateTime;
        ReceiptNo := pReceiptNo;
        ReceiptType := pReceiptType;
        ReceiptTotal := pReceiptTotal;
        NegativeTotal := pNegativeTotal;
        Vat[1] := pVat[1];
        Vat[2] := pVat[2];
        Vat[3] := pVat[3];
        Vat[4] := pVat[4];
        ConnectionString := pConnectionString;
        MultiOrganizationIDPerPOS := pMultiOrganizationIDPerPOS;
        ShowErrorMessage := pShowErrorMessage;
    end;

    procedure GetSerialNo(): Text[100]
    begin
        exit(SerialNo);
    end;

    procedure GetControlCode(): Text[100]
    begin
        exit(ControlCode);
    end;

    procedure GetCCCommunicationResult(var EnumCommResult: DotNet NPRNetCommunicationResult)
    var
        tempInt: Integer;
    begin
        EnumCommResult := CCCommunicationResult;
    end;

    procedure GetCCCommunicationStatus(var EnumCommStatus: DotNet NPRNetCommunicationStatus)
    begin
        EnumCommStatus := CCCommunicationStatus;
    end;

    procedure GetLastUnitStatusList(): Text[250]
    begin
        exit(CopyStr(LastUnitStatusList, 1, 250));
    end;

    procedure GetLastExtendedError(): Integer
    begin
        exit(LastExtendedError);
    end;

    procedure GetEventResponse(): Integer
    begin
        exit(EventResponse);
    end;
}

