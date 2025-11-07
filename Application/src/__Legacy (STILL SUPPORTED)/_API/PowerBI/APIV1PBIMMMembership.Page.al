page 6059933 "NPR APIV1 PBIMMMembership"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'mmMembership';
    EntitySetName = 'mmMemberships';
    Caption = 'PowerBI MM Membership';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR MM Membership";
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
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(membershipCode; Rec."Membership Code")
                {
                    Caption = 'Membership Code', Locked = true;
                }
                field(externalMembershipNo; Rec."External Membership No.")
                {
                    Caption = 'External Membership No.', Locked = true;
                }
                field(communitycode; Rec."Community Code")
                {
                    Caption = 'Community Code', Locked = true;
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Time', Locked = true;
                }
                field(autoRenew; Rec."Auto-Renew")
                {
                    Caption = 'Auto-Renew', Locked = true;
                }
                field(autoRenewPaymentMethodCode; Rec."Auto-Renew Payment Method Code")
                {
                    Caption = 'Auto-Renew Payment Method Code', Locked = true;
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'System Created At', Locked = true;
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