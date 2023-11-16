page 6150864 "NPR APIV1 PBIMMLoyLedgEntry"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'mmLoyaltyLedgerEntry';
    EntitySetName = 'mmLoyaltyLedgerEntries';
    Caption = 'PowerBI MM Loy. Ledger Entry';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR MM Loy. LedgerEntry (Srvr)";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(id; Rec.SystemId) { }
                field(entryNo; Rec."Entry No.") { }
                field(entryType; Rec."Entry Type") { }
                field(posStoreCode; Rec."POS Store Code") { }
                field(posUnitCode; Rec."POS Unit Code") { }
                field(cardNumber; Rec."Card Number") { }
                field(referenceNumber; Rec."Reference Number") { }
                field(foreignTransactionId; Rec."Foreign Transaction Id") { }
                field(transactionDate; Rec."Transaction Date") { }
                field(transactionTime; Rec."Transaction Time") { }
                field(authorizationCode; Rec."Authorization Code") { }
                field(earnedPoints; Rec."Earned Points") { }
                field(burnedPoints; Rec."Burned Points") { }
                field(balance; Rec.Balance) { }
                field(companyName; Rec."Company Name") { }
#IF NOT (BC17 or BC18 or BC19 or BC20)
                field(systemModifiedAt; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt)) { }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt) { }
                field(systemRowVersion; Rec.SystemRowVersion) { }
#ENDIF
            }
        }
    }

#IF NOT (BC17 or BC18 or BC19 or BC20)
    trigger OnOpenPage()
    var
        CurrRecordRef: RecordRef;
    begin
        CurrRecordRef.GetTable(Rec);
        PowerBIUtils.UpdateSystemModifiedAtfilter(CurrRecordRef);
    end;

    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
#ENDIF
}