page 6150766 "NPR APIV1 - POS Wks. Chkpt."
{
    APIGroup = 'pos';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'apiv1PosWorkshiftCheckpoint';
    DataAccessIntent = ReadOnly;
    DelayedInsert = true;
    Editable = false;
    EntityName = 'posWorkshiftCheckpoint';
    EntitySetName = 'posWorkshiftCheckpoints';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR POS Workshift Checkpoint";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(posEntryNo; Rec."POS Entry No.")
                {
                    Caption = 'POS Entry No.', Locked = true;
                }
                field(eftLCY; Rec."EFT (LCY)")
                {
                    Caption = 'Card Payment/EFT (LCY)', Locked = true;
                }
                field(profitAmountLCY; Rec."Profit Amount (LCY)")
                {
                    Caption = 'Profit Amount (LCY)', Locked = true;
                }
                field(creditSalesAmountLCY; Rec."Credit Sales Amount (LCY)")
                {
                    Caption = 'Credit Sales Amount (LCY)', Locked = true;
                }
                field(creditSalesCount; Rec."Credit Sales Count")
                {
                    Caption = 'Credit Sales Count', Locked = true;
                }
                field(cancelledSalesCount; Rec."Cancelled Sales Count")
                {
                    Caption = 'Cancelled Sales Count', Locked = true;
                }
                field(creditItemSalesLCY; Rec."Credit Item Sales (LCY)")
                {
                    Caption = 'Credit Item Sales (LCY)', Locked = true;
                }
                field(directSalesCount; Rec."Direct Sales Count")
                {
                    Caption = 'Direct Sales Count', Locked = true;
                }
                field(redeemedVouchersLCY; Rec."Redeemed Vouchers (LCY)")
                {
                    Caption = 'Redeemed Vouchers (LCY)', Locked = true;
                }
                field(redeemedCreditVoucherLCY; Rec."Redeemed Credit Voucher (LCY)")
                {
                    Caption = 'Redeemed Credit Voucher (LCY)', Locked = true;
                }
                field(issuedVouchersLCY; Rec."Issued Vouchers (LCY)")
                {
                    Caption = 'Issued Vouchers (LCY)', Locked = true;
                }
                field(createdCreditVoucherLCY; Rec."Created Credit Voucher (LCY)")
                {
                    Caption = 'Created Credit Voucher (LCY)', Locked = true;
                }
                field(createdAt; Rec."Created At")
                {
                    Caption = 'Created At', Locked = true;
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'SystemCreatedAt', Locked = true;
                }
#IF NOT (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'systemRowVersion', Locked = true;
                }
#ENDIF
            }
        }
    }
}