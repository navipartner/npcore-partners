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
                    var
                        ClickCollectNPEmailSetupMsg: Label 'In order to use this feature for Click & Collect orders, you will need to set "* NP Email Template *" fields on Collect Workflows and Collect Stores pages. Two fields related to Stores: Store NP Email Template (Pending) and Store NP Email Template (Expired) and five "NP E-mail Template *" fields related to Customers. Also, you will have to enable this feature in all other stores which are being used for Click & Collect.';
                    begin
                        if xRec.Enabled <> Rec.Enabled then
                            EnabledValueChanged := true;
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
                        if Rec.Enabled and not xRec.Enabled and (Rec.Feature = Rec.Feature::"NP Email for Click & Collect") then
                            Message(ClickCollectNPEmailSetupMsg);
#endif
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
