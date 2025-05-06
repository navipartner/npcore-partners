page 6150788 "NPR APIV1 PBIMMMemberCard"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'mmMemberCard';
    EntitySetName = 'mmMemberCard';
    Caption = 'PowerBI MM Member Card';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR MM Member Card";
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
                field(blockReason; Rec."Block Reason")
                {
                    Caption = 'Block Reason';
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';
                }
                field(blockedAt; Rec."Blocked At")
                {
                    Caption = 'Blocked At';
                }
                field(blockedBy; Rec."Blocked By")
                {
                    Caption = 'Blocked By';
                }
                field(cardIsTemporary; Rec."Card Is Temporary")
                {
                    Caption = 'Card Is Temporary';
                }
                field(cardType; Rec."Card Type")
                {
                    Caption = 'Card Type';
                }
                field(companyName; Rec."Company Name")
                {
                    Caption = 'Company Name';
                }
                field(displayName; Rec."Display Name")
                {
                    Caption = 'Display Name';
                }
                field(documentID; Rec."Document ID")
                {
                    Caption = 'Document ID';
                }
                field(eMailAddress; Rec."E-Mail Address")
                {
                    Caption = 'E-Mail Address';
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                }
                field(externalCardNo; Rec."External Card No.")
                {
                    Caption = 'External Card No.';
                }
                field(externalMemberNo; Rec."External Member No.")
                {
                    Caption = 'External Member No.';
                }
                field(externalCardNoLast4; Rec."External Card No. Last 4")
                {
                    Caption = 'External Card No. Last 4';
                }
                field(externalMembershipNo; Rec."External Membership No.")
                {
                    Caption = 'External Membership No.';
                }
                field(memberBlocked; Rec."Member Blocked")
                {
                    Caption = 'Member Blocked';
                }
                field(memberEntryNo; Rec."Member Entry No.")
                {
                    Caption = 'Member Entry No.';
                }
                field(membershipBlocked; Rec."Membership Blocked")
                {
                    Caption = 'Membership Blocked';
                }
                field(membershipCode; Rec."Membership Code")
                {
                    Caption = 'Membership Code';
                }
                field(membershipEntryNo; Rec."Membership Entry No.")
                {
                    Caption = 'Membership Entry No.';
                }
                field(pinCode; Rec."Pin Code")
                {
                    Caption = 'Pin Code';
                }
                field(validUntil; Rec."Valid Until")
                {
                    Caption = 'Valid Until';
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