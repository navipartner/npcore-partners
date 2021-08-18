page 6014503 "NPR APIV1 - Default Dimensions"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityCaption = 'Default Dimension';
    EntitySetCaption = 'Default Dimensions';
    EntityName = 'defaultDimension';
    EntitySetName = 'defaultDimensions';
    Extensible = false;
    PageType = API;
    SourceTable = "Default Dimension";
    ODataKeyFields = SystemId;

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
                field(tableID; Rec."Table ID")
                {
                    Caption = 'Table Id', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }
                field(dimensionCode; Rec."Dimension Code")
                {
                    Caption = 'Dimension Code', Locked = true;
                    Editable = false;
                }
                field(parentType; Rec."Parent Type")
                {
                    Caption = 'Parent Type', Locked = true;
                }
                field(parentId; Rec.ParentId)
                {
                    Caption = 'Parent Id', Locked = true;
                }
                field(dimensionId; Rec.DimensionId)
                {
                    Caption = 'Dimension Id', Locked = true;
                }
                field(dimensionValueId; Rec.DimensionValueId)
                {
                    Caption = 'Dimension Value Id', Locked = true;
                }
                field(dimensionValueCode; Rec."Dimension Value Code")
                {
                    Caption = 'Dimension Value Code', Locked = true;
                    Editable = false;
                }
                field(postingValidation; Rec."Value Posting")
                {
                    Caption = 'Posting Validation', Locked = true;
                }

                field("tableCaption"; Rec."Table Caption")
                {
                    Caption = 'Table Caption', Locked = true;
                }

                field(multiSelectionAction; Rec."Multi Selection Action")
                {
                    Caption = 'Multi Selection Action', Locked = true;
                }

                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }

                field(replicationCounter; Rec."NPR Replication Counter")
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

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        DefaultDimensionParentType: Enum "Default Dimension Parent Type";
        ParentIdFilter: Text;
        ParentTypeFilter: Text;
    begin
        if Rec."Parent Type" = Rec."Parent Type"::" " then begin
            ParentTypeFilter := Rec.GetFilter("Parent Type");
            if ParentTypeFilter = '' then
                Error(ParentNotSpecifiedErr);
            Evaluate(DefaultDimensionParentType, ParentTypeFilter);
            Rec.Validate("Parent Type", DefaultDimensionParentType);
        end;
        if IsNullGuid(Rec.ParentId) then begin
            ParentIdFilter := Rec.GetFilter(ParentId);
            if ParentIdFilter = '' then
                Error(ParentNotSpecifiedErr);
            Rec.Validate(ParentId, ParentIdFilter);
        end else
            Rec.Validate(ParentId); // to populate also the Item No in Default Dimension record

        exit(true);
    end;

    var
        ParentNotSpecifiedErr: Label 'You must get to the parent first to get to the default dimensions.';
}