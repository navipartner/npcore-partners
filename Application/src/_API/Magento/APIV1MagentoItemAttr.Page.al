page 6060022 "NPR APIV1 - Magento Item Attr."
{
    APIGroup = 'magento';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'magentoItemAttribute';
    EntitySetName = 'magentoItemAttributes';
    EntityCaption = 'Magento Item Attribute';
    EntitySetCaption = 'Magento Item Attributes';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Magento Item Attr.";

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
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.', Locked = true;
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code', Locked = true;
                }
                field(attributeSetId; Rec."Attribute Set ID")
                {
                    Caption = 'Attribute Set ID', Locked = true;
                }
                field(attributeId; Rec."Attribute ID")
                {
                    Caption = 'Attribute ID', Locked = true;
                }
                field(attributeDescription; Rec."Attribute Description")
                {
                    Caption = 'Attribute Description', Locked = true;
                }
                field(selected; Rec.Selected)
                {
                    Caption = 'Selected', Locked = true;
                }
                field(attributeGroupId; Rec."Attribute Group ID")
                {
                    Caption = 'Attribute Group ID', Locked = true;
                }
                field(replicationCounter; Rec."Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                    ObsoleteState = Pending;
                    ObsoleteTag = 'NPR23.0';
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
