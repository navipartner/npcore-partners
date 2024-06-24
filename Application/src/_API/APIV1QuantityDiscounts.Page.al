page 6184682 "NPR APIV1 Quantity Discounts"
{
    Caption = 'APIV1 Quantity Discounts';
    Extensible = false;
    Editable = false;
    DelayedInsert = true;
    PageType = API;
    APIPublisher = 'navipartner';
    APIGroup = 'core';
    APIVersion = 'v1.0';
    EntityName = 'quantityDiscount';
    EntitySetName = 'quantityDiscounts';
    SourceTable = "NPR Quantity Discount Header";
    ODataKeyFields = SystemId;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            repeater(DiscountRepeater)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'System Id', Locked = true;
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.', Locked = true;
                }
                field(mainNo; Rec."Main No.")
                {
                    Caption = 'Main No.', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'Starting Date', Locked = true;
                }
                field(startingTime; Rec."Starting Time")
                {
                    Caption = 'Starting Time', Locked = true;
                }
                field(closingDate; Rec."Closing Date")
                {
                    Caption = 'Closing Date', Locked = true;
                }
                field(closingTime; Rec."Closing Time")
                {
                    Caption = 'Closing Time', Locked = true;
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status', Locked = true;
                }
                field(blockCustomDiscount; Rec."Block Custom Discount")
                {
                    Caption = 'Block Custom Discount', Locked = true;
                }
                field(campaignRef; Rec."Campaign Ref.")
                {
                    Caption = 'Campaign Ref.', Locked = true;
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
                part(quantityDiscountLines; "NPR APIV1 Quantity Disc. Lines")
                {
                    Caption = 'Quantity Discount Lines';
                    EntityName = 'quantityDiscountLine';
                    EntitySetName = 'quantityDiscountLines';
                    SubPageLink = "Item No." = field("Item No."), "Main no." = field("Main No.");
                }
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