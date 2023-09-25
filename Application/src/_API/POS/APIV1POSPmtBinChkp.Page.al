page 6150769 "NPR APIV1 - POS Pmt. Bin Chkp."
{
    APIGroup = 'pos';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'apiv1PosPaymentBinCheckpoint';
    DataAccessIntent = ReadOnly;
    DelayedInsert = true;
    Editable = false;
    EntityName = 'posPaymentBinCheckpoint';
    EntitySetName = 'posPaymentBinCheckpoints';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR POS Payment Bin Checkp.";

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
                field(paymentBinNo; Rec."Payment Bin No.")
                {
                    Caption = 'Payment Bin No.', Locked = true;
                }
                field(paymentTypeNo; Rec."Payment Type No.")
                {
                    Caption = 'Payment Type No.', Locked = true;
                }
                field(comment; Rec.Comment)
                {
                    Caption = 'Comment', Locked = true;
                }
                field(workshiftCheckpointEntryNo; Rec."Workshift Checkpoint Entry No.")
                {
                    Caption = 'Workshift Checkpoint Entry No.', Locked = true;
                }
                field(calculatedAmountInclFloat; Rec."Calculated Amount Incl. Float")
                {
                    Caption = 'Calculated Amount Incl. Float', Locked = true;
                }
                field(calculatedQuantity; Rec."Calculated Quantity")
                {
                    Caption = 'Calculated Quantity', Locked = true;
                }
                field(floatAmount; Rec."Float Amount")
                {
                    Caption = 'Float Amount', Locked = true;
                }
                field(newFloatAmount; Rec."New Float Amount")
                {
                    Caption = 'New Float Amount', Locked = true;
                }
                field(countedAmountInclFloat; Rec."Counted Amount Incl. Float")
                {
                    Caption = 'Counted Amount Incl. Float', Locked = true;
                }
                field(checkpointDate; Rec."Checkpoint Date")
                {
                    Caption = 'Checkpoint Date', Locked = true;
                }
                field(checkpointTime; Rec."Checkpoint Time")
                {
                    Caption = 'Checkpoint Time', Locked = true;
                }
                field(paymentBinEntryAmountLCY; Rec."Payment Bin Entry Amount (LCY)")
                {
                    Caption = 'Payment Bin Entry Amount (LCY)', Locked = true;
                }
                field(bankDepositAmount; Rec."Bank Deposit Amount")
                {
                    Caption = 'Bank Deposit Amount', Locked = true;
                }
                field(moveToBinAmount; Rec."Move to Bin Amount")
                {
                    Caption = 'Move to Bin Amount', Locked = true;
                }
                field(paymentBinEntryAmount; Rec."Payment Bin Entry Amount")
                {
                    Caption = 'Payment Bin Entry Amount', Locked = true;
                }
                field(transferInAmount; Rec."Transfer In Amount")
                {
                    Caption = 'Transfer In Amount', Locked = true;
                }
                field(transferOutAmount; Rec."Transfer Out Amount")
                {
                    Caption = 'Transfer Out Amount', Locked = true;
                }
                field(createdOn; Rec."Created On")
                {
                    Caption = 'Created On', Locked = true;
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