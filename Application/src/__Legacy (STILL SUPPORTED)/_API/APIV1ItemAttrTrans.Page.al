page 6150824 "NPR API V1 - Item Attr Trans"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Item Attribute Translation';
    DelayedInsert = true;
    EntityName = 'itemAttributeTranslation';
    EntitySetName = 'itemAttributeTranslations';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Item Attribute Translation";

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
                    Caption = 'id', Locked = true;
                }
                field(languageCode; Rec."Language Code")
                {
                    Caption = 'languageCode', Locked = true;
                }
                field(name; Rec.Name)
                {
                    Caption = 'name', Locked = true;
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

