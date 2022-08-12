page 6059932 NPRPBIMM_MembershipEntry
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'mmMembershipEntry';
    EntitySetName = 'mmMembershipEntries';
    Caption = 'PowerBI MM Membership Entry';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR MM Membership Entry";
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
                    Caption = 'Context', Locked = true;
                }
                field(createdAt; Rec."Created At")
                {
                    Caption = 'Created At', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.', Locked = true;
                }
                field(membershipCode; Rec."Membership Code")
                {
                    Caption = 'Membership Code', Locked = true;
                }
                field(membershipEntryNo; Rec."Membership Entry No.")
                {
                    Caption = 'Membership Entry No.', Locked = true;
                }
                field(validFromDate; Rec."Valid From Date")
                {
                    Caption = 'Valid From Date', Locked = true;
                }
                field(validUntilDate; Rec."Valid Until Date")
                {
                    Caption = 'Valid Until Date', Locked = true;
                }
            }
        }
    }
}