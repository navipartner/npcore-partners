page 6150823 "NPR API V1 - Item Attr Val Map"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Item Attribute Value Mapping';
    DelayedInsert = true;
    EntityName = 'itemAttributeValueMapping';
    EntitySetName = 'itemAttributeValueMappings';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Item Attribute Value Mapping";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'systemId', Locked = true;
                }
                field(tableId; Rec."Table ID")
                {
                    Caption = 'attributeId', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'attributeId', Locked = true;
                }
                field(itemAttributeId; Rec."Item Attribute ID")
                {
                    Caption = 'itemAttributeId', Locked = true;
                }
                field(itemAttributeValueId; Rec."Item Attribute Value ID")
                {
                    Caption = 'itemAttributeValueId', Locked = true;
                }
                field(replicationCounter; Rec."NPR Replication Counter")
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

    trigger OnInit()
    begin
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        CurrentTransactionType := TransactionType::Update;
#ELSE
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
    end;
}