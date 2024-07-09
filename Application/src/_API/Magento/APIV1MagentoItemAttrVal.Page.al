page 6060023 "NPR APIV1 - MagentoItemAttrVal"
{
    APIGroup = 'magento';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'magentoItemAttributeValue';
    EntitySetName = 'magentoItemAttributeValues';
    EntityCaption = 'Magento Item Attribute Value';
    EntitySetCaption = 'Magento Item Attribute Values';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Magento Item Attr. Value";

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
                field(type; Rec.Type)
                {
                    Caption = 'Type', Locked = true;
                }
                field(attributeLabelLineNo; Rec."Attribute Label Line No.")
                {
                    Caption = 'Attribute Label Line No.', Locked = true;
                }

                field(picture; Rec.Picture)
                {
                    Caption = 'Picture', Locked = true;
                }
                field(attributeSetId; Rec."Attribute Set ID")
                {
                    Caption = 'Attribute Set ID', Locked = true;
                }
                field(selected; Rec.Selected)
                {
                    Caption = 'Selected', Locked = true;
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.', Locked = true;
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code', Locked = true;
                }
                field(longValue; Rec."Long Value")
                {
                    Caption = 'Long Value', Locked = true;
                }
                field(value; Rec.Value)
                {
                    Caption = 'Value', Locked = true;
                }
                field(attributeDescription; Rec."Attribute Description")
                {
                    Caption = 'Attribute Description', Locked = true;
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
