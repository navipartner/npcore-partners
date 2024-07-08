page 6060016 "NPR APIV1 - MagentoCatLink"
{
    APIGroup = 'magento';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'magentoCategoryLink';
    EntitySetName = 'magentoCategoryLinks';
    EntityCaption = 'Magento Category Link';
    EntitySetCaption = 'Magento Category Links';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Magento Category Link";

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

                field(categoryId; Rec."Category Id")
                {
                    Caption = 'Category Id', Locked = true;
                }

                field(categoryName; Rec."Category Name")
                {
                    Caption = 'Category Name', Locked = true;
                }

                field(position; Rec.Position)
                {
                    Caption = 'Position', Locked = true;
                }

                field(rootNo; Rec."Root No.")
                {
                    Caption = 'Root No.', Locked = true;
                }

                field(disabled; Rec.disabled)
                {
                    Caption = 'disabled', Locked = true;
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
