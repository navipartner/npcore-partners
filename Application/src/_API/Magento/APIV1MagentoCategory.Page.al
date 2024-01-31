page 6060015 "NPR APIV1 - Magento Category"
{
    APIGroup = 'magento';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'magentoCategory';
    EntitySetName = 'magentoCategories';
    EntityCaption = 'Magento Category';
    EntitySetCaption = 'Magento Categories';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Magento Category";

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
                field(parentCategoryId; Rec."Parent Category Id")
                {
                    Caption = 'Parent Category Id', Locked = true;
                }
                field(level; Rec.Level)
                {
                    Caption = 'Level', Locked = true;
                }
                field(path; Rec.Path)
                {
                    Caption = 'Path', Locked = true;
                }
                field(isActive; Rec."Is Active")
                {
                    Caption = 'Is Active', Locked = true;
                }
                field(isAnchor; Rec."Is Anchor")
                {
                    Caption = 'Is Anchor', Locked = true;
                }
                field(showInNavigationMenu; Rec."Show In Navigation Menu")
                {
                    Caption = 'Show In Navigation Menu', Locked = true;
                }
                field(root; Rec.Root)
                {
                    Caption = 'Root', Locked = true;
                }
                field(rootNo; Rec."Root No.")
                {
                    Caption = 'Root No.', Locked = true;
                }
                field(icon; Rec.Icon)
                {
                    Caption = 'Icon', Locked = true;
                }
                field(shortDescription; Rec."Short Description")
                {
                    Caption = 'Short Description', Locked = true;
                }
                field(picture; Rec.Picture)
                {
                    Caption = 'Picture', Locked = true;
                }
                field("sorting"; Rec.Sorting)
                {
                    Caption = 'Sorting', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(seoLink; Rec."Seo Link")
                {
                    Caption = 'Seo Link', Locked = true;
                }
                field(metaTitle; Rec."Meta Title")
                {
                    Caption = 'Meta Title', Locked = true;
                }
                field(metaKeywords; Rec."Meta Keywords")
                {
                    Caption = 'Meta Keywords', Locked = true;
                }
                field(metaDescription; Rec."Meta Description")
                {
                    Caption = 'Meta Description', Locked = true;
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
