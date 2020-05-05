codeunit 6150739 "POS Resume Sale Mgt."
{
    // If you want to overrule/suppress the pop-up windows/questions, create a subscriber.
    // For example, using the following subscriber we can suppress all pop-ups
    // and get all unfinished sales silently cancelled, and, if cancel fails, get them saved as POS quotes:
    //     [EventSubscriber(Codeunit,6150739,OnBeforePromptResumeSale)]
    //     LOCAL PROCEDURE SetSilentlyCancelUnfinishedSale(VAR SalePOS: Record 6014405;POSSession: Codeunit 6150700;VAR SkipDialog: Boolean;VAR ActionOption: ' ,Resume,CancelAndNew,SaveAsQuote';VAR ActionOnCancelError: ' ,Resume,SaveAsQuote,ShowError'; ..
    //     BEGIN
    //       SkipDialog := TRUE;
    //       ActionOption := ActionOption::CancelAndNew;
    //       ActionOnCancelError := ActionOnCancelError::SaveAsQuote;
    //     END;
    // 
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale


    trigger OnRun()
    begin
    end;

    var
        CannotCancelMsg: Label 'This sale cannot be cancelled: %1';
        CannotResumeMsg: Label 'System cannot directly resume selected sale ticket as it was created from another POS unit or on another date.';
        NoInfoProvidedMsg: Label 'The POS sale cancel routine did not provide any additional infromation.';
        POSActionDeleteMsg: Label 'This sales can''t be deleted.';
        ResumedWithNewTicketMsg: Label 'Instead system created a new sale ticket and copied all the information from the old sale.';
        SavedAsQuoteMsg: Label 'The sale was saved as POS quote No. %1. You can retrieve it from the list of parked sales.';
        SelectAction_InstructionMsg: Label 'Please select what do you want to do with the sale:\\';
        SelectAction_OptionsMsg: Label 'Resume,Park (save as a POS quote)';
        CancelErrorText: Text;

    procedure SelectUnfinishedSaleToResume(var SalePOS: Record "Sale POS";POSSession: Codeunit "POS Session";var POSQuoteEntryNo: Integer): Boolean
    var
        POSUnit: Record "POS Unit";
        POSUnitIdentity: Record "POS Unit Identity";
        Setup: Codeunit "POS Setup";
    begin
        POSSession.GetSetup(Setup);
        Setup.GetPOSUnitIdentity(POSUnitIdentity);
        Setup.GetPOSUnit(POSUnit);

        SalePOS.FilterGroup(2);
        SalePOS.SetRange("Register No.",Setup.Register);
        SalePOS.FilterGroup(0);
        //SalePOS.SETRANGE("Salesperson Code",Setup.Salesperson());
        if POSUnitIdentity."Entry No." = 0 then
          SalePOS.SetRange("Device ID",'')  //Configured using temporary pos unit identity
        else
          SalePOS.SetRange("Device ID",POSUnitIdentity."Device ID");
        SalePOS.SetRange("Host Name",POSUnitIdentity."Host Name");
        if (POSUnitIdentity."Session Type" in [POSUnitIdentity."Session Type"::RemoteDesktop,POSUnitIdentity."Session Type"::Citrix]) or
           (POSUnitIdentity."Host Name" = '')  //Connected from web browser
        then
          SalePOS.SetRange("User ID",POSUnitIdentity."User ID");
        exit(SaleToResumeIsSelected(SalePOS,POSUnit,POSSession,POSQuoteEntryNo));
    end;

    local procedure SaleToResumeIsSelected(var SalePOS: Record "Sale POS";POSUnit: Record "POS Unit";POSSession: Codeunit "POS Session";var POSQuoteEntryNo: Integer): Boolean
    var
        ActionOnCancelError: Option " ",Resume,SaveAsQuote,ShowError;
        ActionOption: Option " ",Resume,CancelAndNew,SaveAsQuote;
        ForceSaveAsQuote: Boolean;
        Handled: Boolean;
        SkipDialog: Boolean;
    begin
        if SalePOS.IsEmpty then
          exit(false);

        SalePOS.FindFirst;
        if not SalePOS.SalesLinesExist then
          ActionOption := ActionOption::CancelAndNew;  //Silently cancel any unfinished sale with no lines
        ActionOnCancelError := ActionOnCancelError::SaveAsQuote;

        OnBeforePromptResumeSale(SalePOS,POSSession,SkipDialog,ActionOption,ActionOnCancelError,Handled);
        if Handled then
          exit(ActionOption = ActionOption::Resume);

        if not SkipDialog and (ActionOption = ActionOption::" ") then
          case PAGE.RunModal(PAGE::"Unfinished POS Sale",SalePOS) of
            ACTION::Yes: ActionOption := ActionOption::Resume;
            ACTION::No: ActionOption := ActionOption::CancelAndNew;
            else
              Error('');
          end;

        CancelErrorText := '';
        if ActionOption = ActionOption::CancelAndNew then begin
          ActionOption := ActionOption::" ";
          if not TryCancelSale(SalePOS,POSSession) then begin
            if ActionOnCancelError = ActionOnCancelError::" " then
              ActionOnCancelError := StrMenu(SelectAction_OptionsMsg,1,StrSubstNo(CannotCancelMsg,CancelErrorText) + '\\' + SelectAction_InstructionMsg);
            case ActionOnCancelError of
              ActionOnCancelError::Resume:
                ActionOption := ActionOption::Resume;
              ActionOnCancelError::SaveAsQuote:
                ActionOption := ActionOption::SaveAsQuote;
              ActionOnCancelError::ShowError:
                Error(CannotCancelMsg,CancelErrorText);
              else
                Error('');
            end;
          end;
        end;

        //Cannot resume a sale started on other POS Unit or on another date.
        //So it is to be saved as a POS Quote and retrieved from the quote once the new sale start routine is finished
        ForceSaveAsQuote :=
          (ActionOption = ActionOption::Resume) and ((SalePOS.Date <> Today) or (SalePOS."Register No." <>  POSUnit."No."));

        if (ActionOption = ActionOption::SaveAsQuote) or ForceSaveAsQuote then begin
          POSQuoteEntryNo := DoSaveAsPOSQuote(SalePOS,ForceSaveAsQuote or SkipDialog);
          if not ForceSaveAsQuote then begin
            POSQuoteEntryNo := 0;
            ActionOption := ActionOption::" ";
          end;
        end;

        if ActionOption = ActionOption::" " then
          exit(SaleToResumeIsSelected(SalePOS,POSUnit,POSSession,POSQuoteEntryNo));

        exit(ActionOption = ActionOption::Resume);
    end;

    procedure DoSaveAsPOSQuote(SalePOS: Record "Sale POS";SkipDialog: Boolean): Integer
    var
        POSQuoteEntry: Record "POS Quote Entry";
        POSActionSavePOSQuote: Codeunit "POS Action - Save POS Quote";
    begin
        POSActionSavePOSQuote.CreatePOSQuote(SalePOS,POSQuoteEntry);
        Commit;

        if not SkipDialog then
          if CancelErrorText <> '' then
            Message('%1\%2',StrSubstNo(CannotCancelMsg,CancelErrorText),StrSubstNo(SavedAsQuoteMsg, POSQuoteEntry."Entry No."))
          else
            Message(SavedAsQuoteMsg, POSQuoteEntry."Entry No.");

        exit(POSQuoteEntry."Entry No.");
    end;

    procedure LoadFromPOSQuote(var SalePOS: Record "Sale POS";POSQuoteEntryNo: Integer) Success: Boolean
    var
        POSQuoteEntry: Record "POS Quote Entry";
        POSActionLoadPOSQuote: Codeunit "POS Action - Load POS Quote";
    begin
        Success := DoLoadFromPOSQuote(SalePOS,POSQuoteEntryNo);
        if Success then
          Message(CannotResumeMsg + '\' + ResumedWithNewTicketMsg)
        else
          Message(CannotResumeMsg + '\' + SavedAsQuoteMsg, POSQuoteEntryNo);
    end;

    local procedure DoLoadFromPOSQuote(var SalePOS: Record "Sale POS";POSQuoteEntryNo: Integer): Boolean
    var
        POSQuoteEntry: Record "POS Quote Entry";
        POSActionLoadPOSQuote: Codeunit "POS Action - Load POS Quote";
    begin
        if not POSQuoteEntry.Get(POSQuoteEntryNo) then
          exit(false);
        exit(POSActionLoadPOSQuote.LoadFromQuote(POSQuoteEntry,SalePOS));
    end;

    procedure DoCancelSale(SalePOS: Record "Sale POS";POSSession: Codeunit "POS Session")
    begin
        CancelErrorText := '';
        if not TryCancelSale(SalePOS,POSSession) then
          Error(CannotCancelMsg,CancelErrorText);
    end;

    local procedure TryCancelSale(SalePOS: Record "Sale POS";POSSession: Codeunit "POS Session") Success: Boolean
    var
        POSTryCancelSale: Codeunit "POS Try Resume and Cancel Sale";
        Position: Integer;
    begin
        Clear(POSTryCancelSale);
        POSTryCancelSale.Initialize(POSSession);
        ClearLastError;
        Success := POSTryCancelSale.Run(SalePOS);
        if not Success then begin
          CancelErrorText := GetLastErrorText;
          Position := StrPos(CancelErrorText,POSActionDeleteMsg);
          if Position <> 0 then
            CancelErrorText := CopyStr(CancelErrorText,StrLen(POSActionDeleteMsg) + 2);
          if CancelErrorText = '' then
            CancelErrorText := NoInfoProvidedMsg;
        end;
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforePromptResumeSale(var SalePOS: Record "Sale POS";POSSession: Codeunit "POS Session";var SkipDialog: Boolean;var ActionOption: Option " ",Resume,CancelAndNew,SaveAsQuote;var ActionOnCancelError: Option " ",Resume,SaveAsQuote,ShowError;var Handled: Boolean)
    begin
    end;
}

