page 6151098 "NPR RS R Localization Setup"
{
    Caption = 'RS Retail Localization Setup';
    PageType = Card;
    Extensible = false;
    SourceTable = "NPR RS R Localization Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            group(Enable)
            {
                Caption = 'Enabling Retail Localization';

                field("Enable RS Localization"; Rec."Enable RS Retail Localization")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the RS Retail Localization is enabled.';

                    trigger OnValidate()
                    begin
                        if xRec."Enable RS Retail Localization" <> Rec."Enable RS Retail Localization" then
                            EnabledValueChanged := true;
                    end;
                }
            }
            group(Accounts)
            {
                Caption = 'G/L Account Setup';
                field("RS Calc. VAT GL Account"; Rec."RS Calc. VAT GL Account")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the acount for posting Calculated VAT.';
                }
                field("RS Calc. Margin GL Account"; Rec."RS Calc. Margin GL Account")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the account for posting Calculated Margin.';
                }
            }
            group(NoSeries)
            {
                Caption = 'No. Series Setup';
                field("RS Nivelation No. Series"; Rec."RS Nivelation Hdr No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Nivelation No. Series field.';
                }
                field("RS Posted Nivelation No. Series"; Rec."RS Posted Niv. No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Posted Nivelation No. Series field.';
                }
                field("RS Ret. Purch. Report Ord."; Rec."RS Ret. Purch. Report Ord.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Retail Purchase Price Report Order field.';
                }
                field("RS Ret. Transfer Report Ord."; Rec."RS Ret. Transfer Report Ord.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Retail Transfer Receipt Report Order field.';
                }

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