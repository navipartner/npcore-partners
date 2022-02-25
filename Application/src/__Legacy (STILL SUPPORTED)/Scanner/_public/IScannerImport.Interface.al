interface "NPR IScanner Import"
{
    procedure GetInitialLine();
    procedure ImportLine(ScannedShelf: Text; ScannedItemCode: Text; ScannedQuantity: Text);
    procedure SetRecordRef(RecRef: RecordRef);
    procedure ShowErrors();
}