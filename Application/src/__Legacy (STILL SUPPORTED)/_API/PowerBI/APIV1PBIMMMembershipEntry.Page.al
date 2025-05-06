page 6059932 "NPR APIV1 PBIMMMembershipEntry"
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
                field(amount; Rec."Amount")
                {
                    Caption = 'Amount', Locked = True;
                }
                field(amountInclVAT; Rec."Amount Incl VAT")
                {
                    Caption = 'Amount Incl VAT', Locked = True;
                }
                field(blocked; Rec."Blocked")
                {
                    Caption = 'Blocked', Locked = True;
                }
                field(closedByEntryNo; Rec."Closed By Entry No.")
                {
                    Caption = 'Closed By Entry No_', Locked = True;
                }
                field(documentLineNo; Rec."Document Line No.")
                {
                    Caption = 'Document Line No_', Locked = True;
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No_', Locked = True;
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type', Locked = True;
                }
                field(durationDateformula; Rec."Duration Dateformula")
                {
                    Caption = 'Duration Dateformula', Locked = True;
                }
                field(importEntryDocumentID; Rec."Import Entry Document ID")
                {
                    Caption = 'Import Entry Document ID', Locked = True;
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No_', Locked = True;
                }
                field(memberCardEntryNo; Rec."Member Card Entry No.")
                {
                    Caption = 'Member Card Entry No_', Locked = True;
                }
                field(originalContext; Rec."Original Context")
                {
                    Caption = 'Original Context', Locked = True;
                }
                field(receiptNo; Rec."Receipt No.")
                {
                    Caption = 'Receipt No_', Locked = True;
                }
                field(sourceType; Rec."Source Type")
                {
                    Caption = 'Source Type', Locked = True;
                }
                field(lastModifiedDateTime; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt))
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
    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
}