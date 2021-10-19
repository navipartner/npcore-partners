codeunit 6150738 "NPR POS Try Resume&CancelSale"
{
    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        SalePOS: Record "NPR POS Sale";
    begin
        SalePOS := Rec;
        ResumeAndCancelSale(SalePOS);
    end;

    var
        POSSession: Codeunit "NPR POS Session";
        AltSaleCancelDescription: Text;
        Initialized: Boolean;

    procedure Initialize(POSSessionIn: Codeunit "NPR POS Session")
    begin
        POSSession := POSSessionIn;
        Initialized := true;
    end;

    local procedure CheckInitialized()
    var
        NotInitializedErr: Label 'Codeunit ''POS Try Resume and Cancel Sale'' was invoked in uninitialized state. This is a programming bug, not a user error.';
    begin
        if not Initialized then
            Error(NotInitializedErr);
    end;

    local procedure ResumeAndCancelSale(SalePOS: Record "NPR POS Sale")
    var
        POSUnit: Record "NPR POS Unit";
        POSActionCancelSale: Codeunit "NPR POSAction: Cancel Sale";
        POSFrontEndMgt: Codeunit "NPR POS Front End Management";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        Setup: Codeunit "NPR POS Setup";
    begin
        CheckInitialized();
        POSSession.GetFrontEnd(POSFrontEndMgt, true);

        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(POSUnit);
        POSSession.GetSale(POSSale);
        POSSale.ResumeExistingSale(SalePOS, POSUnit, POSFrontEndMgt, Setup, POSSale);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.Init(SalePOS."Register No.", SalePOS."Sales Ticket No.", POSSale, Setup, POSFrontEndMgt);

        POSActionCancelSale.CheckSaleBeforeCancel(POSSession);
        POSActionCancelSale.SetAlternativeDescription(AltSaleCancelDescription);
        if not POSActionCancelSale.CancelSale(POSSession) then
            Error('');
    end;

    procedure SetAlternativeDescription(NewAltSaleCancelDescription: Text)
    begin
        AltSaleCancelDescription := NewAltSaleCancelDescription;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Resume Sale Mgt.", 'OnBeforePromptResumeSale', '', false, false)]
    local procedure SetCancelOrPark(var SalePOS: Record "NPR POS Sale"; POSSession: Codeunit "NPR POS Session"; var SkipDialog: Boolean; var ActionOption: Option " ",Resume,CancelAndNew,SaveAsQuote; var ActionOnCancelError: Option " ",Resume,SaveAsQuote,ShowError; var Handled: Boolean)
    begin
        /*
        SkipDialog := TRUE;
        ActionOption := ActionOption::CancelAndNew;
        ActionOnCancelError := ActionOnCancelError::SaveAsQuote;
        */
    end;
}