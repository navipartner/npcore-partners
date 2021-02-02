interface "NPR CleanCash XCCSP Interface"
{
    procedure CreateRequest(PosEntry: Record "NPR POS Entry"; RequestType: Enum "NPR CleanCash Request Type"; var EntryNo: Integer): Boolean

    procedure CreateRequest(PosUnitNo: Code[10]; var EntryNo: Integer): Boolean

    procedure GetRequestXml(CleanCashTransactionRequest: Record "NPR CleanCash Trans. Request"; var XmlDoc: XmlDocument) Success: Boolean;

    procedure SerializeResponse(var CleanCashTransactionRequest: Record "NPR CleanCash Trans. Request"; XmlDoc: XmlDocument; var ResponseEntryNo: Integer) Success: Boolean

    procedure AddToPrintBuffer(var LinePrintMgt: Codeunit "NPR RP Line Print Mgt."; var CleanCashTransaction: Record "NPR CleanCash Trans. Request");
}