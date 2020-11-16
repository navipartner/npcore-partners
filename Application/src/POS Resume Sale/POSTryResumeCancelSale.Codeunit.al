codeunit 6150738 "NPR POS Try Resume&CancelSale"
{
    // NPR5.54/JAKUBV/20200408  CASE 364658 Transport NPR5.54 - 8 April 2020
    // NPR5.55/ALPO/20200810 CASE 391678 Log sale cancelling to POS Entry

    TableNo = "NPR Sale POS";

    trigger OnRun()
    var
        SalePOS: Record "NPR Sale POS";
    begin
        SalePOS := Rec;
        ResumeAndCancelSale(SalePOS);
    end;

    var
        POSSession: Codeunit "NPR POS Session";
        AltSaleCancelDescription: Text;
        Initialized: Boolean;
        NotInitializedMsg: Label 'Codeunit ''POS Try Resume and Cancel Sale'' was invoked in uninitialized state. This is a programming bug, not a user error.';

    procedure Initialize(POSSessionIn: Codeunit "NPR POS Session")
    begin
        POSSession := POSSessionIn;
        Initialized := true;
    end;

    local procedure CheckInitialized()
    begin
        if not Initialized then
            Error(NotInitializedMsg);
    end;

    local procedure ResumeAndCancelSale(SalePOS: Record "NPR Sale POS")
    var
        CashRegister: Record "NPR Register";
        POSActionCancelSale: Codeunit "NPR POSAction: Cancel Sale";
        POSFrontEndMgt: Codeunit "NPR POS Front End Management";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        Setup: Codeunit "NPR POS Setup";
    begin
        CheckInitialized();

        POSSession.GetSetup(Setup);
        Setup.GetRegisterRecord(CashRegister);
        POSSession.GetSale(POSSale);
        POSSale.ResumeExistingSale(SalePOS, CashRegister, POSFrontEndMgt, Setup, POSSale);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.Init(SalePOS."Register No.", SalePOS."Sales Ticket No.", POSSale, Setup, POSFrontEndMgt);

        POSActionCancelSale.CheckSaleBeforeCancel(POSSession);
        POSActionCancelSale.SetAlternativeDescription(AltSaleCancelDescription);  //NPR5.55 [391678]
        if not POSActionCancelSale.CancelSale(POSSession) then
            Error('');
    end;

    procedure SetAlternativeDescription(NewAltSaleCancelDescription: Text)
    begin
        //-NPR5.55 [391678]
        AltSaleCancelDescription := NewAltSaleCancelDescription;
        //+NPR5.55 [391678]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150739, 'OnBeforePromptResumeSale', '', false, false)]
    local procedure SetCancelOrPark(var SalePOS: Record "NPR Sale POS"; POSSession: Codeunit "NPR POS Session"; var SkipDialog: Boolean; var ActionOption: Option " ",Resume,CancelAndNew,SaveAsQuote; var ActionOnCancelError: Option " ",Resume,SaveAsQuote,ShowError; var Handled: Boolean)
    begin
        /*
        SkipDialog := TRUE;
        ActionOption := ActionOption::CancelAndNew;
        ActionOnCancelError := ActionOnCancelError::SaveAsQuote;
        */

    end;
}

