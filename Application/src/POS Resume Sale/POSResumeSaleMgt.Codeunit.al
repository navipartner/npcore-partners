codeunit 6150739 "NPR POS Resume Sale Mgt."
{
    // If you want to overrule/suppress the pop-up windows/questions, create a subscriber.
    // For example, using the following subscriber we can suppress all pop-ups
    // and get all unfinished sales silently cancelled, and, if cancel fails, get them saved as POS Saved Sales:
    //     [EventSubscriber(Codeunit,6150739,OnBeforePromptResumeSale)]
    //     LOCAL PROCEDURE SetSilentlyCancelUnfinishedSale(VAR SalePOS: Record 6014405;POSSession: Codeunit 6150700;VAR SkipDialog: Boolean;VAR ActionOption: ' ,Resume,CancelAndNew,SaveAsQuote';VAR ActionOnCancelError: ' ,Resume,SaveAsQuote,ShowError'; ..
    //     BEGIN
    //       SkipDialog := TRUE;
    //       ActionOption := ActionOption::CancelAndNew;
    //       ActionOnCancelError := ActionOnCancelError::SaveAsQuote;
    //     END;
    // 

    trigger OnRun()
    begin
    end;

    var
        CannotCancelMsg: Label 'This sale cannot be cancelled: %1';
        CannotResumeMsg: Label 'System cannot directly resume selected sale ticket as it was created from another POS unit or on another date.';
        NoInfoProvidedMsg: Label 'The POS sale cancel routine did not provide any additional infromation.';
        POSActionDeleteMsg: Label 'This sales can''t be deleted.';
        ResumedWithNewTicketMsg: Label 'Instead system created a new sale ticket and copied all the information from the old sale.';
        SavedAsQuoteMsg: Label 'The sale was saved as POS Saved Sale No. %1. You can retrieve it from the list of parked sales.';
        SelectAction_InstructionMsg: Label 'Please select what do you want to do with the sale:\\';
        SelectAction_OptionsMsg: Label 'Resume,Park (save as a POS Saved Sale)';
        AltSaleCancelDescription: Text;
        CancelErrorText: Text;

    procedure SelectUnfinishedSaleToResume(var SalePOS: Record "NPR POS Sale"; POSSession: Codeunit "NPR POS Session"; var POSQuoteEntryNo: Integer): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        Setup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(POSUnit);

        SalePOS.FilterGroup(2);
        SalePOS.SetRange("Register No.", Setup.GetPOSUnitNo());
        SalePOS.SetRange("User ID", UserId);
        SalePOS.FilterGroup(0);
        if SalePOS.IsEmpty then
            exit(false);

        SalePOS.FindSet();
        repeat
            SalePOS.Mark(true);
        until SalePOS.Next() = 0;
        SalePOS.MarkedOnly(true);
        exit(SaleToResumeIsSelected(SalePOS, POSUnit, POSSession, POSQuoteEntryNo));
    end;

    local procedure SaleToResumeIsSelected(var SalePOS: Record "NPR POS Sale"; POSUnit: Record "NPR POS Unit"; POSSession: Codeunit "NPR POS Session"; var POSQuoteEntryNo: Integer): Boolean
    var
        ActionOnCancelError: Option " ",Resume,SaveAsQuote,ShowError;
        ActionOption: Option " ",Resume,CancelAndNew,SaveAsQuote,SkipAndNew;
        Confirmed: Boolean;
        ForceSaveAsQuote: Boolean;
        Handled: Boolean;
        SkipDialog: Boolean;
        ConfirmActionCnf: Label 'You have chosen to %1 an existing unfinished sale. The sale was created in another session, which at the moment is still active. Are you sure you want to go on with your selected action? If you do NOT confirm, system will leave the sale intact.';
        ActionOptionLabels: Label 'resume,cancel,save as quote (park)';
    begin
        if SalePOS.IsEmpty then
            exit(false);

        SalePOS.FindFirst();
        if not SalePOS.SalesLinesExist() then begin
            if IsAnotherActiveSessionSale(SalePOS) then
                ActionOption := ActionOption::SkipAndNew  //Leave this empty unfinished sale untouched, because it may have been just started in another active session
            else
                ActionOption := ActionOption::CancelAndNew;  //Silently cancel any unfinished sale with no lines
        end;
        ActionOnCancelError := ActionOnCancelError::SaveAsQuote;

        OnBeforePromptResumeSale(SalePOS, POSSession, SkipDialog, ActionOption, ActionOnCancelError, Handled);
        if Handled then
            exit(ActionOption = ActionOption::Resume);

        if not SkipDialog and (ActionOption = ActionOption::" ") then
            case Page.RunModal(Page::"NPR Unfinished POS Sale", SalePOS) of
                Action::Yes:
                    ActionOption := ActionOption::Resume;
                Action::No:
                    ActionOption := ActionOption::CancelAndNew;
                else
                    Error('');
            end;

        if ActionOption in [ActionOption::Resume, ActionOption::CancelAndNew, ActionOption::SaveAsQuote] then
            if IsAnotherActiveSessionSale(SalePOS) then begin
                Confirmed := SkipDialog;
                if not Confirmed then
                    Confirmed := Confirm(ConfirmActionCnf, false, SelectStr(ActionOption, ActionOptionLabels));
                if not Confirmed then
                    ActionOption := ActionOption::SkipAndNew;
            end;
        if ActionOption = ActionOption::SkipAndNew then begin
            SalePOS.Mark(false);
            ActionOption := ActionOption::" ";
        end;

        CancelErrorText := '';
        if ActionOption = ActionOption::CancelAndNew then begin
            ActionOption := ActionOption::" ";
            if not TryCancelSale(SalePOS, POSSession) then begin
                if ActionOnCancelError = ActionOnCancelError::" " then
                    ActionOnCancelError := StrMenu(SelectAction_OptionsMsg, 1, StrSubstNo(CannotCancelMsg, CancelErrorText) + '\\' + SelectAction_InstructionMsg);
                case ActionOnCancelError of
                    ActionOnCancelError::Resume:
                        ActionOption := ActionOption::Resume;
                    ActionOnCancelError::SaveAsQuote:
                        ActionOption := ActionOption::SaveAsQuote;
                    ActionOnCancelError::ShowError:
                        Error(CannotCancelMsg, CancelErrorText);
                    else
                        Error('');
                end;
            end;
        end;

        //Cannot resume a sale started on other POS Unit or on another date.
        //So it is to be saved as a POS Saved Sale and retrieved from the quote once the new sale start routine is finished
        ForceSaveAsQuote :=
            (ActionOption = ActionOption::Resume) and ((SalePOS.Date <> Today) or (SalePOS."Register No." <> POSUnit."No."));

        if (ActionOption = ActionOption::SaveAsQuote) or ForceSaveAsQuote then begin
            POSQuoteEntryNo := DoSaveAsPOSQuote(POSSession, SalePOS, ForceSaveAsQuote or SkipDialog);
            if not ForceSaveAsQuote then begin
                POSQuoteEntryNo := 0;
                ActionOption := ActionOption::" ";
            end;
        end;

        if ActionOption = ActionOption::" " then
            exit(SaleToResumeIsSelected(SalePOS, POSUnit, POSSession, POSQuoteEntryNo));

        exit(ActionOption = ActionOption::Resume);
    end;

    local procedure IsAnotherActiveSessionSale(SalePOS: Record "NPR POS Sale"): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if (SalePOS."Server Instance ID" = 0) or (SalePOS."User Session ID" = 0) then
            exit(false);
        if not ActiveSession.Get(SalePOS."Server Instance ID", SalePOS."User Session ID") then
            exit(false);
        exit(not ((SalePOS."Server Instance ID" = Database.ServiceInstanceId()) and (SalePOS."User Session ID" = Database.SessionId())));
    end;

    procedure DoSaveAsPOSQuote(POSSession: Codeunit "NPR POS Session"; SalePOS: Record "NPR POS Sale"; SkipDialog: Boolean): Integer
    var
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        POSActionSavePOSQuote: Codeunit "NPR POS Action: SavePOSSvSl";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
    begin
        //Do not save as POS Saved Sales unfinished sales with no lines
        if not SalePOS.SalesLinesExist() then
            SkipDialog := true
        else begin
            POSActionSavePOSQuote.CreatePOSQuote(SalePOS, POSQuoteEntry);
            POSCreateEntry.InsertParkSaleEntry(SalePOS."Register No.", SalePOS."Salesperson Code");
        end;

        SalePOS.Delete(true);
        Commit();

        if not SkipDialog then
            if CancelErrorText <> '' then
                Message('%1\%2', StrSubstNo(CannotCancelMsg, CancelErrorText), StrSubstNo(SavedAsQuoteMsg, POSQuoteEntry."Entry No."))
            else
                Message(SavedAsQuoteMsg, POSQuoteEntry."Entry No.");

        exit(POSQuoteEntry."Entry No.");
    end;

    procedure LoadFromPOSQuote(var SalePOS: Record "NPR POS Sale"; POSQuoteEntryNo: Integer) Success: Boolean
    begin
        Success := DoLoadFromPOSQuote(SalePOS, POSQuoteEntryNo);
        if Success then
            Message(CannotResumeMsg + '\' + ResumedWithNewTicketMsg)
        else
            Message(CannotResumeMsg + '\' + SavedAsQuoteMsg, POSQuoteEntryNo);
    end;

    local procedure DoLoadFromPOSQuote(var SalePOS: Record "NPR POS Sale"; POSQuoteEntryNo: Integer): Boolean
    var
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        POSActionLoadPOSQuote: Codeunit "NPR POS Action: LoadPOSSvSl";
    begin
        if not POSQuoteEntry.Get(POSQuoteEntryNo) then
            exit(false);
        if POSActionLoadPOSQuote.LoadFromQuote(POSQuoteEntry, SalePOS) then begin
            LogSaleResume(SalePOS, POSQuoteEntry."Sales Ticket No.");
            exit(true);
        end else
            exit(false);
    end;

    procedure DoCancelSale(SalePOS: Record "NPR POS Sale"; POSSession: Codeunit "NPR POS Session")
    begin
        CancelErrorText := '';
        if not TryCancelSale(SalePOS, POSSession) then
            Error(CannotCancelMsg, CancelErrorText);
    end;

    local procedure TryCancelSale(SalePOS: Record "NPR POS Sale"; POSSession: Codeunit "NPR POS Session") Success: Boolean
    var
        POSTryCancelSale: Codeunit "NPR POS Try Resume&CancelSale";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        Position: Integer;
    begin
        if SalePOS."NPRE Pre-Set Waiter Pad No." <> '' then begin
            WaiterPadPOSMgt.ClearSaleHdrNPREPresetFields(SalePOS, true);
            Commit();
        end;

        Clear(POSTryCancelSale);
        POSTryCancelSale.Initialize(POSSession);
        POSTryCancelSale.SetAlternativeDescription(AltSaleCancelDescription);
        ClearLastError();
        Success := POSTryCancelSale.Run(SalePOS);
        if not Success then begin
            CancelErrorText := GetLastErrorText;
            Position := StrPos(CancelErrorText, POSActionDeleteMsg);
            if Position <> 0 then
                CancelErrorText := CopyStr(CancelErrorText, StrLen(POSActionDeleteMsg) + 2);
            if CancelErrorText = '' then
                CancelErrorText := NoInfoProvidedMsg;
        end;
    end;

    procedure LogSaleResume(SalePOS: Record "NPR POS Sale"; FromTicketNo: Code[20])
    var
        POSCreateEntry: Codeunit "NPR POS Create Entry";
    begin
        POSCreateEntry.InsertResumeSaleEntry(
          SalePOS."Register No.", SalePOS."Salesperson Code", FromTicketNo, SalePOS."Sales Ticket No.");
    end;

    procedure SetAlternativeCancelDescription(NewAltSaleCancelDescription: Text)
    begin
        AltSaleCancelDescription := NewAltSaleCancelDescription;
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforePromptResumeSale(var SalePOS: Record "NPR POS Sale"; POSSession: Codeunit "NPR POS Session"; var SkipDialog: Boolean; var ActionOption: Option " ",Resume,CancelAndNew,SaveAsQuote; var ActionOnCancelError: Option " ",Resume,SaveAsQuote,ShowError; var Handled: Boolean)
    begin
    end;
}