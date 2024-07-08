page 6150764 "NPR APIV1 - Arch Vouch Entries"
{
    APIGroup = 'retailVoucher';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Archived Voucher Entries';
    DataAccessIntent = ReadOnly;
    DelayedInsert = true;
    Editable = false;
    EntityName = 'archivedVoucherEntry';
    EntitySetName = 'archivedVoucherEntries';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR NpRv Arch. Voucher Entry";

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

                field(archVoucherNo; Rec."Arch. Voucher No.")
                {
                    Caption = 'Arch. Voucher No.', Locked = true;
                }

                field(entryType; Rec."Entry Type")
                {
                    Caption = 'Entry Type', Locked = true;
                }

                field(voucherType; Rec."Voucher Type")
                {
                    Caption = 'Voucher Type', Locked = true;
                }

                field(positive; Rec.Positive)
                {
                    Caption = 'Positive', Locked = true;
                }

                field(amount; Rec.Amount)
                {
                    Caption = 'Amount', Locked = true;
                }

                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date', Locked = true;
                }

                field(ppen; Rec.Open)
                {
                    Caption = 'Open', Locked = true;
                }

                field(correction; Rec.Correction)
                {
                    Caption = 'Correction', Locked = true;
                }

                field(remainingAmount; Rec."Remaining Amount")
                {
                    Caption = 'Remaining Amount', Locked = true;
                }

                field(registerNo; Rec."Register No.")
                {
                    Caption = 'Register No.', Locked = true;
                }

                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type', Locked = true;
                }

                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No.', Locked = true;
                }

                field(documentLineNo; Rec."Document Line No.")
                {
                    Caption = 'Document Line No.', Locked = true;
                }

                field(externalDocumentNo; Rec."External Document No.")
                {
                    Caption = 'External Document No.', Locked = true;
                }

                field("userId"; Rec."User ID")
                {
                    Caption = 'User ID', Locked = true;
                }

                field(partnerCode; Rec."Partner Code")
                {
                    Caption = 'Partner Code', Locked = true;
                }

                field(closedByEntryNo; Rec."Closed by Entry No.")
                {
                    Caption = 'Closed by Entry No.', Locked = true;
                }

                field(closedByPartnerCode; Rec."Closed by Partner Code")
                {
                    Caption = 'Closed by Partner Code', Locked = true;
                }

                field(partnerClearing; Rec."Partner Clearing")
                {
                    Caption = 'Partner Clearing', Locked = true;
                }

                field(originalEntryNo; Rec."Original Entry No.")
                {
                    Caption = 'Original Entry No.', Locked = true;
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'systemModifiedAt', Locked = true;
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