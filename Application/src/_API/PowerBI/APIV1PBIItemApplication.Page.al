page 6059927 "NPR APIV1 PBIItemApplication"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'itemApplication';
    EntitySetName = 'itemApplications';
    Caption = 'PowerBI Item Application';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Item Application Entry";
    Extensible = false;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(costApplication; Rec."Cost Application")
                {
                    Caption = 'Cost Application', Locked = true;
                }
                field(createdByUser; Rec."Created By User")
                {
                    Caption = 'Created By User', Locked = true;
                }
                field(creationDate; Rec."Creation Date")
                {
                    Caption = 'Creation Date', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(inboundItemEntryNo; Rec."Inbound Item Entry No.")
                {
                    Caption = 'Inbound Item Entry No.', Locked = true;
                }
                field(itemLedgerEntryNo; Rec."Item Ledger Entry No.")
                {
                    Caption = 'Item Ledger Entry No.', Locked = true;
                }
                field(lastModifiedByUser; Rec."Last Modified By User")
                {
                    Caption = 'Last Modified By User', Locked = true;
                }
                field(lastModifiedDate; Rec."Last Modified Date")
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(outboundEntryisUpdated; Rec."Outbound Entry is Updated")
                {
                    Caption = 'Outbound Entry is Updated', Locked = true;
                }
                field(outboundItemEntryNo; Rec."Outbound Item Entry No.")
                {
                    Caption = 'Outbound Item Entry No.', Locked = true;
                }
                field(outputCompletelyInvdDate; Rec."Output Completely Invd. Date")
                {
                    Caption = 'Output Completely Invd. Date', Locked = true;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date', Locked = true;
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity', Locked = true;
                }
                field(transferredfromEntryNo; Rec."Transferred-from Entry No.")
                {
                    Caption = 'Transferred-from Entry No.', Locked = true;
                }
            }
        }
    }
}

