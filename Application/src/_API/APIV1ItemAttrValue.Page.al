page 6150822 "NPR API V1 - Item Attr Value"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Item Attribute Value';
    DelayedInsert = true;
    EntityName = 'itemAttributeValue';
    EntitySetName = 'itemAttributeValues';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Item Attribute Value";

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

                field(attributeId; Rec."Attribute ID")
                {
                    Caption = 'attributeId', Locked = true;
                }

                field(attributeValueId; Rec.ID)
                {
                    Caption = 'attributeValueId', Locked = true;
                }
                field(value; Rec.Value)
                {
                    Caption = 'value', Locked = true;
                }
                field(numericValue; Rec."Numeric Value")
                {
                    Caption = 'numericValue', Locked = true;
                }
                field(dateValue; Rec."Date Value")
                {
                    Caption = 'dateValue', Locked = true;
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'blocked', Locked = true;
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
