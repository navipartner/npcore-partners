codeunit 6151129 "NpIa Before Insert Functions"
{
    // NPR5.48/MHA /20181113  CASE 334922 Object created - Before Insert functions for Item AddOns POS Lines


    trigger OnRun()
    begin
    end;

    local procedure "--- Unit Price From Master"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151125, 'BeforeInsertPOSAddOnLine', '', true, true)]
    local procedure UnitPriceFromMaster(SalePOS: Record "Sale POS";AppliesToLineNo: Integer;var NpIaItemAddOnLine: Record "NpIa Item AddOn Line")
    var
        SaleLinePOS: Record "Sale Line POS";
        NpIaItemAddOnLineSetup: Record "NpIa Item AddOn Line Setup";
    begin
        if NpIaItemAddOnLine."Before Insert Function" <> 'UnitPriceFromMaster' then
          exit;
        if NpIaItemAddOnLine."Before Insert Codeunit ID" <> CurrCodeunitId() then
          exit;

        if not SaleLinePOS.Get(SalePOS."Register No.",SalePOS."Sales Ticket No.",SalePOS.Date,SalePOS."Sale type",AppliesToLineNo) then
          exit;

        if (SaleLinePOS.Quantity = 0) or (not NpIaItemAddOnLineSetup.Get(NpIaItemAddOnLine."AddOn No.",NpIaItemAddOnLine."Line No.")) then begin
          NpIaItemAddOnLine."Unit Price" := 0;
          exit;
        end;

        NpIaItemAddOnLine."Unit Price" := (SaleLinePOS."Amount Including VAT" / SaleLinePOS.Quantity) * (NpIaItemAddOnLineSetup."Unit Price % from Master" / 100);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151125, 'HasBeforeInsertSetup', '', true, true)]
    local procedure UnitPriceFromMasterHasSetup(NpIaItemAddOnLine: Record "NpIa Item AddOn Line";var HasSetup: Boolean)
    begin
        if HasSetup then
          exit;
        if NpIaItemAddOnLine."Before Insert Function" <> 'UnitPriceFromMaster' then
          exit;
        if NpIaItemAddOnLine."Before Insert Codeunit ID" <> CurrCodeunitId() then
          exit;

        HasSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151125, 'RunBeforeInsertSetup', '', true, true)]
    local procedure UnitPriceFromMasterRunSetup(NpIaItemAddOnLine: Record "NpIa Item AddOn Line";var Handled: Boolean)
    var
        NpIaItemAddOnLineSetup: Record "NpIa Item AddOn Line Setup";
    begin
        if Handled then
          exit;
        if NpIaItemAddOnLine."Before Insert Function" <> 'UnitPriceFromMaster' then
          exit;
        if NpIaItemAddOnLine."Before Insert Codeunit ID" <> CurrCodeunitId() then
          exit;

        NpIaItemAddOnLineSetup.FilterGroup(2);
        NpIaItemAddOnLineSetup.SetRange("AddOn No.",NpIaItemAddOnLine."AddOn No.");
        NpIaItemAddOnLineSetup.SetRange("AddOn Line No.",NpIaItemAddOnLine."Line No.");
        NpIaItemAddOnLineSetup.FilterGroup(0);
        if not NpIaItemAddOnLineSetup.Get(NpIaItemAddOnLine."AddOn No.",NpIaItemAddOnLine."Line No.") then begin
          NpIaItemAddOnLineSetup.Init;
          NpIaItemAddOnLineSetup."AddOn No." := NpIaItemAddOnLine."AddOn No.";
          NpIaItemAddOnLineSetup."AddOn Line No." := NpIaItemAddOnLine."Line No.";
          NpIaItemAddOnLineSetup.Insert;
        end;
        PAGE.Run(PAGE::"NpIa Item AddOn Line Setup",NpIaItemAddOnLineSetup);
    end;

    [EventSubscriber(ObjectType::Table, 6151126, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteAddOnLine(var Rec: Record "NpIa Item AddOn Line";RunTrigger: Boolean)
    var
        NpIaItemAddOnLineSetup: Record "NpIa Item AddOn Line Setup";
    begin
        if Rec.IsTemporary then
          exit;

        if NpIaItemAddOnLineSetup.Get(Rec."AddOn No.",Rec."Line No.") then
          NpIaItemAddOnLineSetup.Delete;
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpIa Before Insert Functions");
    end;
}

