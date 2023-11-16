page 6059967 "NPR APIV1 PBITMDetTicketAccess"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'detTMTicketAccess';
    EntitySetName = 'detTMTicketsAccess';
    Caption = 'PowerBI TM Detailed Ticket Access Entry';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR TM Det. Ticket AccessEntry";
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
                field(closedByEntryNo; Rec."Closed By Entry No.")
                {
                    Caption = 'Closed By Entry No.', Locked = true;
                }
                field(createdDatetime; Rec."Created Datetime")
                {
                    Caption = 'Created Datetime', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(open; Rec.Open)
                {
                    Caption = 'Open', Locked = true;
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity', Locked = true;
                }
                field(ticketAccessEntryNo; Rec."Ticket Access Entry No.")
                {
                    Caption = 'Ticket Access Entry No.', Locked = true;
                }
                field(type; Rec."Type")
                {
                    Caption = 'Type', Locked = true;
                }
                field(externalAdmSchEntryNo; Rec."External Adm. Sch. Entry No.")
                {
                    Caption = 'External Adm. Sch. Entry No.', Locked = true;
                }
                field(ticketNo; Rec."Ticket No.")
                {
                    Caption = 'Ticket No.';
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

    trigger OnOpenPage()
    var
        CurrRecordRef: RecordRef;
    begin
        CurrRecordRef.GetTable(Rec);
        PowerBIUtils.UpdateSystemModifiedAtfilter(CurrRecordRef);
    end;

    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
}