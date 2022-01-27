codeunit 6151140 "NPR POS Action: Change UOM"
{
    Access = Internal;
    var
        ActionDescriptionCaption: Label 'Change unit of measure for POS sales line';

    local procedure ActionCode(): Code[20]
    begin
        exit('CHANGE_UOM');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescriptionCaption,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('Select', 'respond();');
            Sender.RegisterWorkflow(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        ChangeUOM(POSSession);

        POSSession.RequestRefreshData();
    end;

    local procedure ChangeUOM(var POSSession: Codeunit "NPR POS Session")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        UnitofMeasure: Record "Unit of Measure";
        UnitsofMeasure: Page "Units of Measure";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        UnitofMeasure.SetFilter(Code, GetItemCodes(SaleLinePOS."No."));

        UnitsofMeasure.Editable(false);
        UnitsofMeasure.LookupMode(true);
        UnitsofMeasure.SetTableView(UnitofMeasure);
        if UnitsofMeasure.RunModal() <> ACTION::LookupOK then
            exit;

        UnitsofMeasure.GetRecord(UnitofMeasure);

        if SaleLinePOS."Unit of Measure Code" = UnitofMeasure.Code then
            exit;

        SaleLinePOS.Validate("Unit of Measure Code", UnitofMeasure.Code);
        SaleLinePOS.Modify(true);

        POSSaleLine.RefreshCurrent();
    end;

    local procedure GetItemCodes(ItemNo: Code[20]) Codes: Text
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitofMeasure.SetRange("Item No.", ItemNo);

        if ItemUnitofMeasure.FindSet() then
            repeat
                Codes += '|' + ItemUnitofMeasure.Code;
            until ItemUnitofMeasure.Next() = 0;

        Codes := CopyStr(Codes, 2);
    end;
}

