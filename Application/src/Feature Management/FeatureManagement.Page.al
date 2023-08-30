page 6151094 "NPR Feature Management"
{
    AdditionalSearchTerms = 'new features,features,turn off features,enable features,disable features';
    ApplicationArea = All;
    Caption = 'NaviPartner Feature Management';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "NPR Feature";
    SourceTableView = sorting(Feature);
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Features)
            {
                field(FeatureDescription; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Feature';
                    Editable = false;
                    ToolTip = 'The name of the feature.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the feature is enabled. The change takes effect the next time each user signs in.';

                    trigger OnValidate()
                    begin
                        if xRec.Enabled <> Rec.Enabled then
                            EnabledValueChanged := true;
                    end;
                }
            }
        }
    }

    trigger OnClosePage()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if EnabledValueChanged then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany(); // refresh of experience tier has to be done in order to trigger OnGetEssentialExperienceAppAreas publisher
    end;

    var
        EnabledValueChanged: Boolean;
}