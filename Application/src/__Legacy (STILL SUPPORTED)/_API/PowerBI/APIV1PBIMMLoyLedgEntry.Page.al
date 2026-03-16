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
    trigger OnAfterGetRecord()
    begin
        if (Rec."Card Number" = '') and (Rec."Membership Entry No." <> 0) then
            Rec."Card Number" := GetFirstMemberCard(Rec."Membership Entry No.");
    end;

    local procedure GetFirstMemberCard(MembershipEntryNo: Integer): Text[50]
    var
        MemberCard: Record "NPR MM Member Card";
    begin
        MemberCard.SetFilter(Blocked, '=%1', false);
        MemberCard.SetRange("Membership Entry No.", MembershipEntryNo);
        MemberCard.SetFilter("Member Entry No.", '<>0');
        MemberCard.SetLoadFields("External Card No.");
        if (MemberCard.FindFirst()) then
            exit(CopyStr(MemberCard."External Card No.", 1, 50));
    end;

#IF NOT (BC17 or BC18 or BC19 or BC20)
    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";

#ENDIF
}