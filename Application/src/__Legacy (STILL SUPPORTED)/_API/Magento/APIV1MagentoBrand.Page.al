page 6060017 "NPR APIV1 - Magento Brand"
{
    APIGroup = 'magento';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'magentoBrand';
    EntitySetName = 'magentoBrands';
    EntityCaption = 'Magento Brand';
    EntitySetCaption = 'Magento Brands';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Magento Brand";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id1; Rec.SystemId) // there is 'conflict' with field 'Id' from table: if they have same name it breaks the API service..
                {
                    Caption = 'System Id', Locked = true;
                    Editable = false;
                }
                field(id; Rec.Id)
                {
                    Caption = 'Id', Locked = true;
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name', Locked = true;
                }
                field(picture; Rec.Picture)
                {
                    Caption = 'Picture', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(seoLink; Rec."Seo Link")
                {
                    Caption = 'Seo Link', Locked = true;
                }
                field(shortDescription; Rec."Short Description")
                {
                    Caption = 'Short Description', Locked = true;
                }
                field(logoPicture; Rec."Logo Picture")
                {
                    Caption = 'Logo Picture', Locked = true;
                }
                field("sorting"; Rec.Sorting)
                {
                    Caption = 'Sorting', Locked = true;
                }
                field(metaTitle; Rec."Meta Title")
                {
                    Caption = 'Meta Title', Locked = true;
                }
                field(metaDescription; Rec."Meta Description")
                {
                    Caption = 'Meta Description', Locked = true;
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
