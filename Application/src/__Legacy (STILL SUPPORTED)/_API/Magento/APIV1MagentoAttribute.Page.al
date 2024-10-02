page 6060018 "NPR APIV1 - Magento Attribute"
{
    APIGroup = 'magento';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'magentoAttribute';
    EntitySetName = 'magentoAttributes';
    EntityCaption = 'Magento Attribute';
    EntitySetCaption = 'Magento Attributes';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Magento Attribute";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }
                field(attributeId; Rec."Attribute ID")
                {
                    Caption = 'Attribute ID', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(filterable; Rec.Filterable)
                {
                    Caption = 'Filterable', Locked = true;
                }
                field(position; Rec.Position)
                {
                    Caption = 'Position', Locked = true;
                }
                field(visible; Rec.Visible)
                {
                    Caption = 'Visible', Locked = true;
                }
                field(type; Rec.Type)
                {
                    Caption = 'Type', Locked = true;
                }
                field(usedByAttributeSet; Rec."Used by Attribute Set")
                {
                    Caption = 'Used by Attribute Set', Locked = true;
                }
                field(showOptionImagesIsFrontend; Rec."Show Option Images Is Frontend")
                {
                    Caption = 'Show Option Images Is Frontend', Locked = true;
                }
                field(useInProductListing; Rec."Use in Product Listing")
                {
                    Caption = 'Use in Product Listing', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(customId; Rec."Custom ID")
                {
                    Caption = 'Custom ID', Locked = true;
                }
                field(usedByItems; Rec."Used by Items")
                {
                    Caption = 'Used by Items', Locked = true;
                }
                field(replicationCounter; Rec."Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                    ObsoleteState = Pending;
                    ObsoleteTag = '2023-06-28';
                    ObsoleteReason = 'Replaced by SystemRowVersion';
                }
#IF NOT (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'systemRowVersion', Locked = true;
                }
#ENDIF
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        CurrentTransactionType := TransactionType::Update;
#ELSE
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
    end;

}
