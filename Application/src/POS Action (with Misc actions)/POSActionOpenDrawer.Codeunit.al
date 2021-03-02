codeunit 6150793 "NPR POS Action: Open Drawer"
{
    var
        ActionDescription: Label 'This is a built-in action for opening the cash drawer';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Text
    begin
        exit('OPEN_CASH_DRAWER');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.5');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin

            Sender.RegisterWorkflow(false);
            Sender.RegisterTextParameter('Cash Drawer No.', '');

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        CashDrawerNo: Code[10];
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
        POSPostingProfile: Record "NPR POS Posting Profile";
        RecID: RecordID;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());
        CashDrawerNo := JSON.GetStringOrFail('Cash Drawer No.', StrSubstNo(ReadingErr, ActionCode()));

        POSSession.GetSetup(POSSetup);
        POSSession.GetSale(POSSale);
        RecID := SalePOS.RecordId;
        POSSale.GetCurrentSale(SalePOS);

        if (CashDrawerNo = '') then begin
            if (POSUnit.Get(POSSetup.GetPOSUnitNo())) then begin
                POSUnit.GetProfile(POSPostingProfile);
                CashDrawerNo := POSPostingProfile."POS Payment Bin";
            end;
        end;

        OpenDrawer(CashDrawerNo, SalePOS);

        if SalePOS.RecordId <> RecID then begin
            SalePOS.Find;
            SalePOS."Drawer Opened" := true;
            SalePOS.Modify;
            POSSale.Refresh(SalePOS);
        end;

        Handled := true;
    end;

    local procedure OpenDrawer(CashDrawerNo: Code[10]; SalePOS: Record "NPR Sale POS")
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
    begin
        POSPaymentBin.Get(CashDrawerNo);
        POSPaymentBinInvokeMgt.EjectDrawer(POSPaymentBin, SalePOS);
    end;
}

