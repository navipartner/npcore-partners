codeunit 6150793 "NPR POS Action: Open Drawer"
{
    var
        ActionDescription: Label 'This is a built-in action for opening the cash drawer';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Code[20]
    begin
        exit('OPEN_CASH_DRAWER');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.5');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
              ActionCode(),
              ActionDescription,
              ActionVersion(),
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
        SalePOS: Record "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
        RecID: RecordID;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());
        CashDrawerNo := CopyStr(JSON.GetStringOrFail('Cash Drawer No.', StrSubstNo(ReadingErr, ActionCode())), 1, MaxStrLen(CashDrawerNo));

        POSSession.GetSetup(POSSetup);
        POSSession.GetSale(POSSale);
        RecID := SalePOS.RecordId;
        POSSale.GetCurrentSale(SalePOS);

        if (CashDrawerNo = '') then begin
            if POSUnit.Get(POSSetup.GetPOSUnitNo()) then begin
                CashDrawerNo := POSUnit."Default POS Payment Bin";
            end;
        end;

        OpenDrawer(CashDrawerNo, SalePOS);

        Handled := true;
    end;

    local procedure OpenDrawer(CashDrawerNo: Code[10]; SalePOS: Record "NPR POS Sale")
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
    begin
        POSPaymentBin.Get(CashDrawerNo);
        POSPaymentBinInvokeMgt.EjectDrawer(POSPaymentBin, SalePOS);
    end;
}

