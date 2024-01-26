codeunit 6150919 "NPR POS Action: RunItemAddOn B"
{
    Access = Internal;

    procedure RunItemAddOns(AppliesToLineNo: Integer; ApplyItemAddOnNo: Code[20]; CompulsoryAddOn: Boolean; SkipItemAvailabilityCheck: Boolean; UserSelectionRequired: Boolean; UserSelectionJToken: JsonToken)
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        PosInventoryProfile: Record "NPR POS Inventory Profile";
        SaleLinePOS: Record "NPR POS Sale Line";
        ItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
        PosItemCheckAvail: Codeunit "NPR POS Item-Check Avail.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        RequestFrontEndRefresh: Boolean;
        UpdateActiveSaleLine: Boolean;
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        UpdateActiveSaleLine := SaleLinePOS."Line No." <> AppliesToLineNo;
        SaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", AppliesToLineNo);
        if (SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Item) and (SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::"BOM List") then
            exit;
        IF UpdateActiveSaleLine THEN
            POSSaleLine.SetPosition(SaleLinePOS.GetPosition());

        ItemAddOn.Get(ApplyItemAddOnNo);
        ItemAddOn.TestField(Enabled);

        Clear(PosItemCheckAvail);
        if not SkipItemAvailabilityCheck then begin
            PosItemCheckAvail.GetPosInvtProfile(POSSession, PosInventoryProfile);
            if PosInventoryProfile."Stockout Warning" then
                PosItemCheckAvail.SetxDataset(POSSession);
        end;

        Clear(ItemAddOnMgt);
        if not UserSelectionRequired then
            RequestFrontEndRefresh := ItemAddOnMgt.InsertMandatoryPOSAddOnLinesSilent(ItemAddOn, POSSession, AppliesToLineNo, CompulsoryAddOn)
        else begin
            if UserSelectionJToken.IsValue then
                if UserSelectionJToken.AsValue().IsNull and not CompulsoryAddOn then
                    Error('');
            RequestFrontEndRefresh := ItemAddOnMgt.InsertPOSAddOnLines(ItemAddOn, UserSelectionJToken, POSSession, AppliesToLineNo, CompulsoryAddOn);
        end;

        if RequestFrontEndRefresh then
            if ItemAddOnMgt.InsertedWithAutoSplitKey() then
                POSSession.ChangeViewSale();  //there is no other way to refresh the lines, so they appear in correct order

        if not SkipItemAvailabilityCheck and PosInventoryProfile."Stockout Warning" then
            PosItemCheckAvail.DefineScopeAndCheckAvailability(POSSession, false);
    end;



}