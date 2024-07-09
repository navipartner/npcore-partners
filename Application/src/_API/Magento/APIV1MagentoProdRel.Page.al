page 6150847 "NPR API V1 Magento Prod. Rel."
{
    APIGroup = 'magento';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'magentoProductRelation';
    EntitySetName = 'magentoProductRelations';
    EntityCaption = 'Magento Product Relation';
    EntitySetCaption = 'Magento Product Relations';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Magento Product Relation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'System Id', Locked = true;
                    Editable = false;
                }

                field(relationType; Rec."Relation Type")
                {
                    Caption = 'Relation Type', Locked = true;
                }

                field(fromItemNo; Rec."From Item No.")
                {
                    Caption = 'From Item No.', Locked = true;
                }
                field(toItemNo; Rec."To Item No.")
                {
                    Caption = 'To Item No.', Locked = true;
                }

                field(position; Rec.Position)
                {
                    Caption = 'Position', Locked = true;
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
