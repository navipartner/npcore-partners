report 6150699 "NPR Re-run Data Upg. Steps"
{
    Caption = 'Re-run Data Upg. Build Steps';
    ProcessingOnly = true;
    requestpage
    {

        layout
        {
            area(content)
            {
                field("From Build Step"; FromBuildStep)
                {
                    BlankZero = true;
                    Caption = 'From Build Step';
                    MinValue = 1;
                    ShowMandatory = true;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Build Step field';

                    trigger OnValidate()
                    begin
                        if ToBuildStep < FromBuildStep then
                            ToBuildStep := FromBuildStep;
                    end;
                }
                field("To Build Step"; ToBuildStep)
                {
                    BlankZero = true;
                    Caption = 'To Build Step';
                    MinValue = 1;
                    ShowMandatory = true;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Build Step field';

                    trigger OnValidate()
                    begin
                        if FromBuildStep > ToBuildStep then
                            FromBuildStep := ToBuildStep;
                    end;
                }
            }
        }

    }

    trigger OnPreReport()
    var
        RetailDataModelUpgradeMgt: Codeunit "NPR Retail Data Model Upg Mgt.";
    begin
        RetailDataModelUpgradeMgt.ReRunUpgradeBuilds(FromBuildStep, ToBuildStep);
    end;

    var
        FromBuildStep: Integer;
        ToBuildStep: Integer;
}

