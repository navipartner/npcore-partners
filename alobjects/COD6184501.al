codeunit 6184501 "CleanCash Communication"
{
    // NPR4.21/JHL/20160302 CASE 222417 Created for handle the communication with CleanCash API
    // NPR5.26/JHL/20160705 CASE 242776 Deleted function not used, change the communication to use CleanCash Proxy.
    // NPR5.26/JHL/20160909 CASE 244106 Remove the creation of "CleanCash Reciept No." for CleanCash AuditRoll. Delete funciton GetUniqueTicketNo, and move to CU 6184502
    //                                   Added error handling on function SendReceipt. And change the maximum length of register to 16.
    // NPR5.29/JHL/20161028 CASE 256695 Added paramet "CleanCashRegisterNo" to the function SendReceipt, and uses this variable to send to the blackbox
    // NPR5.29/JHL/20161111 CASE 256695 Make sure that all CleanCash is commited, when the transaction is done
    // NPR5.31/JHL/20170223 CASE 256695 Add communication to application through server side

    TableNo = "Audit Roll";

    trigger OnRun()
    begin
    end;

    var
        CleanCashServerBridge: Codeunit "CleanCash Server Bridge";
        Method: Text[30];
        EnumType: Text[30];
        IsConnected: Boolean;
        Err001: Label 'Failed to check status (%1) of the CleanCash unit. Result code: %2';
        Err002: Label 'Failed on contact to CleanCash. Result code: %1';
        Err003: Label 'Failed to register POS. Result code: %1';
        Err004: Label 'Communication with CleanCash terminal, has return a fatal error, with CommStatusErr %1 and LastUnitStatusCodeList %2';
        IsOpen: Boolean;
        Err005: Label 'The length of Register No. must be a maximum of 16. ';
        Err006: Label 'Not allowed to print any more copies';
        ShowErrorMessage: Boolean;
        Err007: Label 'The receipt was not send correct to the CleanCash Box';
        Err008: Label 'Register %1 is not setup to run CleanCash service';
        Msg001: Label 'Sales Ticket No. %1, was not fount in the Audit Roll, the Sales Ticket could not be registered in CleanCash';
        Msg002: Label 'CleanCash returns EnumCommResult %1, with ExtendedError %2';
        Msg003: Label 'CleanCash returns EnumCommResult %1';
        Msg004: Label 'CleanCash returns EnumCommStatus %1';
        RunMultipleLine: Boolean;
        RunLocal: Boolean;

    procedure RunSingelSalesTicket(SalesTicketNo: Code[20];RegisterNo: Code[10])
    var
        CleanCashAuditRoll: Record "CleanCash Audit Roll";
    begin
        CleanCashAuditRoll.SetRange("Sales Ticket No.",SalesTicketNo);
        CleanCashAuditRoll.SetRange("Register No.",RegisterNo);

        if CleanCashAuditRoll.FindFirst then begin
          //-NPR5.26
          //SendReceipt(CleanCashAuditRoll."Register No.",CleanCashAuditRoll."Sales Ticket No.")
          if not SendReceipt(CleanCashAuditRoll."Register No.",CleanCashAuditRoll."Sales Ticket No.") then
            Message('Last Error %1',GetLastErrorText);
            //MESSAGE(Err007);
          //-NPR5.26
        end else
          Message(Msg004,SalesTicketNo);

        //-NPR5.29
        Commit;
        //+NPR5.29
    end;

    procedure RunMultiSalesTicket()
    var
        CleanCashAuditRoll: Record "CleanCash Audit Roll";
        LastSalesTicketNo: Code[20];
        ReceiptType: DotNet CommunicationReceipt;
    begin
        CleanCashAuditRoll.SetRange("CleanCash Control Code",'');
        CleanCashAuditRoll.SetRange("CleanCash Copy Control Code",'');
        //-NPR5.29
        RunMultipleLine := true;
        ReceiptType := ReceiptType.RECEIPT_TRAINING;
        CleanCashAuditRoll.SetFilter("Receipt Type",'<>%1', ReceiptType.ToString);
        //+NPR5.29

        if CleanCashAuditRoll.FindSet then repeat
          if LastSalesTicketNo <> CleanCashAuditRoll."Sales Ticket No." then begin
            LastSalesTicketNo := CleanCashAuditRoll."Sales Ticket No.";
            SendReceipt(CleanCashAuditRoll."Register No.",CleanCashAuditRoll."Sales Ticket No.");
          end;
        until CleanCashAuditRoll.Next = 0;

        //-NPR5.29
        Commit;
        //+NPR5.29
    end;

    [TryFunction]
    procedure SendReceipt(RegisterNo: Code[20];SalesTicketNo: Code[20])
    var
        CleanCashBridge: Codeunit "CleanCash Server Bridge";
        CleanCashProxy: Codeunit "CleanCash Proxy";
        ProxyDialog: Page "Proxy Dialog";
        Register: Record Register;
        CleanCashSetup: Record "CleanCash Setup";
        CleanCashRegister: Record "CleanCash Register";
        CleanCashAuditRoll: Record "CleanCash Audit Roll";
        CleanCashAuditRoll2: Record "CleanCash Audit Roll";
        ConnectionString: Text[100];
        VATs: array [4] of Text[30];
        ReceiptTime: Text[100];
        CleanCashRegisterNo: Text[16];
        VatRates: array [4] of Decimal;
        VatAmounts: array [4] of Decimal;
        VatRatesNeg: array [4] of Decimal;
        VatAmountsNeg: array [4] of Decimal;
        ReceiptTotal: Decimal;
        ReceiptTotalNeg: Decimal;
        ReceiptTotalNegDummy: Decimal;
        i: Integer;
        ReceiptCopy: Boolean;
        Start: Boolean;
        ReceiptType: DotNet CommunicationReceipt;
        ReceiptNo: Code[10];
        SerialNo: Text[100];
        ControlCode: Text[100];
        TicketType: Option Sale,Mix,Return;
        Loops: Integer;
    begin
        if Register.Get(RegisterNo) and CleanCashRegister.Get(RegisterNo) then
          if not CleanCashRegister."CleanCash Integration" then
            exit;
        
        ReceiptCopy:= false;
        
        //-NPR5.29
        if not CleanCashSetup.Get(RegisterNo) then begin
          Message(Err008,RegisterNo);
          exit;
          end;
        
        
        CleanCashRegisterNo := CleanCashSetup."CleanCash Register No.";
        if CleanCashRegisterNo = '' then
          CleanCashRegisterNo := RegisterNo;
        //+NPR5.29
        
        //-NPR5.26
        //IF STRLEN(RegisterNo) > 6 THEN BEGIN
        //-NPR5.29
        //IF STRLEN(RegisterNo) > 16 THEN BEGIN
        if StrLen(CleanCashRegisterNo) > 16  then begin
        //+NPR5.29
        //+NPR5.26
          Message(Err005);
        end;
        
        CleanCashAuditRoll.SetRange("Register No.",RegisterNo);
        CleanCashAuditRoll.SetRange("Sales Ticket No.",SalesTicketNo);
        
        if CleanCashAuditRoll.Count = 0 then
          exit;
        
        if CleanCashAuditRoll.FindFirst then begin
          if CleanCashAuditRoll.FindFirst then
            if ((CleanCashAuditRoll."CleanCash Serial No." <> '') and (CleanCashAuditRoll."CleanCash Control Code" <> '')) and not RunMultipleLine then begin
              ReceiptCopy := true;
              if ((CleanCashAuditRoll."CleanCash Copy Serial No." <> '') and (CleanCashAuditRoll."CleanCash Copy Control Code" <> '')) then begin
                //ERROR(Err006);
                Message(Err006);
                exit;
              end;
            end;
        
          if CleanCashAuditRoll."Sales Ticket Type" = CleanCashAuditRoll."Sales Ticket Type"::Mix then
            Loops := 2
          else
            Loops := 1;
        
          ReceiptTime := Format(CleanCashAuditRoll."Sale Date",0,'<Year4><Month,2><Day,2>');
          ReceiptTime := ReceiptTime + Format(CleanCashAuditRoll."Closing Time",0,'<Hours24,2><Filler Character,0><Minutes,2><Filler Character,0>');
        end;
        
        //-NPR5.29
        //CleanCashSetup.GET(RegisterNo);
        //+NPR5.29
        
        if GuiAllowed then
          ShowErrorMessage := CleanCashSetup."Show Error Message"
        else
          ShowErrorMessage := false;
        
        i := 1;
        if CleanCashAuditRoll.FindSet then repeat
          if ReceiptCopy then begin
            //-NPR5.26
            //ReceiptNo := CleanCashAuditRoll."CleanCash Reciept No.";
            //+NPR5.26
            ReceiptType := ReceiptType.RECEIPT_COPY;
          end else begin
            //-NPR5.26
            //ReceiptNo := GetUniqueTicketNo(RegisterNo);
            //+NPR5.26
            ReceiptType := ReceiptType.RECEIPT_NORMAL;
          end;
        
          if CleanCashSetup.Training then
            ReceiptType := ReceiptType.RECEIPT_TRAINING;
        
          SetVatArray(VATs,CleanCashAuditRoll);
          //-NPR5.26
          ReceiptNo := CleanCashAuditRoll."CleanCash Reciept No.";
          //+NPR5.26
        
          Start := false;
          //-NPR5.31
          RunLocal := CleanCashSetup."Run Local";
          //+NPR5.31
        
          //-NPR5.29
          if ((CleanCashAuditRoll."CleanCash Control Code" = '') and not ReceiptCopy) or ((CleanCashAuditRoll."CleanCash Copy Control Code" = '') and ReceiptCopy) then begin
          //+NPR5.29
            //-NPR5.31
            /*
            CleanCashProxy.InitializeProtocol();
            CleanCashProxy.Init(CleanCashSetup."Organization ID",
                                //-NPR5.29
                                //RegisterNo,
                                CleanCashRegisterNo,
                                //+NPR5.29
                                ReceiptTime,
                                ReceiptNo,
                                ReceiptType,
                                ConvertDecimal(CleanCashAuditRoll."Receipt Total"),
                                ConvertDecimal(CleanCashAuditRoll."Receipt Total Neg"),
                                VATs,
                                CleanCashSetup."Connection String",
                                CleanCashSetup."Multi Organization ID Per POS",
                                ShowErrorMessage);
            COMMIT;
            CLEAR(ProxyDialog);
        
            ProxyDialog.RunProtocolModal(CODEUNIT::"CleanCash Proxy");
            */
        
            //Start := IsCCSucces;
            Start := SendReceiptToApplication(CleanCashSetup."Organization ID",
                                              CleanCashRegisterNo,
                                              ReceiptTime,
                                              ReceiptNo,
                                              ReceiptType,
                                              ConvertDecimal(CleanCashAuditRoll."Receipt Total"),
                                              ConvertDecimal(CleanCashAuditRoll."Receipt Total Neg"),
                                              VATs,
                                              CleanCashSetup."Connection String",
                                              CleanCashSetup."Multi Organization ID Per POS",
                                              ShowErrorMessage);
            //+NPR5.31
        
          //-NPR5.29
          end;
          //+NPR5.29
          if Start then begin
            //-NPR5.31
            //SerialNo := CleanCashProxy.GetSerialNo;
            //ControlCode := CleanCashProxy.GetControlCode;
            SerialNo := GetSerialNo;
            ControlCode := GetControlCode;
            //+NPR5.31
            Clear(CleanCashAuditRoll2);
            CleanCashAuditRoll2.SetRange("Register No.",RegisterNo);
            CleanCashAuditRoll2.SetRange("Sales Ticket No.",SalesTicketNo);
            CleanCashAuditRoll2.SetRange(Type,CleanCashAuditRoll.Type);
        
            if CleanCashAuditRoll2.FindFirst then begin
              //-NPR5.29
              CleanCashAuditRoll2."CleanCash Register No." := CleanCashRegisterNo;
              //+NPR5.29
              if ReceiptCopy then begin
                CleanCashAuditRoll2."CleanCash Copy Serial No." := SerialNo;
                CleanCashAuditRoll2."CleanCash Copy Control Code" := ControlCode;
                CleanCashAuditRoll2."Receipt Type" := ReceiptType.ToString;
                CleanCashAuditRoll2.Modify(false);
              end else begin
                //-NPR5.26
                //CleanCashAuditRoll2."CleanCash Reciept No." := ReceiptNo;
                //+NPR5.26
                CleanCashAuditRoll2."CleanCash Serial No." := SerialNo;
                CleanCashAuditRoll2."CleanCash Control Code" := ControlCode;
                CleanCashAuditRoll2."Receipt Type" := ReceiptType.ToString;
                CleanCashAuditRoll2.Modify(false);
              end;
            end;
            Commit;
          end;
        until CleanCashAuditRoll.Next = 0;

    end;

    local procedure "//Assistens Function"()
    begin
    end;

    local procedure SendReceiptToApplication(OrganisationNumber: Text[10];PosId: Text[16];DateTime: Text[12];ReceiptNo: Text[30];ReceiptType: DotNet CommunicationReceipt;ReceiptTotal: Text[30];NegativeTotal: Text[30];Vat: array [4] of Text[30];ConnectionString: Text[100];MultiOrganizationIDPerPOS: Boolean;ShowErrorMessage: Boolean) IsSucces: Boolean
    var
        CleanCashBridge: Codeunit "CleanCash Server Bridge";
        CleanCashProxy: Codeunit "CleanCash Proxy";
        ProxyDialog: Page "Proxy Dialog";
        CCCommResult: DotNet CommunicationResult;
        EventResponse: Option NotSet,FailOpen,FailCheckStatusEX,FailRegisterPos,FailCheckStatus,FailStartReceipt,FailSendReceiptEX,FailSendReceipt,ReceiptSend;
    begin
          //-NPR5.31

          if RunLocal then begin
            CleanCashProxy.InitializeProtocol();
            CleanCashProxy.Init(OrganisationNumber,
                                PosId,
                                DateTime,
                                ReceiptNo,
                                ReceiptType,
                                ReceiptTotal,
                                NegativeTotal,
                                Vat,
                                ConnectionString,
                                MultiOrganizationIDPerPOS,
                                ShowErrorMessage);
            Commit;
            Clear(ProxyDialog);

            ProxyDialog.RunProtocolModal(CODEUNIT::"CleanCash Proxy");
            CleanCashProxy.GetCCCommunicationResult(CCCommResult);
            EventResponse := CleanCashProxy.GetEventResponse;
          end else begin
            CleanCashServerBridge.SendReceiptByBridge(CCCommResult,
                                              EventResponse,
                                              OrganisationNumber,
                                              PosId,
                                              DateTime,
                                              ReceiptNo,
                                              ReceiptType,
                                              ReceiptTotal,
                                              NegativeTotal,
                                              Vat,
                                              ConnectionString,
                                              MultiOrganizationIDPerPOS,
                                              ShowErrorMessage)
          end;
          IsSucces := IsCCSucces(CCCommResult, EventResponse)
          //+NPR5.31
    end;

    local procedure LogCleanCashError(EventResponse: Option NotSet,FailOpen,FailCheckStatusEX,FailRegisterPos,FailCheckStatus,FailStartReceipt,FailSendReceiptEX,FailSendReceipt,ReceiptSend;EnumType: Text[50];ErrorText: Text[200])
    var
        CleanCashErrorList: Record "CleanCash Error List";
    begin
        CleanCashErrorList.Date := Today;
        CleanCashErrorList.Time := Time;
        CleanCashErrorList."Object Type" := CleanCashErrorList."Object Type"::Codeunit;
        CleanCashErrorList."Object No." := CODEUNIT::"CleanCash Communication";
        CleanCashErrorList."Object Name" := 'Clean Cash Communication';
        CleanCashErrorList.EventResponse := EventResponse;
        CleanCashErrorList."Enum Type" := EnumType;
        CleanCashErrorList."Error Text" := ErrorText;
        if not CleanCashErrorList.Insert then
          CleanCashErrorList.Modify;
        //COMMIT;
    end;

    local procedure ConvertDecimal(Value: Decimal) RetValue: Text[30]
    begin
        RetValue := ConvertStr(Format(Value,0,'<Precision,2:2><Standard Format,2>'),'.',',');
    end;

    local procedure SetVatArray(var Vats: array [4] of Text[30];CleanCashAuditRoll: Record "CleanCash Audit Roll")
    var
        i: Integer;
    begin
        Vats[1] := ConvertDecimal(CleanCashAuditRoll.VatRate1) + ';' + ConvertDecimal(CleanCashAuditRoll.VatAmount1);
        Vats[2] := ConvertDecimal(CleanCashAuditRoll.VatRate2) + ';' + ConvertDecimal(CleanCashAuditRoll.VatAmount2);
        Vats[3] := ConvertDecimal(CleanCashAuditRoll.VatRate3) + ';' + ConvertDecimal(CleanCashAuditRoll.VatAmount3);
        Vats[4] := ConvertDecimal(CleanCashAuditRoll.VatRate4) + ';' + ConvertDecimal(CleanCashAuditRoll.VatAmount4);
    end;

    local procedure IsCCSucces(CCCommResult: DotNet CommunicationResult;EventResponse: Option NotSet,FailOpen,FailCheckStatusEX,FailRegisterPos,FailCheckStatus,FailStartReceipt," FailSendReceiptEX"," FailSendReceipt",ReceiptSend): Boolean
    var
        CleanCashProxy: Codeunit "CleanCash Proxy";
        CCCommResultInt: Integer;
    begin
        //-NPR5.31
        //CleanCashProxy.GetCCCommunicationResult(CCCommResult);
        //EventResponse := CleanCashProxy.GetEventResponse;
        //+NPR5.31
        if not CheckEnumCommResult(EventResponse, CCCommResult) then begin
          if ((EventResponse = EventResponse::FailCheckStatus) or (EventResponse = EventResponse::FailCheckStatusEX)) then
            CheckEnumCommStatus(EventResponse);
          exit(false);
        end;

        exit(true);
    end;

    local procedure CheckEnumCommResult(EventResponse: Option NotSet,FailOpen,FailCheckStatusEX,FailRegisterPos,FailCheckStatus,FailStartReceipt,FailSendReceiptEX,FailSendReceipt,ReceiptSend;EnumCommResult: DotNet CommunicationResult): Boolean
    var
        CleanCashProxy: Codeunit "CleanCash Proxy";
        EnumType: Text[30];
        ExtendedError: Integer;
        EnumCommResultInt: Integer;
    begin
        EnumCommResultInt := EnumCommResult;

        case EnumCommResultInt of
          EnumCommResult.RC_SUCCESS:
            exit(true);
          EnumCommResult.RC_E_FAILURE:
            begin
              //-NPR5.31
              ExtendedError := GetLastExtendedError;
              //+NPR5.31
              if ShowErrorMessage then begin
                //-NPR5.31
                //ExtendedError := CleanCashProxy.GetLastExtendedError;
                //MESSAGE(Msg003,EnumCommResult.ToString,CleanCashProxy.GetLastExtendedError);
                Message(Msg003,EnumCommResult.ToString,ExtendedError);
                //+NPR5.31
              end;
              //-NPR5.31
              //LogCleanCashError(EventResponse,EnumType,STRSUBSTNO('EnumCommResult := %1, ExtendedError := %2',EnumCommResult.ToString,CleanCashProxy.GetLastExtendedError));
              LogCleanCashError(EventResponse,EnumType,StrSubstNo('EnumCommResult := %1, ExtendedError := %2',EnumCommResult.ToString,ExtendedError));
              //+NPR5.31
            end;
          EnumCommResult.RC_E_ILLEGAL,
          EnumCommResult.RC_E_INVALID_PARAMETER,
          EnumCommResult.RC_E_INVALID_PORT,
          EnumCommResult.RC_E_LICENSE_EXCEEDED,
          EnumCommResult.RC_E_NOT_CLEANCASH,
          EnumCommResult.RC_E_NOT_SUPPORTED,
          EnumCommResult.RC_E_NULL_PARAMETER,
          EnumCommResult.RC_E_PORT_BUSY:
            begin
              if ShowErrorMessage then
                Message(Msg001,EnumCommResult.ToString);
              LogCleanCashError(EventResponse,EnumType,EnumCommResult.ToString);
            end;
          else
           if ShowErrorMessage then
              Message(Msg001,EnumCommResult.ToString);
        end;

        exit(false);
    end;

    local procedure CheckEnumCommStatus(EventResponse: Option NotSet,FailOpen,FailCheckStatusEX,FailRegisterPos,FailCheckStatus,FailStartReceipt,FailSendReceiptEX,FailSendReceipt,ReceiptSend): Boolean
    var
        EnumStatus: DotNet CommunicationStatus;
        CleanCashProxy: Codeunit "CleanCash Proxy";
        EnumType: Text[30];
        StatusList: Text[100];
        EnumStatusInt: Integer;
    begin
        EnumType := 'CommunicationStatus';
        //-NPR5.31
        //CleanCashProxy.GetCCCommunicationStatus(EnumStatus);
        //StatusList := CleanCashProxy.GetLastUnitStatusList;
        GetCCCommunicationStatus(EnumStatus);
        StatusList := GetLastUnitStatusList;
        //+NPR5.31
        EnumStatusInt := EnumStatus;

        case EnumStatusInt of
          EnumStatus.STATUS_OK:
              exit(true);
          EnumStatus.STATUS_WARNING,
          EnumStatus.STATUS_PROTOCOL_ERROR,
          EnumStatus.STATUS_ERROR,
          EnumStatus.STATUS_BUSY,
          EnumStatus.STATUS_UNKNOWN,
          EnumStatus.STATUS_COMMUNICATION_ERROR:
            begin
              if ShowErrorMessage then
                Message(Msg002,EnumStatus.ToString);
              LogCleanCashError(EventResponse,EnumType,EnumStatus.ToString);
            end;
          EnumStatus.STATUS_FATAL_ERROR:
            begin
              LogCleanCashError(EventResponse,EnumType,EnumStatus.ToString);
              Message(Err004,EnumStatus.ToString,StatusList);
            end;
          else begin
            if ShowErrorMessage then
              Message(Msg002,EnumStatus.ToString);
            LogCleanCashError(EventResponse,EnumType,EnumStatus.ToString);
          end;
        end;

        exit(false);
    end;

    local procedure GetLastExtendedError(): Integer
    var
        CleanCashProxy: Codeunit "CleanCash Proxy";
    begin
        //-NPR5.31
        if RunLocal then
          exit(CleanCashProxy.GetLastExtendedError)
        else
          exit(CleanCashServerBridge.GetLastExtendedError);
        //+NPR5.31
    end;

    local procedure GetCCCommunicationStatus(var EnumStatus: DotNet CommunicationStatus)
    var
        CleanCashProxy: Codeunit "CleanCash Proxy";
    begin
        //-NPR5.31
        if RunLocal then
          CleanCashProxy.GetCCCommunicationStatus(EnumStatus)
        else
          CleanCashServerBridge.GetCCCommunicationStatus(EnumStatus);
        //+NPR5.31
    end;

    local procedure GetLastUnitStatusList(): Text[100]
    var
        StatusList: Text[100];
        CleanCashProxy: Codeunit "CleanCash Proxy";
    begin
        //-NPR5.31
        if RunLocal then
          exit(CleanCashProxy.GetLastUnitStatusList)
        else
          exit(CleanCashServerBridge.GetLastUnitStatusList);
        //+NPR5.31
    end;

    local procedure GetControlCode(): Text[100]
    var
        CleanCashProxy: Codeunit "CleanCash Proxy";
    begin
        //-NPR5.31
        if RunLocal then
         exit(CleanCashProxy.GetControlCode)
        else
          exit(CleanCashServerBridge.GetControlCode);
        //+NPR5.31
    end;

    local procedure GetSerialNo(): Text[100]
    var
        CleanCashProxy: Codeunit "CleanCash Proxy";
    begin
        //-NPR5.31
        if RunLocal then
          exit(CleanCashProxy.GetSerialNo)
        else
          exit(CleanCashServerBridge.GetSerialNo);
        //+NPR5.31
    end;
}

