codeunit 6151490 "NPR RS R Localization Mgt."
{
    Access = Internal;
    internal procedure IsRSLocalizationActive(): Boolean
    var
        RSRetLocalizationSetup: Record "NPR RS R Localization Setup";
    begin
        if not RSRetLocalizationSetup.Get() then begin
            RSRetLocalizationSetup.Init();
            RSRetLocalizationSetup.Insert();
        end;
        exit(RSRetLocalizationSetup."Enable RS Retail Localization");
    end;

    #region RS Retail Lcl. Mgt. - Posted Purch. Invoice Action Mgt.
    internal procedure CheckForRetailLocationLines(PostedPurchInvHdr: Record "Purch. Inv. Header") RetailLocationCodeExists: Boolean
    var
        PurchInvLines: Record "Purch. Inv. Line";
        Location: Record Location;
    begin
        if not IsRSLocalizationActive() then
            exit;
        PurchInvLines.SetLoadFields("Document No.", "Location Code");
        PurchInvLines.SetRange("Document No.", PostedPurchInvHdr."No.");
        if not PurchInvLines.FindSet() then
            exit;
        repeat
            case true of
                PurchInvLines."Location Code" <> '':
                    begin
                        if Location.Get(PurchInvLines."Location Code") then
                            RetailLocationCodeExists := Location."NPR Retail Location";
                        if RetailLocationCodeExists then
                            exit;
                    end;
            end;
        until PurchInvLines.Next() = 0;
    end;
    #endregion

    #region RS Retail Lcl. Mgt. - Sales Price List Lines Mgt.
    internal procedure RetailCheckForModifyActiveLine(PrevPriceListLine: Record "Price List Line")
    var
        ActivePriceListLineModifyNotAllowedErr: Label 'You cannot edit a verified Price List Line.';
    begin
        if not IsRSLocalizationActive() then
            exit;
        if PrevPriceListLine.Status = "Price Status"::Active then
            Error(ActivePriceListLineModifyNotAllowedErr);
    end;

    internal procedure RetailCheckForDeleteActiveLine(PrevPriceListLine: Record "Price List Line")
    var
        ActivePriceListLineDeleteNotAllowedErr: Label 'You cannot remove a verified Price List Line.';
    begin
        if not IsRSLocalizationActive() then
            exit;
        if PrevPriceListLine.Status = "Price Status"::Active then
            Error(ActivePriceListLineDeleteNotAllowedErr);
    end;
    #endregion

    #region RS Retail Lcl. Mgt. - Sales Line Retail Price Mgt.
    internal procedure GetPriceFromSalesPriceList(var SalesLine: Record "Sales Line")
    var
        RSSalesLineRetailCalc: Codeunit "NPR RS Sales Line Retail Cal.";
    begin
        if not IsRSLocalizationActive() then
            exit;
        RSSalesLineRetailCalc.GetPriceFromSalesPriceList(SalesLine);
    end;
    #endregion
}