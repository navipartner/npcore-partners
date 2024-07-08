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
                field(Identifier; UpperCase(Rec.Identifier))
                {
                    Caption = 'Identifier';
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
    actions
    {
        area(Processing)
        {
            action(GetFeatureFlags)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Get Feature Flags';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = GetLines;
                ToolTip = 'Executes the Get Feature Flags action.';
                trigger OnAction()
                var
                    FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
                begin
                    FeatureFlagsManagement.GetFeatureFlagsManual();
                end;
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