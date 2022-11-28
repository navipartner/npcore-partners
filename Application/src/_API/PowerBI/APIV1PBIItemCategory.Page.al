page 6059928 "NPR APIV1 PBIItemCategory"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'itemCategory';
    EntitySetName = 'itemCategories';
    Caption = 'PowerBI Item Category';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Item Category";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field("code"; Rec."Code")
                {
                    Caption = 'Code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(parentCategory; Rec."Parent Category")
                {
                    Caption = 'Parent Category', Locked = true;
                }
                field(hasChildren; Rec.HasChildren)
                {
                    Caption = 'Has Children', locked = true;
                }
                field(indentation; Rec.Indentation)
                {
                    Caption = 'Indentation', locked = true;
                }
            }
        }
    }
}