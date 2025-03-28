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
                field(id; Rec.Id)
                {
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }
                field(parentType; Rec."Parent Type")
                {
                    Caption = 'Parent Type', Locked = true;
                    Editable = false;
                }
                field(width; Rec.Width)
                {
                    Caption = 'Width', Locked = true;
                    Editable = false;
                }
                field(height; Rec.Height)
                {
                    Caption = 'Height', Locked = true;
                    Editable = false;
                }
                field(contentType; Rec."Mime Type")
                {
                    Caption = 'Content Type', Locked = true;
                    Editable = false;
                }
                field(pictureContent; Rec.Content)
                {
                    Caption = 'Picture Content', Locked = true;
                }
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

    trigger OnDeleteRecord(): Boolean
    begin
        Rec.DeletePictureWithParentType();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        PictureEntityParentType: Enum "Picture Entity Parent Type";
        ParentIdFilter: Text;
        ParentTypeFilter: Text;
    begin
        if not DataLoaded then begin
            ParentIdFilter := Rec.GetFilter(Id);
            ParentTypeFilter := Rec.GetFilter("Parent Type");
            if (ParentTypeFilter = '') or (ParentIdFilter = '') then begin
                Rec.FilterGroup(4);
                ParentIdFilter := Rec.GetFilter(Id);
                ParentTypeFilter := Rec.GetFilter("Parent Type");
                Rec.FilterGroup(0);
                if (ParentTypeFilter = '') or (ParentIdFilter = '') then
                    Error(ParentNotSpecifiedErr)
            end;
            Evaluate(PictureEntityParentType, ParentTypeFilter);
            Rec.NPRLoadDataWithParentType(ParentIdFilter, PictureEntityParentType);
            Rec.Insert(true);
        end;

        DataLoaded := true;
        exit(true);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.SavePictureWithParentType();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Rec.SavePictureWithParentType();
    end;

    var
        ParentNotSpecifiedErr: Label 'You must get to the parent first to get to the picture.';
        DataLoaded: Boolean;
}

