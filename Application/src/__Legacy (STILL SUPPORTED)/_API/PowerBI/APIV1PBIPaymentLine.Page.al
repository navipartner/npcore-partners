page 6185076 "NPR APIV1 PBI Payment Line"
{
    Extensible = false;
    Editable = false;
    DelayedInsert = true;
    PageType = API;
    APIPublisher = 'navipartner';
    APIGroup = 'powerBI';
    APIVersion = 'v1.0';
    SourceTable = "NPR Magento Payment Line";
    EntitySetName = 'paymentLines';
    EntityName = 'paymentLine';
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            repeater(PaymentLineRepeater)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                }
                field(documentTableNo; Rec."Document Table No.")
                {
                    Caption = 'Document Table No.', Locked = true;
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type', Locked = true;
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No.', Locked = true;
                }
                field(paymentType; Rec."Payment Type")
                {
                    Caption = 'Payment Type', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount', Locked = true;
                }
                field(cardBrand; Rec.Brand)
                {
                    Caption = 'Card Brand', Locked = true;
                }
                field(capturedAt; Rec."Date Captured")
                {
                    Caption = 'Captured At', Locked = true;
                }
                field(refundedAt; Rec."Date Refunded")
                {
                    Caption = 'Refunded At', Locked = true;
                }
                field(canceledAt; Rec."Date Canceled")
                {
                    Caption = 'Canceled At', Locked = true;
                }
#if not (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'System Row Version', Locked = true;
                }
#endif
            }
        }
    }
}