codeunit 6151129 "NPR NpIa Before Ins. Func."
{
    Access = Internal;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpIa Item AddOn Mgt.", 'BeforeInsertPOSAddOnLine', '', true, true)]
    local procedure UnitPriceFromMaster(SalePOS: Record "NPR POS Sale"; AppliesToLineNo: Integer; var NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        NpIaItemAddOnLineSetup: Record "NPR NpIa ItemAddOn Line Setup";
    begin
        if NpIaItemAddOnLine."Before Insert Function" <> 'UnitPriceFromMaster' then
            exit;
        if NpIaItemAddOnLine."Before Insert Codeunit ID" <> CurrCodeunitId() then
            exit;

        if not SaleLinePOS.Get(SalePOS."Register No.", SalePOS."Sales Ticket No.", SalePOS.Date, SalePOS."Sale type", AppliesToLineNo) then
            exit;

        if (SaleLinePOS.Quantity = 0) or (not NpIaItemAddOnLineSetup.Get(NpIaItemAddOnLine."AddOn No.", NpIaItemAddOnLine."Line No.")) then begin
            NpIaItemAddOnLine."Unit Price" := 0;
            exit;
        end;

        NpIaItemAddOnLine."Unit Price" := (SaleLinePOS."Amount Including VAT" / SaleLinePOS.Quantity) * (NpIaItemAddOnLineSetup."Unit Price % from Master" / 100);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpIa Item AddOn Mgt.", 'HasBeforeInsertSetup', '', true, true)]
    local procedure UnitPriceFromMasterHasSetup(NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var HasSetup: Boolean)
    begin
        if HasSetup then
            exit;
        if NpIaItemAddOnLine."Before Insert Function" <> 'UnitPriceFromMaster' then
            exit;
        if NpIaItemAddOnLine."Before Insert Codeunit ID" <> CurrCodeunitId() then
            exit;

        HasSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpIa Item AddOn Mgt.", 'RunBeforeInsertSetup', '', true, true)]
    local procedure UnitPriceFromMasterRunSetup(NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var Handled: Boolean)
    var
        NpIaItemAddOnLineSetup: Record "NPR NpIa ItemAddOn Line Setup";
    begin
        if Handled then
            exit;
        if NpIaItemAddOnLine."Before Insert Function" <> 'UnitPriceFromMaster' then
            exit;
        if NpIaItemAddOnLine."Before Insert Codeunit ID" <> CurrCodeunitId() then
            exit;

        NpIaItemAddOnLineSetup.FilterGroup(2);
        NpIaItemAddOnLineSetup.SetRange("AddOn No.", NpIaItemAddOnLine."AddOn No.");
        NpIaItemAddOnLineSetup.SetRange("AddOn Line No.", NpIaItemAddOnLine."Line No.");
        NpIaItemAddOnLineSetup.FilterGroup(0);
        if not NpIaItemAddOnLineSetup.Get(NpIaItemAddOnLine."AddOn No.", NpIaItemAddOnLine."Line No.") then begin
            NpIaItemAddOnLineSetup.Init();
            NpIaItemAddOnLineSetup."AddOn No." := NpIaItemAddOnLine."AddOn No.";
            NpIaItemAddOnLineSetup."AddOn Line No." := NpIaItemAddOnLine."Line No.";
            NpIaItemAddOnLineSetup.Insert();
        end;
        PAGE.Run(PAGE::"NPR NpIa ItemAddOn Line Setup", NpIaItemAddOnLineSetup);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpIa Item AddOn Line", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteAddOnLine(var Rec: Record "NPR NpIa Item AddOn Line"; RunTrigger: Boolean)
    var
        NpIaItemAddOnLineSetup: Record "NPR NpIa ItemAddOn Line Setup";
    begin
        if Rec.IsTemporary() then
            exit;

        if NpIaItemAddOnLineSetup.Get(Rec."AddOn No.", Rec."Line No.") then
            NpIaItemAddOnLineSetup.Delete();
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpIa Before Ins. Func.");
    end;
}

