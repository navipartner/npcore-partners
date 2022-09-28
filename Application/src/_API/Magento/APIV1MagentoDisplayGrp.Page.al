page 6060024 "NPR APIV1 - MagentoDisplayGrp"
{
    APIGroup = 'magento';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'magentoDisplayGroup';
    EntitySetName = 'magentoDisplayGroups';
    EntityCaption = 'Magento Display Group';
    EntitySetCaption = 'Magento Display Groups';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Magento Display Group";

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
                field("code"; Rec.Code)
                {
                    Caption = 'Code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(replicationCounter; Rec."Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

}