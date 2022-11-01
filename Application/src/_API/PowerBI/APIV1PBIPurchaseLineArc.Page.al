page 6060062 "NPR APIV1 PBIPurchase Line Arc"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'purchaseLineArchive';
    EntitySetName = 'purchaseLineArchives';
    Caption = 'PowerBI Purchase Line Archive';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Purchase Line Archive";
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
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No.', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }
                field(quantity; Rec."Quantity")
                {
                    Caption = 'Quantity', Locked = true;
                }
                field(quantityReceived; Rec."Quantity Received")
                {
                    Caption = 'Quantity Received', Locked = true;
                }
                field(amountIncludingVAT; Rec."Amount Including VAT")
                {
                    Caption = 'Amount Including VAT', Locked = true;
                }
                field(amount; Rec."Amount")
                {
                    Caption = 'Amount', Locked = true;
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code', Locked = true;
                }
            }
        }
    }
}