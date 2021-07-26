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
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(parentType; "Parent Type")
                {
                    Caption = 'Parent Type';
                }
                field(parentId; ParentId)
                {
                    Caption = 'Parent Id';
                }
                field(dimensionId; DimensionId)
                {
                    Caption = 'Dimension Id';
                }
                field(dimensionCode; "Dimension Code")
                {
                    Caption = 'Dimension Code';
                    Editable = false;
                }
                field(dimensionValueId; DimensionValueId)
                {
                    Caption = 'Dimension Value Id';
                }
                field(dimensionValueCode; "Dimension Value Code")
                {
                    Caption = 'Dimension Value Code';
                    Editable = false;
                }
                field(postingValidation; "Value Posting")
                {
                    Caption = 'Posting Validation';
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
        if "Parent Type" = "Parent Type"::" " then begin
            ParentTypeFilter := GetFilter("Parent Type");
            if ParentTypeFilter = '' then
                Error(ParentNotSpecifiedErr);
            Evaluate(DefaultDimensionParentType, ParentTypeFilter);
            Validate("Parent Type", DefaultDimensionParentType);
        end;
        if IsNullGuid(ParentId) then begin
            ParentIdFilter := GetFilter(ParentId);
            if ParentIdFilter = '' then
                Error(ParentNotSpecifiedErr);
            Validate(ParentId, ParentIdFilter);
        end else
            Validate(ParentId); //AL: to populate also the Item No in Default Dimension record

        exit(true);
    end;

    var
        ParentNotSpecifiedErr: Label 'You must get to the parent first to get to the default dimensions.';
}