codeunit 6059950 "NPR Print Exchange Labels"
{
    procedure PrintLabelsPOSLine(PrintType: Option Single,LineQuantity,All,Selection,Package; var SaleLinePOS: Record "NPR POS Sale Line"; ValidFromDate: Date)
    var
        ExchLabelMgt: codeunit "NPR Exchange Label Mgt.";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(SaleLinePOS);
        ExchLabelMgt.PrintLabels(PrintType, RecRef, ValidFromDate);
    end;

    procedure PrintLabelsSalesLine(PrintType: Option Single,LineQuantity,All,Selection,Package; var SalesLine: Record "Sales Line"; ValidFromDate: Date)
    var
        ExchLabelMgt: codeunit "NPR Exchange Label Mgt.";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(SalesLine);
        ExchLabelMgt.PrintLabels(PrintType, RecRef, ValidFromDate);
    end;

    procedure PrintLabelsSalesInvLine(PrintType: Option Single,LineQuantity,All,Selection,Package; var SalesInvLine: Record "Sales Invoice Line"; ValidFromDate: Date)
    var
        ExchLabelMgt: codeunit "NPR Exchange Label Mgt.";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(SalesInvLine);
        ExchLabelMgt.PrintLabels(PrintType, RecRef, ValidFromDate);
    end;

    procedure ExchangeLabelsExist(RecVariant: Variant): Boolean
    var
        ExchLabelMgt: codeunit "NPR Exchange Label Mgt.";
    begin
        exit(ExchLabelMgt.ExchangeLabelsExist(RecVariant));
    end;

    procedure DeleteExchangeLabels(RecVariant: Variant)
    var
        ExchLabelMgt: codeunit "NPR Exchange Label Mgt.";
    begin
        ExchLabelMgt.DeleteExchangeLabels(RecVariant);
    end;

    procedure CheckIfBarCodeIsExchangeLabel(Barcode: Text): Boolean
    var
        ExchLabelMgt: codeunit "NPR Exchange Label Mgt.";
    begin
        exit(ExchLabelMgt.CheckIfBarCodeIsExchangeLabel(Barcode));
    end;

    procedure CheckPrefix(Barcode: Text; Prefix: Code[10]): Boolean
    var
        ExchLabelMgt: codeunit "NPR Exchange Label Mgt.";
    begin
        exit(ExchLabelMgt.CheckPrefix(Barcode, Prefix));
    end;

    procedure ScanExchangeLabel(var SalePOS: Record "NPR POS Sale"; var Validering: Code[20]; CopyValidering: Code[20]) Found: Boolean
    var
        ExchLabelMgt: codeunit "NPR Exchange Label Mgt.";
    begin
        exit(ExchLabelMgt.ScanExchangeLabel(SalePOS, Validering, CopyValidering));
    end;

    internal procedure CallOnBeforeInsertExchangeLabel(var ExchangeLabelRecRef: RecordRef; var RecRef: RecordRef)
    begin
        OnBeforeInsertExchangeLabel(ExchangeLabelRecRef, RecRef);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertExchangeLabel(var ExchangeLabelRecRef: RecordRef; var RecRef: RecordRef)
    begin
    end;
}