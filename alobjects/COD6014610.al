codeunit 6014610 "Tax Free Handler Mgt."
{
    // All tax free handlers implement the publishers in this codeunit.
    // 
    // Handlers can either use the generic parameter pattern (stored as blob on the specific tax free unit record) or maintain their own parameters elsewhere if too complex.
    // 
    // All generic business logic/flows that is handler independent should be in this codeunit while everything else should be inside each implementation.
    // The most important business records (the actual vouchers with links to receipts/sale docs) are created by this codeunit after handler operation is done.
    // 
    // Commit is used vigorously in this codeunit as it is assumed that handlers are acting on external systems.
    // 
    // NPR5.39/MHA /20180202  CASE 302779 Added OnFinishSale POS Workflow
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module


    trigger OnRun()
    begin
    end;

    var
        Error_MissingHandler: Label 'No handler is registered for ID %1';
        Error_TaxFreeProcessing: Label 'An error occurred during tax free processing';
        Error_NotEligible: Label 'Sale is not eligible for tax free voucher. VAT amount or sale date is outside the allowed limits.';
        Error_VoucherIsVoided: Label 'This voucher has already been voided';
        Error_NoVoucherInSession: Label 'No recent tax free voucher found for this session';
        Caption_TestSuccess: Label 'Connection test successful';
        Caption_Code: Label 'Code';
        Caption_UnitConfigured: Label 'Tax Free Unit configured';
        Caption_ExistingVoucherFound: Label 'A tax free voucher already exists for this sale!\Please choose how to proceed:';
        Caption_Cancel: Label 'Cancel (do nothing)';
        Caption_Void: Label 'Void existing voucher';
        Caption_Reissue: Label 'Reissue existing voucher';
        Caption_VoidSucces: Label 'Voucher %1 was voided successfully';
        Caption_EnvironmentWarning: Label 'WARNING:\The current environment is not set to production, but this tax free operation will impact an external service running in production!\Continue?';
        Caption_Workflow: Label 'Issue Tax Free Voucher';

    procedure TryLookupHandler(var HandlerID: Text): Boolean
    var
        HashSet: DotNet HashSet_Of_T;
        tmpRetailList: Record "Retail List" temporary;
        HashSetEnumerator: DotNet HashSet_Of_T_Enumerator;
    begin
        CreateDotNetHashSet(HashSet);
        OnLookupHandler(HashSet);

        HashSetEnumerator := HashSet.GetEnumerator();
        while (HashSetEnumerator.MoveNext()) do begin
          tmpRetailList.Number += 1;
          tmpRetailList.Choice := HashSetEnumerator.Current();
          tmpRetailList.Insert;
        end;

        if tmpRetailList.IsEmpty then
          exit(false);

        if PAGE.RunModal(PAGE::"Retail List", tmpRetailList) <> ACTION::LookupOK then
          exit(false);

        HandlerID := tmpRetailList.Choice;
        exit(true);
    end;

    procedure SetGenericHandlerParameters(TaxFreeUnit: Record "Tax Free POS Unit")
    var
        tmpHandlerParameter: Record "Tax Free Handler Parameters" temporary;
        Handled: Boolean;
        JSON: Text;
        TaxFreeHandlerParameters: Page "Tax Free Gen. Handler Params";
    begin
        OnLookupHandlerParameters(TaxFreeUnit, Handled, tmpHandlerParameter);
        if not Handled then
          Error(Error_MissingHandler, TaxFreeUnit."Handler ID");

        if tmpHandlerParameter.IsEmpty then
          exit;

        if TaxFreeUnit."Handler Parameters".HasValue then
          tmpHandlerParameter.DeserializeParameterBLOB(TaxFreeUnit);

        TaxFreeHandlerParameters.Editable(true);
        TaxFreeHandlerParameters.SetRec(tmpHandlerParameter);
        if TaxFreeHandlerParameters.RunModal <> ACTION::OK then
          exit;

        TaxFreeHandlerParameters.GetRec(tmpHandlerParameter);

        tmpHandlerParameter.SerializeParameterBLOB(TaxFreeUnit);
        TaxFreeUnit.Modify;
    end;

    local procedure "--- Tax Free Actions"()
    begin
    end;

    procedure SetParameters(TaxFreeUnit: Record "Tax Free POS Unit")
    var
        Handled: Boolean;
    begin
        OnSetUnitParameters(TaxFreeUnit, Handled);

        if not Handled then
          Error(Error_MissingHandler, TaxFreeUnit."Handler ID");
    end;

    procedure UnitAutoConfigure(TaxFreeUnit: Record "Tax Free POS Unit";Silent: Boolean)
    var
        TaxFreeRequest: Record "Tax Free Request";
        Handled: Boolean;
    begin
        CreateRequest('UNIT_AUTO_CONFIGURE', TaxFreeUnit, TaxFreeRequest);

        ClearLastError();
        asserterror begin
          OnUnitAutoConfigure(TaxFreeRequest, Silent, Handled);
          TaxFreeRequest.Success := true;
          Commit;
          Error('');
        end;

        HandleEventResponse(Handled, TaxFreeUnit, TaxFreeRequest, false);

        if (TaxFreeRequest.Success and Handled and (not Silent)) then
          Message(Caption_UnitConfigured);
    end;

    procedure UnitTestConnection(TaxFreeUnit: Record "Tax Free POS Unit")
    var
        Handled: Boolean;
        TaxFreeRequest: Record "Tax Free Request";
    begin
        CreateRequest('UNIT_TEST_CONN', TaxFreeUnit, TaxFreeRequest);

        ClearLastError();
        asserterror begin
          OnUnitTestConnection(TaxFreeRequest, Handled);
          TaxFreeRequest.Success := true;
          Commit;
          Error('');
        end;

        HandleEventResponse(Handled, TaxFreeUnit, TaxFreeRequest, false);

        if (TaxFreeRequest.Success and Handled) then
          Message(Caption_TestSuccess);
    end;

    procedure VoucherIssueFromPOSSale(ReceiptNo: Text)
    var
        Handled: Boolean;
        AuditRoll: Record "Audit Roll";
        TaxFreeUnit: Record "Tax Free POS Unit";
        AuditRollAmountCheck: Record "Audit Roll";
        TaxFreeRequest: Record "Tax Free Request";
        TaxFreeVoucher: Record "Tax Free Voucher";
        "Action": Integer;
        tmpTaxFreeVoucherSaleLink: Record "Tax Free Voucher Sale Link" temporary;
        SkipRecordHandling: Boolean;
    begin
        AuditRoll.SetCurrentKey("Sales Ticket No.");
        AuditRoll.SetRange("Sales Ticket No.", ReceiptNo);
        AuditRoll.FindFirst;
        TaxFreeUnit.Get(AuditRoll."Register No.");

        if not CheckEnvironment(TaxFreeUnit) then
          exit;

        CreateRequest('VOUCHER_ISSUE', TaxFreeUnit, TaxFreeRequest);

        if TryGetActiveVoucherFromReceiptNo(ReceiptNo, TaxFreeVoucher) then begin //Another voucher is already linked to this receipt, we can't issue a new one.
          Action := StrMenu(StrSubstNo('%1,%2,%3', Caption_Reissue, Caption_Void, Caption_Cancel), 3, Caption_ExistingVoucherFound);
          case Action of
            1 : VoucherReissue(TaxFreeVoucher);
            2 : VoucherVoid(TaxFreeVoucher);
          end;
          exit;
        end;

        if not IsStoredSaleEligible(TaxFreeUnit, ReceiptNo) then begin
          TaxFreeRequest."Error Message" := Error_NotEligible;
          LogEvent(TaxFreeUnit, TaxFreeRequest);
          ShowError(Error_NotEligible);
          exit;
        end;

        ClearLastError();
        asserterror begin
          OnVoucherIssueFromPOSSale(TaxFreeRequest, ReceiptNo, Handled, SkipRecordHandling);
          TaxFreeRequest.Success := true;
          Commit;
          Error('');
        end;

        HandleEventResponse(Handled, TaxFreeUnit, TaxFreeRequest, false);

        if TaxFreeRequest.Success and (not SkipRecordHandling) then begin
          tmpTaxFreeVoucherSaleLink.Init;
          tmpTaxFreeVoucherSaleLink."Sales Ticket No." := ReceiptNo;
          tmpTaxFreeVoucherSaleLink.Insert;

          CreateAndPrintVoucher(TaxFreeRequest, tmpTaxFreeVoucherSaleLink);
        end;
    end;

    procedure VoucherVoid(var TaxFreeVoucher: Record "Tax Free Voucher")
    var
        TaxFreeUnit: Record "Tax Free POS Unit";
        Handled: Boolean;
        TaxFreeRequest: Record "Tax Free Request";
    begin
        TaxFreeUnit.Get(TaxFreeVoucher."POS Unit No.");
        if not CheckEnvironment(TaxFreeUnit) then
          exit;

        CreateRequest('VOUCHER_VOID', TaxFreeUnit, TaxFreeRequest);

        TaxFreeRequest."External Voucher Barcode" := TaxFreeVoucher."External Voucher Barcode";
        TaxFreeRequest."External Voucher No." := TaxFreeVoucher."External Voucher No.";

        if TaxFreeVoucher.Void then begin
          TaxFreeRequest."Error Message" := Error_VoucherIsVoided;
          LogEvent(TaxFreeUnit, TaxFreeRequest);
          ShowError(Error_VoucherIsVoided);
          exit;
        end;

        ClearLastError();
        asserterror begin
          OnVoucherVoid(TaxFreeRequest, TaxFreeVoucher, Handled);
          TaxFreeRequest.Success := true;
          Commit;
          Error('');
        end;

        HandleEventResponse(Handled, TaxFreeUnit, TaxFreeRequest, false);

        if (TaxFreeRequest.Success and Handled) then
          VoidVoucher(TaxFreeVoucher, false);
    end;

    procedure VoucherReissue(var TaxFreeVoucher: Record "Tax Free Voucher")
    var
        Handled: Boolean;
        TaxFreeUnit: Record "Tax Free POS Unit";
        TaxFreeRequest: Record "Tax Free Request";
        tmpTaxFreeVoucherSaleLink: Record "Tax Free Voucher Sale Link" temporary;
        TaxFreeVoucherSaleLink: Record "Tax Free Voucher Sale Link";
    begin
        TaxFreeUnit.Get(TaxFreeVoucher."POS Unit No.");
        if not CheckEnvironment(TaxFreeUnit) then
          exit;

        TaxFreeVoucherSaleLink.SetRange("Voucher Entry No.", TaxFreeVoucher."Entry No.");
        TaxFreeVoucherSaleLink.FindSet;
        repeat
          tmpTaxFreeVoucherSaleLink.Init;
          tmpTaxFreeVoucherSaleLink.TransferFields(TaxFreeVoucherSaleLink);
          tmpTaxFreeVoucherSaleLink.Insert;
        until TaxFreeVoucherSaleLink.Next = 0;

        CreateRequest('VOUCHER_REISSUE', TaxFreeUnit, TaxFreeRequest);

        TaxFreeRequest."External Voucher Barcode" := TaxFreeVoucher."External Voucher Barcode";
        TaxFreeRequest."External Voucher No." := TaxFreeVoucher."External Voucher No.";

        if TaxFreeVoucher.Void then begin
          TaxFreeRequest."Error Message" := Error_VoucherIsVoided;
          LogEvent(TaxFreeUnit, TaxFreeRequest);
          ShowError(Error_VoucherIsVoided);
          exit;
        end;

        ClearLastError();
        asserterror begin
          OnVoucherReissue(TaxFreeRequest, TaxFreeVoucher, Handled);
          TaxFreeRequest.Success := true;
          Commit;
          Error('');
        end;

        HandleEventResponse(Handled, TaxFreeUnit, TaxFreeRequest, false);

        if (TaxFreeRequest.Success and Handled) then begin
          VoidVoucher(TaxFreeVoucher, true); //Void old
          CreateAndPrintVoucher(TaxFreeRequest, tmpTaxFreeVoucherSaleLink); //Create & print new
        end;
    end;

    procedure VoucherLookup(TaxFreeUnit: Record "Tax Free POS Unit";VoucherNo: Text)
    var
        Handled: Boolean;
        TaxFreeRequest: Record "Tax Free Request";
    begin
        CreateRequest('VOUCHER_LOOKUP', TaxFreeUnit, TaxFreeRequest);

        ClearLastError();
        asserterror begin
          OnVoucherLookup(TaxFreeRequest, VoucherNo, Handled);
          TaxFreeRequest.Success := true;
          Commit;
          Error('');
        end;

        HandleEventResponse(Handled, TaxFreeUnit, TaxFreeRequest, false);
    end;

    procedure VoucherPrint(TaxFreeVoucher: Record "Tax Free Voucher")
    var
        Handled: Boolean;
        TaxFreeUnit: Record "Tax Free POS Unit";
        TaxFreeRequest: Record "Tax Free Request";
    begin
        TaxFreeUnit.Get(TaxFreeVoucher."POS Unit No.");
        CreateRequest('VOUCHER_PRINT', TaxFreeUnit, TaxFreeRequest);

        if TaxFreeVoucher.Void then begin
          TaxFreeRequest."Error Message" := Error_VoucherIsVoided;
          LogEvent(TaxFreeUnit, TaxFreeRequest);
          ShowError(Error_VoucherIsVoided);
          exit;
        end;

        TaxFreeVoucher.CalcFields(Print);
        TaxFreeRequest.Print := TaxFreeVoucher.Print;
        TaxFreeRequest."Print Type" := TaxFreeVoucher."Print Type";

        ClearLastError();
        asserterror begin
          OnVoucherPrint(TaxFreeRequest, TaxFreeVoucher, false, Handled);
          TaxFreeRequest.Success := true;
          Commit;
          Error('');
        end;

        HandleEventResponse(Handled, TaxFreeUnit, TaxFreeRequest, false);
    end;

    procedure VoucherPrintLast()
    var
        TaxFreeLastPrint: Codeunit "Tax Free Last Voucher Print";
        VoucherEntryNo: Integer;
        TempBlob: Record TempBlob temporary;
        PrintType: Integer;
        Handled: Boolean;
        TaxFreeRequest: Record "Tax Free Request";
        TaxFreeVoucher: Record "Tax Free Voucher";
        TaxFreeUnit: Record "Tax Free POS Unit";
        POSSession: Codeunit "POS Session";
        POSFrontEndManagement: Codeunit "POS Front End Management";
        POSSetup: Codeunit "POS Setup";
    begin
        //Single instance codeunit contains the last tax free voucher from this user session - for integrations where you should not always be able to re-print any voucher, only the recent last.
        if not TaxFreeLastPrint.GetVoucher(VoucherEntryNo, TempBlob, PrintType) then
          Error(Error_NoVoucherInSession);

        TaxFreeVoucher.Get(VoucherEntryNo);
        TaxFreeUnit.Get(TaxFreeVoucher."POS Unit No.");

        CreateRequest('VOUCHER_PRINT_LAST', TaxFreeUnit, TaxFreeRequest);

        if TaxFreeVoucher.Void then begin
          TaxFreeRequest."Error Message" := Error_VoucherIsVoided;
          LogEvent(TaxFreeUnit, TaxFreeRequest);
          ShowError(Error_VoucherIsVoided);
          exit;
        end;

        TaxFreeRequest.Print := TempBlob.Blob;
        TaxFreeRequest."Print Type" := PrintType;

        ClearLastError();
        asserterror begin
          OnVoucherPrint(TaxFreeRequest, TaxFreeVoucher, true, Handled);
          TaxFreeRequest.Success := true;
          Commit;
          Error('');
        end;

        HandleEventResponse(Handled, TaxFreeUnit, TaxFreeRequest, false);
    end;

    procedure VoucherConsolidate(TaxFreeUnit: Record "Tax Free POS Unit";var tmpTaxFreeConsolidation: Record "Tax Free Consolidation" temporary)
    var
        Handled: Boolean;
        Success: Boolean;
        TaxFreeRequest: Record "Tax Free Request";
        tmpTaxFreeVoucherSaleLink: Record "Tax Free Voucher Sale Link" temporary;
    begin
        if not CheckEnvironment(TaxFreeUnit) then
          exit;

        CreateRequest('VOUCHER_CONSOLIDATE', TaxFreeUnit, TaxFreeRequest);

        if not tmpTaxFreeConsolidation.FindSet then
          exit;

        if tmpTaxFreeConsolidation.Count = 1 then begin //Normal voucher issue flow instead.
          VoucherIssueFromPOSSale(tmpTaxFreeConsolidation."Sales Ticket No.");
          exit;
        end;

        asserterror begin
          OnVoucherConsolidate(TaxFreeRequest, tmpTaxFreeConsolidation, Handled);
          TaxFreeRequest.Success := true;
          Commit;
          Error('');
        end;

        HandleEventResponse(Handled, TaxFreeUnit, TaxFreeRequest, false);

        if TaxFreeRequest.Success then begin
          tmpTaxFreeConsolidation.FindSet;
          repeat
            tmpTaxFreeVoucherSaleLink.Init;
            tmpTaxFreeVoucherSaleLink."Sales Ticket No." := tmpTaxFreeConsolidation."Sales Ticket No.";
            tmpTaxFreeVoucherSaleLink."Sales Header No." := tmpTaxFreeConsolidation."Sales Header No.";
            tmpTaxFreeVoucherSaleLink."Sales Header Type" := tmpTaxFreeConsolidation."Sales Header Type";
            tmpTaxFreeVoucherSaleLink.Insert;
          until tmpTaxFreeConsolidation.Next = 0;

          CreateAndPrintVoucher(TaxFreeRequest, tmpTaxFreeVoucherSaleLink);
        end;
    end;

    procedure IsValidTerminalIIN(TaxFreeUnit: Record "Tax Free POS Unit";MaskedCardNo: Text): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
        Handled: Boolean;
        Valid: Boolean;
        TaxFreeRequest: Record "Tax Free Request";
    begin
        if not TaxFreeUnit."Check POS Terminal IIN" then
          exit(false);

        CreateRequest('TERMINAL_IIN_CHECK', TaxFreeUnit, TaxFreeRequest);

        ClearLastError;
        asserterror begin
          OnIsValidTerminalIIN(TaxFreeRequest, MaskedCardNo, Valid, Handled);
          TaxFreeRequest.Success := true;
          Commit;
          Error('');
        end;

        HandleEventResponse(Handled, TaxFreeUnit, TaxFreeRequest, true);

        exit(Valid);
    end;

    procedure IsActiveSaleEligible(TaxFreeUnit: Record "Tax Free POS Unit";SalesTicketNo: Code[20]): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
        TaxFreeRequest: Record "Tax Free Request";
        Eligible: Boolean;
        Handled: Boolean;
    begin
        CreateRequest('ELIGIBLE_CHECK_CURRENT', TaxFreeUnit, TaxFreeRequest);

        ClearLastError();
        asserterror begin
          OnIsActiveSaleEligible(TaxFreeRequest, SalesTicketNo, Eligible, Handled);
          TaxFreeRequest.Success := true;
          Commit;
          Error('');
        end;

        HandleEventResponse(Handled, TaxFreeUnit, TaxFreeRequest, true);

        exit(Eligible);
    end;

    procedure IsStoredSaleEligible(TaxFreeUnit: Record "Tax Free POS Unit";SalesTicketNo: Code[20]): Boolean
    var
        AuditRoll: Record "Audit Roll";
        TaxFreeRequest: Record "Tax Free Request";
        Eligible: Boolean;
        Handled: Boolean;
    begin
        CreateRequest('ELIGIBLE_CHECK_STORED', TaxFreeUnit, TaxFreeRequest);

        ClearLastError();
        asserterror begin
          OnIsStoredSaleEligible(TaxFreeRequest, SalesTicketNo, Eligible, Handled);
          TaxFreeRequest.Success := true;
          Commit;
          Error('');
        end;

        HandleEventResponse(Handled, TaxFreeUnit, TaxFreeRequest, true);

        exit(Eligible);
    end;

    procedure TryGetActiveVoucherFromReceiptNo(ReceiptNo: Text;var TaxFreeVoucher: Record "Tax Free Voucher"): Boolean
    var
        TaxFreeVoucherSaleLink: Record "Tax Free Voucher Sale Link";
        Result: Boolean;
    begin
        TaxFreeVoucher.SetCurrentKey("External Voucher No.");
        TaxFreeVoucher.SetRange(Void, false);
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", ReceiptNo);
        if TaxFreeVoucherSaleLink.FindSet then repeat
          TaxFreeVoucher.SetRange("Entry No.", TaxFreeVoucherSaleLink."Voucher Entry No.");
          Result := TaxFreeVoucher.FindFirst;
        until (TaxFreeVoucherSaleLink.Next = 0) or Result;
        exit(Result);
    end;

    local procedure "--- Event Publishers"()
    begin
    end;

    local procedure "--- Handler Setup"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupHandler(var HashSet: DotNet HashSet_Of_T)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupHandlerParameters(TaxFreeUnit: Record "Tax Free POS Unit";var Handled: Boolean;var tmpHandlerParameters: Record "Tax Free Handler Parameters" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetUnitParameters(TaxFreeUnit: Record "Tax Free POS Unit";var Handled: Boolean)
    begin
    end;

    local procedure "--- Handler Operations"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUnitAutoConfigure(var TaxFreeRequest: Record "Tax Free Request";Silent: Boolean;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUnitTestConnection(var TaxFreeRequest: Record "Tax Free Request";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnVoucherIssueFromPOSSale(var TaxFreeRequest: Record "Tax Free Request";SalesReceiptNo: Code[20];var Handled: Boolean;var SkipRecordHandling: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnVoucherVoid(var TaxFreeRequest: Record "Tax Free Request";TaxFreeVoucher: Record "Tax Free Voucher";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnVoucherReissue(var TaxFreeRequest: Record "Tax Free Request";TaxFreeVoucher: Record "Tax Free Voucher";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnVoucherLookup(var TaxFreeRequest: Record "Tax Free Request";VoucherNo: Text;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnVoucherPrint(var TaxFreeRequest: Record "Tax Free Request";TaxFreeVoucher: Record "Tax Free Voucher";IsRecentVoucher: Boolean;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnVoucherConsolidate(var TaxFreeRequest: Record "Tax Free Request";var tmpTaxFreeConsolidation: Record "Tax Free Consolidation" temporary;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsValidTerminalIIN(var TaxFreeRequest: Record "Tax Free Request";MaskedCardNo: Text;var IsForeignIIN: Boolean;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsActiveSaleEligible(var TaxFreeRequest: Record "Tax Free Request";SalesTicketNo: Code[20];var Eligible: Boolean;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsStoredSaleEligible(var TaxFreeRequest: Record "Tax Free Request";SalesTicketNo: Code[20];var Eligible: Boolean;var Handled: Boolean)
    begin
    end;

    local procedure "-- Aux"()
    begin
    end;

    local procedure CreateDotNetHashSet(HashSet: DotNet HashSet_Of_T)
    var
        Type: DotNet Type;
        Activator: DotNet Activator;
        Arr: DotNet Array;
        String: DotNet String;
    begin
        Arr := Arr.CreateInstance(GetDotNetType(Type),1);
        Arr.SetValue(GetDotNetType(String),0);

        Type := GetDotNetType(HashSet);
        Type := Type.MakeGenericType(Arr);

        HashSet := Activator.CreateInstance(Type);
    end;

    local procedure CreateAndPrintVoucher(TaxFreeRequest: Record "Tax Free Request";var tmpTaxFreeVoucherSaleLink: Record "Tax Free Voucher Sale Link")
    var
        TaxFreeVoucher: Record "Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "Tax Free Voucher Sale Link";
        TaxFreeLastVoucher: Codeunit "Tax Free Last Voucher Print";
        TempBlob: Record TempBlob temporary;
        TaxFreeUnit: Record "Tax Free POS Unit";
    begin
        TaxFreeUnit.Get(TaxFreeRequest."POS Unit No.");

        with TaxFreeVoucher do begin
          Init;
          "External Voucher Barcode" := TaxFreeRequest."External Voucher Barcode";
          "External Voucher No." := TaxFreeRequest."External Voucher No.";
          "Issued Date" := Today;
          "Issued Time" := Time;
          "Issued By User" := UserId;
          "Print Type" := TaxFreeRequest."Print Type";
          "Total Amount Incl. VAT" := TaxFreeRequest."Total Amount Incl. VAT";
          "Refund Amount" := TaxFreeRequest."Refund Amount";
          "Salesperson Code" := TaxFreeRequest."Salesperson Code";
          "POS Unit No." := TaxFreeRequest."POS Unit No.";
          "Handler ID" := TaxFreeRequest."Handler ID";
          Mode := TaxFreeRequest.Mode;
          "Service ID" := TaxFreeRequest."Service ID";
          if TaxFreeUnit."Store Voucher Prints" then
            Print := TaxFreeRequest.Print;
          Insert(true);
        end;

        tmpTaxFreeVoucherSaleLink.FindSet;
        repeat
          TaxFreeVoucherSaleLink.Init;
          TaxFreeVoucherSaleLink.TransferFields(tmpTaxFreeVoucherSaleLink);
          TaxFreeVoucherSaleLink.Validate("Voucher Entry No.", TaxFreeVoucher."Entry No.");
          TaxFreeVoucherSaleLink.Insert(true);
        until tmpTaxFreeVoucherSaleLink.Next = 0;

        Commit;  //COMMIT data before print is attempted in case of error.

        TempBlob.Blob := TaxFreeRequest.Print;
        TaxFreeLastVoucher.SetVoucher(TaxFreeVoucher."Entry No.", TempBlob, TaxFreeRequest."Print Type");
        VoucherPrintLast();
    end;

    local procedure VoidVoucher(var TaxFreeVoucher: Record "Tax Free Voucher";Silent: Boolean)
    begin
        TaxFreeVoucher.Void := true;
        TaxFreeVoucher."Voided By User" := UserId;
        TaxFreeVoucher."Voided Date" := Today;
        TaxFreeVoucher."Voided Time" := Time;
        TaxFreeVoucher.Modify(true);
        Commit;

        if not Silent then
          Message(Caption_VoidSucces, TaxFreeVoucher."External Voucher No.");
    end;

    local procedure CreateRequest(RequestType: Text;TaxFreeUnit: Record "Tax Free POS Unit";var Request: Record "Tax Free Request"): Boolean
    var
        POSSession: Codeunit "POS Session";
        POSFrontEndManagement: Codeunit "POS Front End Management";
        POSSetup: Codeunit "POS Setup";
    begin
        Request.Init;
        Request."User ID" := UserId;
        Request."Request Type" := RequestType;
        Request."Date Start" := Today;
        Request."Time Start" := Time;
        Request.Mode := TaxFreeUnit.Mode;
        Request."Timeout (ms)" := TaxFreeUnit."Request Timeout (ms)";
        Request."Handler ID" := TaxFreeUnit."Handler ID";
        Request."POS Unit No." := TaxFreeUnit."POS Unit No.";

        if POSSession.IsActiveSession(POSFrontEndManagement) then begin //If the request is being created while logged into POS
          POSFrontEndManagement.GetSession(POSSession);
          POSSession.GetSetup(POSSetup);
          Request."Salesperson Code" := POSSetup.Salesperson;
        end;
    end;

    local procedure HandleEventResponse(EventWasHandled: Boolean;TaxFreeUnit: Record "Tax Free POS Unit";TaxFreeRequest: Record "Tax Free Request";Silent: Boolean)
    var
        ErrorNo: Text;
    begin
        if not EventWasHandled then begin
          TaxFreeRequest."Error Message" := StrSubstNo(Error_MissingHandler, TaxFreeUnit."Handler ID");
          TaxFreeRequest.Success := false;
        end else if not TaxFreeRequest.Success then
          TaxFreeRequest."Error Message" := CopyStr(GetLastErrorText, 1, 250);

        LogEvent(TaxFreeUnit, TaxFreeRequest);

        if (not TaxFreeRequest.Success) and (not Silent) then begin
          if TaxFreeRequest."Error Code" <> '' then
            ErrorNo := StrSubstNo(' - %1: %2', Caption_Code, TaxFreeRequest."Error Code");
          ShowError(TaxFreeRequest."Error Message" + ErrorNo);
        end;
    end;

    local procedure LogEvent(TaxFreeUnit: Record "Tax Free POS Unit";var TaxFreeRequest: Record "Tax Free Request")
    begin
        if TaxFreeUnit."Log Level" = TaxFreeUnit."Log Level"::NONE then
          exit;

        if (TaxFreeUnit."Log Level" = TaxFreeUnit."Log Level"::ERROR) and TaxFreeRequest.Success then
          exit;

        TaxFreeRequest."Date End" := Today;
        TaxFreeRequest."Time End" := Time;
        TaxFreeRequest.Insert(true);

        Commit;
    end;

    local procedure ShowError(ErrorMessage: Text)
    begin
        if StrLen(ErrorMessage) > 0 then
          Message(Error_TaxFreeProcessing + ':\' + ErrorMessage)
        else
          Message(Error_TaxFreeProcessing);
    end;

    local procedure CheckEnvironment(TaxFreeUnit: Record "Tax Free POS Unit"): Boolean
    var
        NPRetailSetup: Record "NP Retail Setup";
    begin
        if TaxFreeUnit.Mode = TaxFreeUnit.Mode::PROD then
          if NPRetailSetup.Get then
            if NPRetailSetup."Environment Type" <> NPRetailSetup."Environment Type"::PROD then
              exit(Confirm(Caption_EnvironmentWarning, false));

        exit(true);
    end;

    local procedure "--- OnFinishSale Workflow"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "POS Sales Workflow Step";RunTrigger: Boolean)
    begin
        //-NPR5.39 [302779]
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
          exit;
        if Rec."Subscriber Function" <>  'IssueTaxFreeVoucherOnSale' then
          exit;

        Rec.Description := Caption_Workflow;
        Rec."Sequence No." := 60;
        //+NPR5.39 [302779]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-NPR5.39 [302779]
        exit(CODEUNIT::"Tax Free Handler Mgt.");
        //+NPR5.39 [302779]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnFinishSale', '', true, true)]
    local procedure IssueTaxFreeVoucherOnSale(POSSalesWorkflowStep: Record "POS Sales Workflow Step";SalePOS: Record "Sale POS")
    var
        AuditRoll: Record "Audit Roll";
        TaxFreeUnit: Record "Tax Free POS Unit";
        TaxFree: Codeunit "Tax Free Handler Mgt.";
    begin
        //-NPR5.39 [302779]
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
          exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'IssueTaxFreeVoucherOnSale' then
          exit;

        AuditRoll.SetRange("Register No.",SalePOS."Register No.");
        AuditRoll.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        if not AuditRoll.FindFirst then
          exit;

        if not SalePOS."Issue Tax Free Voucher" then
          exit;

        if not TaxFreeUnit.Get(SalePOS."Register No.") then
          exit;

        Commit;

        VoucherIssueFromPOSSale(SalePOS."Sales Ticket No.");
        //+NPR5.39 [302779]
    end;
}

