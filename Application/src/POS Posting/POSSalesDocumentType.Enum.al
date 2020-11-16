enum 6150620 "NPR POS Sales Document Type"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "QUOTE") { Caption = 'Quote'; }
    value(1; "ORDER") { Caption = 'Order'; }
    value(2; "INVOICE") { Caption = 'Invoice'; }
    value(3; "CREDIT_MEMO") { Caption = 'Credit Memo'; }
    value(4; "BLANKET_ORDER") { Caption = 'Blanket Order'; }
    value(5; "RETURN_ORDER") { Caption = 'Return Order'; }
    value(6; "POSTED_INVOICE") { Caption = 'Posted Invoice'; }
    value(7; "POSTED_CREDIT_MEMO") { Caption = 'Posted Credit Memo'; }
    value(8; "SHIPMENT") { Caption = 'Shipment'; }
    value(9; "RETURN_RECEIPT") { Caption = 'Return Receipt'; }
    value(10; "SERVICE_ITEM") { Caption = 'Service Item'; }
    value(11; "ASSEMBLY_ORDER") { Caption = 'Assembly Order'; }
    value(12; "POSTED_ASSEMBLY_ORDER") { Caption = 'Posted Assembly Order'; }
}