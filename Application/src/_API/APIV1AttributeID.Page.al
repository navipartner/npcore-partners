page 6014514 "NPR APIV1 - Attribute ID"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'attributeID';
    DelayedInsert = true;
    EntityName = 'attributeId';
    EntitySetName = 'attributeIds';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Attribute ID";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'systemId', Locked = true;
                }
                field(attributeCode; Rec."Attribute Code")
                {
                    Caption = 'attributeCode', Locked = true;
                }
                field(tableID; Rec."Table ID")
                {
                    Caption = 'tableID', Locked = true;
                }
                field(entityAttributeID; Rec."Entity Attribute ID")
                {
                    Caption = 'entityAttributeID', Locked = true;
                }
                field(keyLayout; Rec."Key Layout")
                {
                    Caption = 'keyLayout', Locked = true;
                }
                field(shortcutAttributeID; Rec."Shortcut Attribute ID")
                {
                    Caption = 'shortcutAttributeID', Locked = true;
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'systemModifiedAt', Locked = true;
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

    trigger OnInit()
    begin
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        CurrentTransactionType := TransactionType::Update;
#ELSE
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
    end;

}
