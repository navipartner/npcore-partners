page 6150921 "NPR APIV1 PBIMMMShipEntryLinks"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'mmMembershipEntryLink';
    EntitySetName = 'mmMembershipEntryLinks';
    Caption = 'PowerBI MM Membership Entry Links';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR MM Membership Entry Link";
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
                field(context; Rec.Context)
                {
                    Caption = 'Context';
                }
                field(contextPeriodEndingDate; Rec."Context Period Ending Date")
                {
                    Caption = 'Context Period Ending Date';
                }
                field(contextPeriodStartingDate; Rec."Context Period Starting Date")
                {
                    Caption = 'Context Period Starting Date';
                }
                field(documentLineNo; Rec."Document Line No.")
                {
                    Caption = 'Document Line No.';
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
                field(membershipLedgerEntryEntryNo; Rec."Membership Entry No.") // Note: ambiguous / bad name on source table
                {
                    Caption = 'Membership Ledger Entry No.';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
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