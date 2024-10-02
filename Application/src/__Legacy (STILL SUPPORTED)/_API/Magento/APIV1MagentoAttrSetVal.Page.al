page 6060021 "NPR APIV1 - MagentoAttrSetVal"
{
    APIGroup = 'magento';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'magentoAttributeSetValue';
    EntitySetName = 'magentoAttributeSetValues';
    EntityCaption = 'Magento Attribute Set Value';
    EntitySetCaption = 'Magento Attribute Set Value';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Magento Attr. Set Value";

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
                field(attributeSetId; Rec."Attribute Set ID")
                {
                    Caption = 'Attribute Set ID', Locked = true;
                }
                field(attributeId; Rec."Attribute ID")
                {
                    Caption = 'Attribute Set ID', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(position; Rec.Position)
                {
                    Caption = 'Position', Locked = true;
                }
                field(attributeGroupId; Rec."Attribute Group ID")
                {
                    Caption = 'Attribute Group ID', Locked = true;
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
