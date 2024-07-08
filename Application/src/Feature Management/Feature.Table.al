table 6060019 "NPR Feature"
{
    Access = Internal;
    Caption = 'NaviPartner Feature';
    DataClassification = SystemMetadata;
    DrillDownPageId = "NPR Feature Management";
    LookupPageId = "NPR Feature Management";

    fields
    {
        field(1; Id; Text[50])
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(10; Feature; Enum "NPR Feature")
        {
            Caption = 'Feature';
            DataClassification = SystemMetadata;
            Editable = false;

            trigger OnValidate()
            begin
                if Feature <> Feature::" " then
                    EnsureUniqueFeatureValue();
            end;
        }
        field(20; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = SystemMetadata;
        }
        field(30; Description; Text[2048])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(Key1; Feature)
        {
        }
    }

    local procedure EnsureUniqueFeatureValue()
    var
        OtherFeature: Record "NPR Feature";
        AlreadyAssignedErr: Label 'The %1 %2 value is already assigned to %2 %3.', Comment = '%1 - Feature value, %2 - Feature table caption, %3 - Other Feature Id value';
    begin
        OtherFeature.SetCurrentKey(Feature);
        OtherFeature.SetRange(Feature, Feature);
        OtherFeature.SetFilter(Id, '<>%1', Id);
        if OtherFeature.FindFirst() then
            Error(AlreadyAssignedErr, Feature, TableCaption(), OtherFeature.Id);
    end;
}