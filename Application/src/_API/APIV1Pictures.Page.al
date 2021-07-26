page 6014536 "NPR APIV1 - Pictures"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityCaption = 'Picture';
    EntitySetCaption = 'Pictures';
    EntityName = 'picture';
    EntitySetName = 'pictures';
    Extensible = false;
    InsertAllowed = false;
    ODataKeyFields = Id;
    PageType = API;
    SourceTable = "Picture Entity";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Id)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(parentType; "Parent Type")
                {
                    Caption = 'Parent Type';
                    Editable = false;
                }
                field(width; Width)
                {
                    Caption = 'Width';
                    Editable = false;
                }
                field(height; Height)
                {
                    Caption = 'Height';
                    Editable = false;
                }
                field(contentType; "Mime Type")
                {
                    Caption = 'Content Type';
                    Editable = false;
                }
                field(pictureContent; Content)
                {
                    Caption = 'Picture Content';
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

    trigger OnDeleteRecord(): Boolean
    begin
        DeletePictureWithParentType();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        PictureEntityParentType: Enum "Picture Entity Parent Type";
        ParentIdFilter: Text;
        ParentTypeFilter: Text;
    begin
        if not DataLoaded then begin
            ParentIdFilter := GetFilter(Id);
            ParentTypeFilter := GetFilter("Parent Type");
            if (ParentTypeFilter = '') or (ParentIdFilter = '') then begin
                FilterGroup(4);
                ParentIdFilter := GetFilter(Id);
                ParentTypeFilter := GetFilter("Parent Type");
                FilterGroup(0);
                if (ParentTypeFilter = '') or (ParentIdFilter = '') then
                    Error(ParentNotSpecifiedErr)
            end;
            Evaluate(PictureEntityParentType, ParentTypeFilter);
            LoadDataWithParentType(ParentIdFilter, PictureEntityParentType);
            Insert(true);
        end;

        DataLoaded := true;
        exit(true);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        SavePictureWithParentType();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        SavePictureWithParentType();
    end;

    var
        ParentNotSpecifiedErr: Label 'You must get to the parent first to get to the picture.';
        DataLoaded: Boolean;
}

