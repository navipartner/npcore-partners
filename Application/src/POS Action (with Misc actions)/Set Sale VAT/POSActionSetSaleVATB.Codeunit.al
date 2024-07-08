codeunit 6060102 "NPR POS Action-Set Sale VAT-B."
{
    Access = Internal;
    procedure CheckLimits(POSSale: Codeunit "NPR POS Sale"; MinSaleAmount: Decimal; MinSaleAmountLimit: Boolean; MaxSaleAmount: Decimal; MaxSaleAmountLimit: Boolean)
    var
        ChangeAmount: Decimal;
        PaidAmount: Decimal;
        RoundingAmount: Decimal;
        SalesAmount: Decimal;
        Error_MaxAmount: Label 'Sale amount is above the maximum limit';
        Error_MinAmount: Label 'Sale amount is below the minimum limit';
    begin
        POSSale.GetTotals(SalesAmount, PaidAmount, ChangeAmount, RoundingAmount);

        if MinSaleAmountLimit and (SalesAmount < MinSaleAmount) then
            Error('%1 (%2)', Error_MinAmount, MinSaleAmount);

        if MaxSaleAmountLimit and (SalesAmount > MaxSaleAmount) then
            Error('%1 (%2)', Error_MaxAmount, MaxSaleAmount);
    end;

    local procedure InsertComment(POSSaleLine: Codeunit "NPR POS Sale Line"; VATAmountDifference: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        Comment_VatAdded: Label 'VAT added to sale';
        Comment_VatRemoved: Label 'VAT removed from sale';
        SaleLinePOSDescLbl: Label '%1: %2', Locked = true;
    begin
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Comment;

        if VATAmountDifference = 0 then
            exit
        else
            if VATAmountDifference > 0 then
                SaleLinePOS.Description := StrSubstNo(SaleLinePOSDescLbl, Comment_VatRemoved, VATAmountDifference)
            else
                SaleLinePOS.Description := StrSubstNo(SaleLinePOSDescLbl, Comment_VatAdded, VATAmountDifference);

        POSSaleLine.InsertLine(SaleLinePOS);
    end;

    procedure ChangeSaleVATBusPostingGroup(POSSale: Codeunit "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line"; NewGenBusPostingGroup: Text; NewVATBusPostingGroup: Text; AddCommentLine: Boolean)
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        NewVATTotal: Decimal;
        OldVATTotal: Decimal;
    begin
        if (NewGenBusPostingGroup = '') and (NewVATBusPostingGroup = '') then
            exit;
        if NewGenBusPostingGroup <> '' then
            GenBusinessPostingGroup.Get(NewGenBusPostingGroup);
        if NewVATBusPostingGroup <> '' then
            VATBusinessPostingGroup.Get(NewVATBusPostingGroup);

        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindSet() then
            repeat
                OldVATTotal += (SaleLinePOS."Amount Including VAT" - SaleLinePOS.Amount);
                if (NewGenBusPostingGroup <> '') and (SaleLinePOS."Gen. Bus. Posting Group" <> GenBusinessPostingGroup.Code) then
                    SaleLinePOS.Validate("Gen. Bus. Posting Group", NewGenBusPostingGroup);
                if (NewVATBusPostingGroup <> '') and (SaleLinePOS."VAT Bus. Posting Group" <> VATBusinessPostingGroup.Code) then
                    SaleLinePOS.Validate("VAT Bus. Posting Group", NewVATBusPostingGroup);
                SaleLinePOS.UpdateVATSetup();
                SaleLinePOS."Unit Price" := SaleLinePOS.FindItemSalesPrice();
                SaleLinePOS.UpdateAmounts(SaleLinePOS);
                SaleLinePOS.Modify();
                NewVATTotal += (SaleLinePOS."Amount Including VAT" - SaleLinePOS.Amount);
            until SaleLinePOS.Next() = 0;
        if (NewGenBusPostingGroup <> '') and (SalePOS."Gen. Bus. Posting Group" <> GenBusinessPostingGroup.Code) then
            SalePOS.Validate("Gen. Bus. Posting Group", NewGenBusPostingGroup);
        if (NewVATBusPostingGroup <> '') and (SaleLinePOS."VAT Bus. Posting Group" <> VATBusinessPostingGroup.Code) then
            SalePOS.Validate("VAT Bus. Posting Group", VATBusinessPostingGroup.Code);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);

        if AddCommentLine then
            InsertComment(POSSaleLine, OldVATTotal - NewVATTotal);

        POSSaleLine.RefreshCurrent();
    end;
}