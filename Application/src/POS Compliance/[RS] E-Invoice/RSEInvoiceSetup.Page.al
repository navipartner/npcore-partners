page 6184546 "NPR RS E-Invoice Setup"
{
    Caption = 'RS E-Invoice Setup';
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    PageType = Card;
    SourceTable = "NPR RS E-Invoice Setup";
    Extensible = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    AdditionalSearchTerms = 'Serbia E-Invoice Setup,RS E Invoice Setup';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';

                field("Enable RS E-Invoice"; Rec."Enable RS E-Invoice")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enable RS E-Invoice field.';
                    trigger OnValidate()
                    begin
                        if xRec."Enable RS E-Invoice" <> Rec."Enable RS E-Invoice" then
                            EnabledValueChanged := true;
                    end;
                }
            }
            group("API Parameters")
            {
                Caption = 'API Parameters';

                field("API URL"; Rec."API URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the API URL field.';
                }
                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the API Key field.';
                }

            }
            group("Defaults Setup")
            {
                Caption = 'Defaults Setup';

                field("Default Unit Of Measure"; Rec."Default Unit Of Measure")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Default Unit Of Measure field.';
                }
            }
            group("Additional Setup")
            {
                Caption = 'Additional Setup';

                field("Allow Zero Amt. Purchase Doc."; Rec."Allow Zero Amt. Purchase Doc.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Allow Zero Amount Purchase Document field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UOMMappingPage)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Allowed Units of Measure';
                Image = GetBinContent;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR RS EI Allowed UOM";
                ToolTip = 'Opens the Allowed Units of Measure.';
            }
            action(TaxExemptionPage)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Tax Exemption Reasons';
                Image = GetBinContent;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR RS EI Tax Ex. Reasons";
                ToolTip = 'Opens the Tax Exemption Reasons.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    trigger OnClosePage()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if EnabledValueChanged then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    var
        EnabledValueChanged: Boolean;
}