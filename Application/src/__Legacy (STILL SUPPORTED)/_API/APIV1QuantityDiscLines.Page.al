page 6184683 "NPR APIV1 Quantity Disc. Lines"
{
    Caption = 'APIV1 Quantity Discount Lines';
    Extensible = false;
    Editable = false;
    DelayedInsert = true;
    PageType = API;
    APIPublisher = 'navipartner';
    APIGroup = 'core';
    APIVersion = 'v1.0';
    EntityName = 'quantityDiscountLine';
    EntitySetName = 'quantityDiscountLines';
    SourceTable = "NPR Quantity Discount Line";
    ODataKeyFields = SystemId;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            repeater(DiscountLineRepeater)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'System Id', Locked = true;
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.', Locked = true;
                }
                field(mainNo; Rec."Main no.")
                {
                    Caption = 'Main No.', Locked = true;
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity', Locked = true;
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price', Locked = true;
                }
                field(total; Rec.Total)
                {
                    Caption = 'Total', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'System Modified At', Locked = true;
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

    trigger OnInit()
    begin
#if (BC17 or BC18 or BC19 or BC20 or BC21)
        CurrentTransactionType := TransactionType::Snapshot;
#else
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
#endif
    end;
}