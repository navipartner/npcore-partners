codeunit 6059841 "NPR POS Action: Sale Dim. B"
{
    Access = Internal;

    var
        DimSetLbl: Label 'Dimension code %1 set to %2.';

    procedure AdjustHeaderDimensions(POSSession: Codeunit "NPR POS Session"; DimCode: Code[20]; DimValueCode: Code[20]; WithCreate: Boolean) StrMessage: Text
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if DimCode = '' then
            SalePOS.ShowDocDim()
        else
            StrMessage := SetHeaderDimensionValue(POSSale, DimCode, DimValueCode, WithCreate);
    end;

    procedure AdjustLineDimensions(POSSession: Codeunit "NPR POS Session"; DimCode: Code[20]; DimValueCode: Code[20]; ApplyDimTo: Option Sale,CurrentLine,LinesOfTypeSale; WithCreate: Boolean) StrMessage: Text
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        MultiLineDimensionEditNotSupportedErr: Label 'Multi-line dimension edit is not supported. Please select a specific Dimension Code for the POS action.';
    begin
        if ApplyDimTo = ApplyDimTo::Sale then
            exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        case ApplyDimTo of
            ApplyDimTo::CurrentLine:
                SaleLinePOS.SetRecFilter();
            ApplyDimTo::LinesOfTypeSale:
                begin
                    SaleLinePOS.SetRange("Register No.", SaleLinePOS."Register No.");
                    SaleLinePOS.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
                end;
        end;

        if DimCode = '' then begin
            if SaleLinePOS.Count = 1 then begin
                if SaleLinePOS.ShowDimensions() then
                    SaleLinePOS.Modify();
            end else
                //TODO: multi-line dimension edit
                Error(MultiLineDimensionEditNotSupportedErr);
        end else
            StrMessage := SetLineDimensionValue(SaleLinePOS, DimCode, DimValueCode, WithCreate);
    end;

    local procedure SetHeaderDimensionValue(POSSale: Codeunit "NPR POS Sale"; DimCode: Code[20]; DimValueCode: Code[20]; WithCreate: Boolean) StrMessage: Text
    begin
        if WithCreate then
            CheckCreateDimensionValue(DimCode, DimValueCode);

        POSSale.SetDimension(DimCode, DimValueCode);
        StrMessage := StrSubstNo(DimSetLbl, DimCode, DimValueCode);
    end;

    local procedure SetLineDimensionValue(var SaleLinePOS: Record "NPR POS Sale Line"; DimCode: Code[20]; DimValueCode: Code[20]; WithCreate: Boolean) StrMessage: Text
    var
        SaleLinePOS2: Record "NPR POS Sale Line";
    begin
        if SaleLinePOS.IsEmpty() then
            exit;

        if WithCreate then
            CheckCreateDimensionValue(DimCode, DimValueCode);

        SaleLinePOS.FindSet(true);
        repeat
            SaleLinePOS2 := SaleLinePOS;
            SaleLinePOS2.SetDimension(DimCode, DimValueCode);
        until SaleLinePOS.Next() = 0;

        StrMessage := StrSubstNo(DimSetLbl, DimCode, DimValueCode);
    end;

    local procedure CheckCreateDimensionValue(DimCode: Code[20]; DimValueCode: Code[20])
    var
        DimensionValue: Record "Dimension Value";
    begin
        if DimensionValue.Get(DimCode, DimValueCode) then
            exit;

        DimensionValue.Init();
        DimensionValue."Dimension Code" := DimCode;
        DimensionValue.Code := DimValueCode;
        DimensionValue."Dimension Value Type" := DimensionValue."Dimension Value Type"::Standard;
        DimensionValue.Insert(true);
    end;
}
