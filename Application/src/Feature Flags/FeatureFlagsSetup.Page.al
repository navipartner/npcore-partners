page 6151158 "NPR Feature Flags Setup"
{
    PageType = Card;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR Feature Flags Setup";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    Extensible = false;
    Caption = 'Feature Flags Setup';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(Identifier; Rec.Identifier)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Identifier field.';
                    Editable = false;
                }
            }
            part(FeatureFlags; "NPR Feature Flags Setup Sub")
            {
                Caption = 'Feature Flags';
                ApplicationArea = NPRRetail;
                Editable = false;
                UpdatePropagation = Both;
            }
        }
    }

    trigger OnOpenPage()
    var
        NPRFeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        NPRFeatureFlagsManagement.InitFeatureFlagSetup();
    end;
}