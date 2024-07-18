page 6150782 "NPR APIV1 PBIMMMember"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'mmMember';
    EntitySetName = 'mmMember';
    Caption = 'PowerBI MM Member';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR MM Member";
    Extensible = false;
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(blocked; Rec."Blocked")
                {
                    Caption = 'Blocked', Locked = True;
                }
                field(city; Rec."City")
                {
                    Caption = 'City', Locked = True;
                }
                field(country; Rec."Country")
                {
                    Caption = 'Country', Locked = True;
                }
                field(countryCode; Rec."Country Code")
                {
                    Caption = 'Country Code', Locked = True;
                }
                field(createdDatetime; Rec."Created Datetime")
                {
                    Caption = 'Created Datetime', Locked = True;
                }
                field(displayName; Rec."Display Name")
                {
                    Caption = 'Display Name', Locked = True;
                }
                field(externalMemberNo; Rec."External Member No.")
                {
                    Caption = 'External Member No.', Locked = True;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Time', Locked = true;
                }
            }
        }
    }
}