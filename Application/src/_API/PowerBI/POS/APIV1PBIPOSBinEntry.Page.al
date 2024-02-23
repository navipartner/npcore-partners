page 6060001 "NPR APIV1 PBIPOSBinEntry"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'posBinEntry';
    EntitySetName = 'posBinEntries';
    Caption = 'PowerBI POS Bin Entry';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR POS Bin Entry";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(posStoreCode; Rec."POS Store Code")
                {
                    Caption = 'POS Store Code', Locked = true;
                }
                field(posUnitNo; Rec."POS Unit No.")
                {
                    Caption = 'POS Unit No.', Locked = true;
                }
                field(type; Rec.Type)
                {
                    Caption = 'Type', Locked = true;
                }
                field(paymentMethodCode; Rec."Payment Method Code")
                {
                    Caption = 'Payment Method Code', Locked = true;
                }
                field(transactionDate; Rec."Transaction Date")
                {
                    Caption = 'Transaction Date', Locked = true;
                }
                field(transactionTime; Rec."Transaction Time")
                {
                    Caption = 'Transaction Time', Locked = true;
                }
                field(accountingPeriodCode; Rec."Accounting Period Code")
                {
                    Caption = 'Accounting Period Code', Locked = true;
                }
                field(transactionAmount; Rec."Transaction Amount")
                {
                    Caption = 'Transaction Amount', Locked = true;
                }
                field(transactionCurrencyCode; Rec."Transaction Currency Code")
                {
                    Caption = 'Transaction Currency Code', Locked = true;
                }
                field(transactionAmountLcy; Rec."Transaction Amount (LCY)")
                {
                    Caption = 'Transaction Amount (LCY)', Locked = true;
                }
                field(posEntryNo; Rec."POS Entry No.")
                {
                    Caption = 'POS Entry No.', Locked = true;
                }
                field(posPaymentLineNo; Rec."POS Payment Line No.")
                {
                    Caption = 'POS Payment Line No.', Locked = true;
                }
                field(lastModifiedDateTime; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt))
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
            }
        }
    }

    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
}