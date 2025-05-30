page 6150849 "NPR API V1 PBI ArchCouponEntry"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'archivedcouponentry';
    EntitySetName = 'archivedcouponsentries';
    Caption = 'PowerBI Archived Coupon Entries';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    Extensible = false;
    Editable = false;
    SourceTable = "NPR NpDc Arch.Coupon Entry";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount';
                }
                field(amountPerQty; Rec."Amount per Qty.")
                {
                    Caption = 'Amount per Qty.';
                }
                field(archCouponNo; Rec."Arch. Coupon No.")
                {
                    Caption = 'Arch. Coupon No.';
                }
                field(closedByEntryNo; Rec."Closed by Entry No.")
                {
                    Caption = 'Closed by Entry No.';
                }
                field(couponType; Rec."Coupon Type")
                {
                    Caption = 'Coupon Type';
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No.';
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type';
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                }
                field(entryType; Rec."Entry Type")
                {
                    Caption = 'Entry Type';
                }
                field(open; Rec.Open)
                {
                    Caption = 'Open';
                }
                field(positive; Rec.Positive)
                {
                    Caption = 'Positive';
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(registerNo; Rec."Register No.")
                {
                    Caption = 'Register No.';
                }
                field(remainingQuantity; Rec."Remaining Quantity")
                {
                    Caption = 'Remaining Quantity';
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'SystemCreatedAt';
                }
                field(systemCreatedBy; Rec.SystemCreatedBy)
                {
                    Caption = 'SystemCreatedBy';
                }
                field(systemId; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'SystemModifiedAt';
                }
                field(systemModifiedBy; Rec.SystemModifiedBy)
                {
                    Caption = 'SystemModifiedBy';
                }
                field("userID"; Rec."User ID")
                {
                    Caption = 'User ID';
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
