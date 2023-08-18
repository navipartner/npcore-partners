codeunit 6014610 "NPR Tax Free Handler Mgt."
{
    Access = Internal;
    // All tax free handlers implement the publishers in this codeunit.
    // 
    // Handlers can either use the generic parameter pattern (stored as blob on the specific tax free unit record) or maintain their own parameters elsewhere if too complex.
    // 
    // All generic business logic/flows that is handler independent should be in this codeunit while everything else should be inside each implementation.
    // The most important business records (the actual vouchers with links to receipts/sale docs) are created by this codeunit after handler operation is done.
    // 
    // Commit is used vigorously in this codeunit as it is assumed that handlers are acting on external systems.

    var
        TaxFreeHandlerInterface: Interface "NPR Tax Free Handler IF";
        Error_TaxFreeProcessing: Label 'An error occurred during tax free processing';
        Caption_ExistingVoucherFound: Label 'A tax free voucher already exists for this sale!\Please choose how to proceed:';
        Caption_Cancel: Label 'Cancel (do nothing)';
        Caption_Code: Label 'Code';
        Caption_TestSuccess: Label 'Connection test successful';
        Caption_Workflow: Label 'Issue Tax Free Voucher';
        Error_MissingHandler: Label 'No handler is registered for ID %1';
        Error_NoVoucherInSession: Label 'No recent tax free voucher found for this session';
        Caption_Reissue: Label 'Reissue existing voucher';
        Error_NotEligible: Label 'Sale is not eligible for tax free voucher. VAT amount or sale date is outside the allowed limits.';
        Caption_UnitConfigured: Label 'Tax Free Unit configured';
        Error_VoucherIsVoided: Label 'This voucher has already been voided';
        Caption_Void: Label 'Void existing voucher';
        Caption_VoidSucces: Label 'Voucher %1 was voided successfully';

        #region Replacing assert error
        ConstructorSet: Boolean;
        OnRunFunction: Enum "NPR Tax Free OnRunFunction";
    #endregion
    procedure Constructor(TaxFreeHandlerID: Enum "NPR Tax Free Handler ID")
    begin
        OnBeforeSetConstructor(TaxFreeHandlerInterface, ConstructorSet);
        if ConstructorSet then
            exit;
        TaxFreeHandlerInterface := TaxFreeHandlerID;
        ConstructorSet := true;
    end;

    procedure SetGenericHandlerParameters(TaxFreeProfile: Record "NPR POS Tax Free Profile")
    var
        TempHandlerParameter: Record "NPR Tax Free Handler Param." temporary;
        Handled: Boolean;
        TaxFreeHandlerParameters: Page "NPR Tax Free Gen. Handl. Param";
    begin
        Constructor(TaxFreeProfile."Handler ID Enum");
        TaxFreeHandlerInterface.OnLookupHandlerParameter(TaxFreeProfile, Handled, TempHandlerParameter);
        if not Handled then
            Error(Error_MissingHandler, TaxFreeProfile."Handler ID Enum");

        if TempHandlerParameter.IsEmpty then
            exit;

        if TaxFreeProfile."Handler Parameters".HasValue() then
            TempHandlerParameter.DeserializeParameterBLOB(TaxFreeProfile);

        TaxFreeHandlerParameters.Editable(true);
        TaxFreeHandlerParameters.SetRec(TempHandlerParameter);
        if TaxFreeHandlerParameters.RunModal() <> ACTION::OK then
            exit;

        TaxFreeHandlerParameters.GetRec(TempHandlerParameter);

        TempHandlerParameter.SerializeParameterBLOB(TaxFreeProfile);
        TaxFreeProfile.Modify();
    end;

    #region Tax Free Actions
    procedure SetParameters(TaxFreeProfile: Record "NPR POS Tax Free Profile")
    var
        Handled: Boolean;
    begin
        Constructor(TaxFreeProfile."Handler ID Enum");
        TaxFreeHandlerInterface.OnSetUnitParameters(TaxFreeProfile, Handled);

        if not Handled then
            Error(Error_MissingHandler, TaxFreeProfile."Handler ID Enum");
    end;

    procedure UnitAutoConfigure(TaxFreeProfile: Record "NPR POS Tax Free Profile"; Silent: Boolean)
    var
        TaxFreeRequest: Record "NPR Tax Free Request";
        Handled: Boolean;
    begin
        CreateRequest('UNIT_AUTO_CONFIGURE', TaxFreeProfile, TaxFreeRequest);

        RunUnitAutoConfigureEvent(TaxFreeRequest, Silent, Handled);

        HandleEventResponse(Handled, TaxFreeProfile, TaxFreeRequest, false);

        if (TaxFreeRequest.Success and Handled and (not Silent)) then
            Message(Caption_UnitConfigured);
    end;

    procedure UnitTestConnection(TaxFreeProfile: Record "NPR POS Tax Free Profile")
    var
        Handled: Boolean;
        TaxFreeRequest: Record "NPR Tax Free Request";
        NoTestActionForPremierPi: Label 'Test operation is not supported by tax free handler Premier PI.';
    begin
        if TaxFreeProfile."Handler ID Enum" = TaxFreeProfile."Handler ID Enum"::PREMIER_PI then begin
            Message(NoTestActionForPremierPi);
            exit;
        end;

        CreateRequest('UNIT_TEST_CONN', TaxFreeProfile, TaxFreeRequest);

        RunUnitTestConnectionEvent(TaxFreeRequest, Handled);

        HandleEventResponse(Handled, TaxFreeProfile, TaxFreeRequest, false);

        if (TaxFreeRequest.Success and Handled) then
            Message(Caption_TestSuccess);
    end;

    procedure VoucherIssueFromPOSSale(ReceiptNo: Code[20])
    var
        Handled: Boolean;
        POSEntry: Record "NPR POS Entry";
        TaxFreeProfile: Record "NPR POS Tax Free Profile";
        TaxFreeRequest: Record "NPR Tax Free Request";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        POSUnit: Record "NPR POS Unit";
        "Action": Integer;
        TempTaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link" temporary;
        SkipRecordHandling: Boolean;
        ActionLbl: Label '%1,%2,%3', Locked = true;
    begin
        POSEntry.SetCurrentKey("Document No.");
        POSEntry.SetRange("Document No.", ReceiptNo);
        POSEntry.FindFirst();

        POSUnit.Get(POSEntry."POS Unit No.");
        TaxFreeProfile.Get(POSUnit."POS Tax Free Prof.");

        CreateRequest('VOUCHER_ISSUE', TaxFreeProfile, TaxFreeRequest);

        if TryGetActiveVoucherFromReceiptNo(ReceiptNo, TaxFreeVoucher) then begin //Another voucher is already linked to this receipt, we can't issue a new one.
            Action := StrMenu(StrSubstNo(ActionLbl, Caption_Reissue, Caption_Void, Caption_Cancel), 3, Caption_ExistingVoucherFound);
            case Action of
                1:
                    VoucherReissue(TaxFreeVoucher);
                2:
                    VoucherVoid(TaxFreeVoucher);
            end;
            exit;
        end;

        if not IsStoredSaleEligible(TaxFreeProfile, ReceiptNo) then begin
            TaxFreeRequest."Error Message" := Error_NotEligible;
            LogEvent(TaxFreeProfile, TaxFreeRequest);
            ShowError(Error_NotEligible);
            exit;
        end;

        RunVoucherIssueFromPOSSaleEvent(TaxFreeRequest, ReceiptNo, Handled, SkipRecordHandling);

        HandleEventResponse(Handled, TaxFreeProfile, TaxFreeRequest, false);

        if TaxFreeRequest.Success and (not SkipRecordHandling) then begin
            TempTaxFreeVoucherSaleLink.Init();
            TempTaxFreeVoucherSaleLink."Sales Ticket No." := ReceiptNo;
            TempTaxFreeVoucherSaleLink.Insert();

            CreateAndPrintVoucher(TaxFreeRequest, TempTaxFreeVoucherSaleLink);
        end;
    end;

    procedure VoucherVoid(var TaxFreeVoucher: Record "NPR Tax Free Voucher")
    var
        TaxFreeProfile: Record "NPR POS Tax Free Profile";
        POSUnit: Record "NPR POS Unit";
        Handled: Boolean;
        TaxFreeRequest: Record "NPR Tax Free Request";
    begin
        POSUnit.Get(TaxFreeVoucher."POS Unit No.");
        TaxFreeProfile.Get(POSUnit."POS Tax Free Prof.");

        CreateRequest('VOUCHER_VOID', TaxFreeProfile, TaxFreeRequest);

        TaxFreeRequest."External Voucher Barcode" := TaxFreeVoucher."External Voucher Barcode";
        TaxFreeRequest."External Voucher No." := TaxFreeVoucher."External Voucher No.";

        if TaxFreeVoucher.Void then begin
            TaxFreeRequest."Error Message" := Error_VoucherIsVoided;
            LogEvent(TaxFreeProfile, TaxFreeRequest);
            ShowError(Error_VoucherIsVoided);
            exit;
        end;

        RunVoucherVoidEvent(TaxFreeRequest, TaxFreeVoucher, Handled);

        HandleEventResponse(Handled, TaxFreeProfile, TaxFreeRequest, false);

        if (TaxFreeRequest.Success and Handled) then
            VoidVoucher(TaxFreeVoucher, false);
    end;

    procedure VoucherReissue(var TaxFreeVoucher: Record "NPR Tax Free Voucher")
    var
        Handled: Boolean;
        TaxFreeProfile: Record "NPR POS Tax Free Profile";
        TaxFreeRequest: Record "NPR Tax Free Request";
        TempTaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link" temporary;
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.Get(TaxFreeVoucher."POS Unit No.");
        TaxFreeProfile.Get(POSUnit."POS Tax Free Prof.");

        TaxFreeVoucherSaleLink.SetRange("Voucher Entry No.", TaxFreeVoucher."Entry No.");
        TaxFreeVoucherSaleLink.FindSet();
        repeat
            TempTaxFreeVoucherSaleLink.Init();
            TempTaxFreeVoucherSaleLink.TransferFields(TaxFreeVoucherSaleLink);
            TempTaxFreeVoucherSaleLink.Insert();
        until TaxFreeVoucherSaleLink.Next() = 0;

        CreateRequest('VOUCHER_REISSUE', TaxFreeProfile, TaxFreeRequest);

        TaxFreeRequest."External Voucher Barcode" := TaxFreeVoucher."External Voucher Barcode";
        TaxFreeRequest."External Voucher No." := TaxFreeVoucher."External Voucher No.";

        if TaxFreeVoucher.Void then begin
            TaxFreeRequest."Error Message" := Error_VoucherIsVoided;
            LogEvent(TaxFreeProfile, TaxFreeRequest);
            ShowError(Error_VoucherIsVoided);
            exit;
        end;

        RunVoucherReissueEvent(TaxFreeRequest, TaxFreeVoucher, Handled);

        HandleEventResponse(Handled, TaxFreeProfile, TaxFreeRequest, false);

        if (TaxFreeRequest.Success and Handled) then begin
            VoidVoucher(TaxFreeVoucher, true); //Void old
            CreateAndPrintVoucher(TaxFreeRequest, TempTaxFreeVoucherSaleLink); //Create & print new
        end;
    end;

    procedure VoucherLookup(TaxFreeProfile: Record "NPR POS Tax Free Profile"; VoucherNo: Text)
    var
        Handled: Boolean;
        TaxFreeRequest: Record "NPR Tax Free Request";
    begin
        CreateRequest('VOUCHER_LOOKUP', TaxFreeProfile, TaxFreeRequest);

        RunVoucherLookupEvent(TaxFreeRequest, Handled);

        HandleEventResponse(Handled, TaxFreeProfile, TaxFreeRequest, false);
    end;

    procedure VoucherPrint(TaxFreeVoucher: Record "NPR Tax Free Voucher")
    var
        Handled: Boolean;
        TaxFreeProfile: Record "NPR POS Tax Free Profile";
        TaxFreeRequest: Record "NPR Tax Free Request";
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.Get(TaxFreeVoucher."POS Unit No.");
        TaxFreeProfile.Get(POSUnit."POS Tax Free Prof.");
        CreateRequest('VOUCHER_PRINT', TaxFreeProfile, TaxFreeRequest);

        if TaxFreeVoucher.Void then begin
            TaxFreeRequest."Error Message" := Error_VoucherIsVoided;
            LogEvent(TaxFreeProfile, TaxFreeRequest);
            ShowError(Error_VoucherIsVoided);
            exit;
        end;

        TaxFreeVoucher.CalcFields(Print);
        TaxFreeRequest.Print := TaxFreeVoucher.Print;
        TaxFreeRequest."Print Type" := TaxFreeVoucher."Print Type";

        RunVoucherPrintEvent(TaxFreeRequest, TaxFreeVoucher, false, Handled);

        HandleEventResponse(Handled, TaxFreeProfile, TaxFreeRequest, false);
    end;

    procedure VoucherPrintLast()
    var
        TaxFreeLastPrint: Codeunit "NPR TaxFree LastVouch.Print";
        VoucherEntryNo: Integer;
        TempBlob: Codeunit "Temp Blob";
        PrintType: Integer;
        Handled: Boolean;
        TaxFreeRequest: Record "NPR Tax Free Request";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeProfile: Record "NPR POS Tax Free Profile";
        POSUnit: Record "NPR POS Unit";
        RecRef: RecordRef;
    begin
        //Single instance codeunit contains the last tax free voucher from this user session - for integrations where you should not always be able to re-print any voucher, only the recent last.
        if not TaxFreeLastPrint.GetVoucher(VoucherEntryNo, TempBlob, PrintType) then
            Error(Error_NoVoucherInSession);

        TaxFreeVoucher.Get(VoucherEntryNo);
        POSUnit.Get(TaxFreeVoucher."POS Unit No.");
        TaxFreeProfile.Get(POSUnit."POS Tax Free Prof.");

        CreateRequest('VOUCHER_PRINT_LAST', TaxFreeProfile, TaxFreeRequest);

        if TaxFreeVoucher.Void then begin
            TaxFreeRequest."Error Message" := Error_VoucherIsVoided;
            LogEvent(TaxFreeProfile, TaxFreeRequest);
            ShowError(Error_VoucherIsVoided);
            exit;
        end;

        RecRef.GetTable(TaxFreeRequest);
        TempBlob.ToRecordRef(RecRef, TaxFreeRequest.FieldNo(Print));
        RecRef.SetTable(TaxFreeRequest);

        TaxFreeRequest."Print Type" := PrintType;

        RunVoucherPrintEvent(TaxFreeRequest, TaxFreeVoucher, true, Handled);

        HandleEventResponse(Handled, TaxFreeProfile, TaxFreeRequest, false);
    end;

    procedure VoucherConsolidate(TaxFreeProfile: Record "NPR POS Tax Free Profile"; var tmpTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary)
    var
        Handled: Boolean;
        TaxFreeRequest: Record "NPR Tax Free Request";
        TempTaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link" temporary;
    begin
        CreateRequest('VOUCHER_CONSOLIDATE', TaxFreeProfile, TaxFreeRequest);

        if not tmpTaxFreeConsolidation.FindSet() then
            exit;

        if tmpTaxFreeConsolidation.Count() = 1 then begin //Normal voucher issue flow instead.
            VoucherIssueFromPOSSale(tmpTaxFreeConsolidation."Sales Ticket No.");
            exit;
        end;

        RunVoucherConsolidateEvent(TaxFreeRequest, tmpTaxFreeConsolidation, Handled);

        HandleEventResponse(Handled, TaxFreeProfile, TaxFreeRequest, false);

        if TaxFreeRequest.Success then begin
            tmpTaxFreeConsolidation.FindSet();
            repeat
                TempTaxFreeVoucherSaleLink.Init();
                TempTaxFreeVoucherSaleLink."Sales Ticket No." := tmpTaxFreeConsolidation."Sales Ticket No.";
                TempTaxFreeVoucherSaleLink."Sales Header No." := tmpTaxFreeConsolidation."Sales Header No.";
                TempTaxFreeVoucherSaleLink."Sales Header Type" := tmpTaxFreeConsolidation."Sales Header Type";
                TempTaxFreeVoucherSaleLink.Insert();
            until tmpTaxFreeConsolidation.Next() = 0;

            CreateAndPrintVoucher(TaxFreeRequest, TempTaxFreeVoucherSaleLink);
        end;
    end;

    procedure IsValidTerminalIIN(TaxFreeProfile: Record "NPR POS Tax Free Profile"; MaskedCardNo: Text): Boolean
    var
        Handled: Boolean;
        Valid: Boolean;
        TaxFreeRequest: Record "NPR Tax Free Request";
    begin
        if not TaxFreeProfile."Check POS Terminal IIN" then
            exit(false);

        CreateRequest('TERMINAL_IIN_CHECK', TaxFreeProfile, TaxFreeRequest);

        RunIsValidTerminalIINEvent(TaxFreeRequest, MaskedCardNo, Valid, Handled);

        HandleEventResponse(Handled, TaxFreeProfile, TaxFreeRequest, true);

        exit(Valid);
    end;

    procedure IsActiveSaleEligible(TaxFreeProfile: Record "NPR POS Tax Free Profile"; SalesTicketNo: Code[20]): Boolean
    var
        TaxFreeRequest: Record "NPR Tax Free Request";
        Eligible: Boolean;
        Handled: Boolean;
    begin
        CreateRequest('ELIGIBLE_CHECK_CURRENT', TaxFreeProfile, TaxFreeRequest);

        RunIsActiveSaleEligibleEvent(TaxFreeRequest, SalesTicketNo, Eligible, Handled);

        HandleEventResponse(Handled, TaxFreeProfile, TaxFreeRequest, true);

        exit(Eligible);
    end;

    procedure IsStoredSaleEligible(TaxFreeProfile: Record "NPR POS Tax Free Profile"; SalesTicketNo: Code[20]): Boolean
    var
        TaxFreeRequest: Record "NPR Tax Free Request";
        Eligible: Boolean;
        Handled: Boolean;
    begin
        CreateRequest('ELIGIBLE_CHECK_STORED', TaxFreeProfile, TaxFreeRequest);

        RunIsStoredSaleEligibleEvent(TaxFreeRequest, SalesTicketNo, Eligible, Handled);

        HandleEventResponse(Handled, TaxFreeProfile, TaxFreeRequest, true);

        exit(Eligible);
    end;

    procedure TryGetActiveVoucherFromReceiptNo(ReceiptNo: Text; var TaxFreeVoucher: Record "NPR Tax Free Voucher"): Boolean
    var
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        Result: Boolean;
    begin
        TaxFreeVoucher.SetCurrentKey("External Voucher No.");
        TaxFreeVoucher.SetRange(Void, false);
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", ReceiptNo);
        if TaxFreeVoucherSaleLink.FindSet() then
            repeat
                TaxFreeVoucher.SetRange("Entry No.", TaxFreeVoucherSaleLink."Voucher Entry No.");
                Result := TaxFreeVoucher.FindFirst();
            until (TaxFreeVoucherSaleLink.Next() = 0) or Result;
        exit(Result);
    end;

    #endregion
    #region Event Publishers
    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetConstructor(var TaxFreeHandlerIfaceIn: Interface "NPR Tax Free Handler IF"; var ConstrSet: Boolean)
    begin
    end;
    #endregion
    #region Aux
    local procedure CreateAndPrintVoucher(TaxFreeRequest: Record "NPR Tax Free Request"; var tmpTaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link")
    var
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        TaxFreeLastVoucher: Codeunit "NPR TaxFree LastVouch.Print";
        TempBlob: Codeunit "Temp Blob";
        TaxFreeProfile: Record "NPR POS Tax Free Profile";
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.Get(TaxFreeRequest."POS Unit No.");
        TaxFreeProfile.Get(POSUnit."POS Tax Free Prof.");
        TaxFreeVoucher.Init();
#pragma warning disable AA0139
        TaxFreeVoucher."External Voucher Barcode" := TaxFreeRequest."External Voucher Barcode";
        TaxFreeVoucher."External Voucher No." := TaxFreeRequest."External Voucher No.";
#pragma warning restore AA0139        
        TaxFreeVoucher."Issued Date" := Today();
        TaxFreeVoucher."Issued Time" := Time;
#pragma warning disable AA0139        
        TaxFreeVoucher."Issued By User" := UserId;
#pragma warning restore AA0139        
        TaxFreeVoucher."Print Type" := TaxFreeRequest."Print Type";
        TaxFreeVoucher."Total Amount Incl. VAT" := TaxFreeRequest."Total Amount Incl. VAT";
        TaxFreeVoucher."Refund Amount" := TaxFreeRequest."Refund Amount";
        TaxFreeVoucher."Salesperson Code" := TaxFreeRequest."Salesperson Code";
        TaxFreeVoucher."POS Unit No." := TaxFreeRequest."POS Unit No.";
        TaxFreeVoucher."Handler ID Enum" := TaxFreeRequest."Handler ID Enum";
        TaxFreeVoucher.Mode := TaxFreeRequest.Mode;
        TaxFreeVoucher."Service ID" := TaxFreeRequest."Service ID";
        if TaxFreeProfile."Store Voucher Prints" then
            TaxFreeVoucher.Print := TaxFreeRequest.Print;
        TaxFreeVoucher.Insert(true);

        tmpTaxFreeVoucherSaleLink.FindSet();
        repeat
            TaxFreeVoucherSaleLink.Init();
            TaxFreeVoucherSaleLink.TransferFields(tmpTaxFreeVoucherSaleLink);
            TaxFreeVoucherSaleLink.Validate("Voucher Entry No.", TaxFreeVoucher."Entry No.");
            TaxFreeVoucherSaleLink.Insert(true);
        until tmpTaxFreeVoucherSaleLink.Next() = 0;

        Commit();  //COMMIT data before print is attempted in case of error.

        TempBlob.FromRecord(TaxFreeRequest, TaxFreeRequest.FieldNo(Print));
        TaxFreeLastVoucher.SetVoucher(TaxFreeVoucher."Entry No.", TempBlob, TaxFreeRequest."Print Type");
        VoucherPrintLast();
    end;

    local procedure VoidVoucher(var TaxFreeVoucher: Record "NPR Tax Free Voucher"; Silent: Boolean)
    begin
        TaxFreeVoucher.Void := true;
#pragma warning disable AA0139        
        TaxFreeVoucher."Voided By User" := UserId;
#pragma warning restore AA0139        
        TaxFreeVoucher."Voided Date" := Today();
        TaxFreeVoucher."Voided Time" := Time;
        TaxFreeVoucher.Modify(true);
        Commit();

        if not Silent then
            Message(Caption_VoidSucces, TaxFreeVoucher."External Voucher No.");
    end;

    local procedure CreateRequest(RequestType: Text[30]; TaxFreeProfile: Record "NPR POS Tax Free Profile"; var Request: Record "NPR Tax Free Request"): Boolean
    var
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        Request.Init();
#pragma warning disable AA0139        
        Request."User ID" := UserId;
#pragma warning restore AA0139        
        Request."Request Type" := RequestType;
        Request."Date Start" := Today();
        Request."Time Start" := Time;
        Request.Mode := TaxFreeProfile.Mode;
        Request."Timeout (ms)" := TaxFreeProfile."Request Timeout (ms)";
        Request."Handler ID Enum" := TaxFreeProfile."Handler ID Enum";
        Request."Tax Free Profile" := TaxFreeProfile."Tax Free Profile";

        if POSSession.IsActiveSession(POSFrontEndManagement) then begin //If the request is being created while logged into POS
            POSFrontEndManagement.GetSession(POSSession);
            POSSession.GetSetup(POSSetup);
            Request."Salesperson Code" := POSSetup.Salesperson();
            Request."POS Unit No." := POSSetup.GetPOSUnitNo();
        end;
    end;

    local procedure HandleEventResponse(EventWasHandled: Boolean; TaxFreeProfile: Record "NPR POS Tax Free Profile"; TaxFreeRequest: Record "NPR Tax Free Request"; Silent: Boolean)
    var
        ErrorNo: Text;
        TaxFreeReqLbl: Label ' - %1: %2', Locked = true;
    begin
        if not EventWasHandled then begin
            TaxFreeRequest."Error Message" := StrSubstNo(Error_MissingHandler, TaxFreeProfile."Handler ID Enum");
            TaxFreeRequest.Success := false;
        end else
            if not TaxFreeRequest.Success then
                TaxFreeRequest."Error Message" := CopyStr(GetLastErrorText, 1, 250);

        LogEvent(TaxFreeProfile, TaxFreeRequest);

        if (not TaxFreeRequest.Success) and (not Silent) then begin
            if TaxFreeRequest."Error Code" <> '' then
                ErrorNo := StrSubstNo(TaxFreeReqLbl, Caption_Code, TaxFreeRequest."Error Code");
            ShowError(TaxFreeRequest."Error Message" + ErrorNo);
        end;
    end;

    local procedure LogEvent(TaxFreeProfile: Record "NPR POS Tax Free Profile"; var TaxFreeRequest: Record "NPR Tax Free Request")
    begin
        if TaxFreeProfile."Log Level" = TaxFreeProfile."Log Level"::NONE then
            exit;

        if (TaxFreeProfile."Log Level" = TaxFreeProfile."Log Level"::ERROR) and TaxFreeRequest.Success then
            exit;

        TaxFreeRequest."Date End" := Today();
        TaxFreeRequest."Time End" := Time;
        TaxFreeRequest.Insert(true);

        Commit();
    end;

    local procedure ShowError(ErrorMessage: Text)
    begin
        if StrLen(ErrorMessage) > 0 then
            Message(Error_TaxFreeProcessing + ':\' + ErrorMessage)
        else
            Message(Error_TaxFreeProcessing);
    end;
    #endregion
    #region OnFinishSale Workflow

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if Rec."Subscriber Function" <> 'IssueTaxFreeVoucherOnSale' then
            exit;

        Rec.Description := Caption_Workflow;
        Rec."Sequence No." := 60;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Tax Free Handler Mgt.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnFinishSale', '', true, true)]
    local procedure IssueTaxFreeVoucherOnSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR POS Sale")
    var
        POSEntry: Record "NPR POS Entry";
        TaxFreeProfile: Record "NPR POS Tax Free Profile";
        POSUnit: Record "NPR POS Unit";
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'IssueTaxFreeVoucherOnSale' then
            exit;

        POSEntry.SetRange("POS Unit No.", SalePOS."Register No.");
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        if not POSEntry.FindFirst() then
            exit;

        if not SalePOS."Issue Tax Free Voucher" then
            exit;

        POSUnit.Get(POSEntry."POS Unit No.");
        if not TaxFreeProfile.Get(POSUnit."POS Tax Free Prof.") then
            exit;
        ;

        Commit();

        VoucherIssueFromPOSSale(SalePOS."Sales Ticket No.");
    end;
    #endregion

    #region assert error replacement functions
    local procedure RunUnitAutoConfigureEvent(var TaxFreeRequest: Record "NPR Tax Free Request"; Silent: Boolean; var Handled: Boolean)
    var
        TaxFreeExecute: Codeunit "NPR Tax Free Execute";
    begin
        Commit();

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, true);
        TaxFreeExecute.OnRunHandledGetSet(Handled, true);
        TaxFreeExecute.OnRunSilentSet(Silent);

        TaxFreeExecute.OnRunFunctionSet(OnRunFunction::UnitAutoConfigure);

        Constructor(TaxFreeRequest."Handler ID Enum");
        TaxFreeExecute.TaxFreeHandlerInterfaceSet(TaxFreeHandlerInterface);

        TaxFreeExecute.OnRunTaxFreeRequestSuccessSet(TaxFreeExecute.Run());

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, false);
        TaxFreeExecute.OnRunHandledGetSet(Handled, false);
    end;

    local procedure RunUnitTestConnectionEvent(var TaxFreeRequest: Record "NPR Tax Free Request"; var Handled: Boolean)
    var
        TaxFreeExecute: Codeunit "NPR Tax Free Execute";
    begin
        Commit();

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, true);
        TaxFreeExecute.OnRunHandledGetSet(Handled, true);
        TaxFreeExecute.OnRunFunctionSet(OnRunFunction::UnitTestConnection);

        Constructor(TaxFreeRequest."Handler ID Enum");
        TaxFreeExecute.TaxFreeHandlerInterfaceSet(TaxFreeHandlerInterface);

        TaxFreeExecute.OnRunTaxFreeRequestSuccessSet(TaxFreeExecute.Run());

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, false);
        TaxFreeExecute.OnRunHandledGetSet(Handled, false);
    end;

    local procedure RunVoucherIssueFromPOSSaleEvent(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesReceiptNo: Code[20]; var Handled: Boolean; var SkipRecordHandling: Boolean)
    var
        TaxFreeExecute: Codeunit "NPR Tax Free Execute";
    begin
        Commit();

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, true);
        TaxFreeExecute.OnRunHandledGetSet(Handled, true);
        TaxFreeExecute.OnRunFunctionSet(OnRunFunction::VoucherIssueFromPOSSale);
        TaxFreeExecute.OnRunSalesReceiptNoSet(SalesReceiptNo);
        TaxFreeExecute.OnRunSkipRecordHandlingGetSet(SkipRecordHandling, true);

        Constructor(TaxFreeRequest."Handler ID Enum");
        TaxFreeExecute.TaxFreeHandlerInterfaceSet(TaxFreeHandlerInterface);

        TaxFreeExecute.OnRunTaxFreeRequestSuccessSet(TaxFreeExecute.Run());

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, false);
        TaxFreeExecute.OnRunHandledGetSet(Handled, false);
        TaxFreeExecute.OnRunSkipRecordHandlingGetSet(SkipRecordHandling, false);
    end;

    local procedure RunVoucherVoidEvent(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher"; var Handled: Boolean)
    var
        TaxFreeExecute: Codeunit "NPR Tax Free Execute";
    begin
        Commit();

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, true);
        TaxFreeExecute.OnRunTaxFreeVoucherGetSet(TaxFreeVoucher, true);
        TaxFreeExecute.OnRunHandledGetSet(Handled, true);
        TaxFreeExecute.OnRunFunctionSet(OnRunFunction::VoucherVoid);

        Constructor(TaxFreeRequest."Handler ID Enum");
        TaxFreeExecute.TaxFreeHandlerInterfaceSet(TaxFreeHandlerInterface);

        TaxFreeExecute.OnRunTaxFreeRequestSuccessSet(TaxFreeExecute.Run());

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, false);
        TaxFreeExecute.OnRunHandledGetSet(Handled, false);
    end;

    local procedure RunVoucherReissueEvent(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher"; var Handled: Boolean)
    var
        TaxFreeExecute: Codeunit "NPR Tax Free Execute";
    begin
        Commit();

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, true);
        TaxFreeExecute.OnRunTaxFreeVoucherGetSet(TaxFreeVoucher, true);
        TaxFreeExecute.OnRunHandledGetSet(Handled, true);
        TaxFreeExecute.OnRunFunctionSet(OnRunFunction::VoucherReissue);

        Constructor(TaxFreeRequest."Handler ID Enum");
        TaxFreeExecute.TaxFreeHandlerInterfaceSet(TaxFreeHandlerInterface);

        TaxFreeExecute.OnRunTaxFreeRequestSuccessSet(TaxFreeExecute.Run());

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, false);
        TaxFreeExecute.OnRunHandledGetSet(Handled, false);
    end;

    local procedure RunVoucherLookupEvent(var TaxFreeRequest: Record "NPR Tax Free Request"; var Handled: Boolean)
    var
        TaxFreeExecute: Codeunit "NPR Tax Free Execute";
    begin
        Commit();

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, true);
        TaxFreeExecute.OnRunHandledGetSet(Handled, true);
        TaxFreeExecute.OnRunFunctionSet(OnRunFunction::VoucherLookup);

        Constructor(TaxFreeRequest."Handler ID Enum");
        TaxFreeExecute.TaxFreeHandlerInterfaceSet(TaxFreeHandlerInterface);

        TaxFreeExecute.OnRunTaxFreeRequestSuccessSet(TaxFreeExecute.Run());

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, false);
        TaxFreeExecute.OnRunHandledGetSet(Handled, false);
    end;


    local procedure RunVoucherPrintEvent(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher"; IsRecentVoucher: Boolean; var Handled: Boolean)
    var
        TaxFreeExecute: Codeunit "NPR Tax Free Execute";
    begin
        Commit();

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, true);
        TaxFreeExecute.OnRunTaxFreeVoucherGetSet(TaxFreeVoucher, true);
        TaxFreeExecute.OnRunHandledGetSet(Handled, true);
        TaxFreeExecute.OnRunFunctionSet(OnRunFunction::VoucherPrint);
        TaxFreeExecute.OnRunIsrecentVoucherSet(IsRecentVoucher);

        Constructor(TaxFreeRequest."Handler ID Enum");
        TaxFreeExecute.TaxFreeHandlerInterfaceSet(TaxFreeHandlerInterface);

        TaxFreeExecute.OnRunTaxFreeRequestSuccessSet(TaxFreeExecute.Run());

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, false);
        TaxFreeExecute.OnRunHandledGetSet(Handled, false);
    end;

    local procedure RunVoucherConsolidateEvent(var TaxFreeRequest: Record "NPR Tax Free Request"; var tmpTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary; var Handled: Boolean)
    var
        TaxFreeExecute: Codeunit "NPR Tax Free Execute";
    begin
        Commit();

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, true);
        TaxFreeExecute.OnRunHandledGetSet(Handled, true);
        TaxFreeExecute.OnRunFunctionSet(OnRunFunction::VoucherConsolidate);
        TaxFreeExecute.OnRunTmpTaxFreeConsolidationGetSet(tmpTaxFreeConsolidation, true);

        Constructor(TaxFreeRequest."Handler ID Enum");
        TaxFreeExecute.TaxFreeHandlerInterfaceSet(TaxFreeHandlerInterface);

        TaxFreeExecute.OnRunTaxFreeRequestSuccessSet(TaxFreeExecute.Run());

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, false);

        TmpTaxFreeConsolidation.reset();
        If (TmpTaxFreeConsolidation.IsTemporary()) then
            TmpTaxFreeConsolidation.DeleteAll();

        TaxFreeExecute.OnRunTmpTaxFreeConsolidationGetSet(tmpTaxFreeConsolidation, true);

        TaxFreeExecute.OnRunHandledGetSet(Handled, false);
    end;

    local procedure RunIsValidTerminalIINEvent(var TaxFreeRequest: Record "NPR Tax Free Request"; MaskedCardNo: Text; var IsForeignIIN: Boolean; var Handled: Boolean)
    var
        TaxFreeExecute: Codeunit "NPR Tax Free Execute";
    begin
        Commit();

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, true);
        TaxFreeExecute.OnRunHandledGetSet(Handled, true);
        TaxFreeExecute.OnRunFunctionSet(OnRunFunction::IsValidTerminalIIN);
        TaxFreeExecute.OnRunMaskedCardNoSet(MaskedCardNo);
        TaxFreeExecute.OnRunIsForeignIINGetSet(IsForeignIIN, true);

        Constructor(TaxFreeRequest."Handler ID Enum");
        TaxFreeExecute.TaxFreeHandlerInterfaceSet(TaxFreeHandlerInterface);

        TaxFreeExecute.OnRunTaxFreeRequestSuccessSet(TaxFreeExecute.Run());

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, false);
        TaxFreeExecute.OnRunIsForeignIINGetSet(IsForeignIIN, false);
        TaxFreeExecute.OnRunHandledGetSet(Handled, false);
    end;

    local procedure RunIsStoredSaleEligibleEvent(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesTicketNo: Code[20]; var Eligible: Boolean; var Handled: Boolean)
    var
        TaxFreeExecute: Codeunit "NPR Tax Free Execute";
    begin
        Commit();

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, true);
        TaxFreeExecute.OnRunHandledGetSet(Handled, true);
        TaxFreeExecute.OnRunFunctionSet(OnRunFunction::IsStoredSaleEligible);
        TaxFreeExecute.OnRunSalesReceiptNoSet(SalesTicketNo);
        TaxFreeExecute.OnRunEligibleGetSet(Eligible, true);

        Constructor(TaxFreeRequest."Handler ID Enum");
        TaxFreeExecute.TaxFreeHandlerInterfaceSet(TaxFreeHandlerInterface);

        TaxFreeExecute.OnRunTaxFreeRequestSuccessSet(TaxFreeExecute.Run());

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, false);
        TaxFreeExecute.OnRunEligibleGetSet(Eligible, false);
        TaxFreeExecute.OnRunHandledGetSet(Handled, false);
    end;

    local procedure RunIsActiveSaleEligibleEvent(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesTicketNo: Code[20]; var Eligible: Boolean; var Handled: Boolean)
    var
        TaxFreeExecute: Codeunit "NPR Tax Free Execute";
    begin
        Commit();

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, true);
        TaxFreeExecute.OnRunHandledGetSet(Handled, true);
        TaxFreeExecute.OnRunFunctionSet(OnRunFunction::IsActiveSaleEligible);
        TaxFreeExecute.OnRunSalesReceiptNoSet(SalesTicketNo);
        TaxFreeExecute.OnRunEligibleGetSet(Eligible, true);

        Constructor(TaxFreeRequest."Handler ID Enum");
        TaxFreeExecute.TaxFreeHandlerInterfaceSet(TaxFreeHandlerInterface);

        TaxFreeExecute.OnRunTaxFreeRequestSuccessSet(TaxFreeExecute.Run());

        TaxFreeExecute.OnRunTaxFreeRequestGetSet(TaxFreeRequest, false);
        TaxFreeExecute.OnRunEligibleGetSet(Eligible, false);
        TaxFreeExecute.OnRunHandledGetSet(Handled, false);
    end;

    #endregion
}
