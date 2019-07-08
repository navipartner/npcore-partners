report 6150699 "Re-run Data Upg. Build Steps"
{
    // NPR5.32/AP/02052017  CASE 274285  Possibility to re-run Data Upgrade Build Steps

    Caption = 'Re-run Data Upg. Build Steps';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field("From Build Step";FromBuildStep)
                {
                    BlankZero = true;
                    Caption = 'From Build Step';
                    MinValue = 1;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if ToBuildStep < FromBuildStep then
                          ToBuildStep := FromBuildStep;
                    end;
                }
                field("To Build Step";ToBuildStep)
                {
                    BlankZero = true;
                    Caption = 'To Build Step';
                    MinValue = 1;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if FromBuildStep > ToBuildStep then
                          FromBuildStep := ToBuildStep;
                    end;
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    var
        RetailDataModelUpgradeMgt: Codeunit "Retail Data Model Upgrade Mgt.";
    begin
        RetailDataModelUpgradeMgt.ReRunUpgradeBuilds(FromBuildStep,ToBuildStep);
    end;

    var
        FromBuildStep: Integer;
        ToBuildStep: Integer;
}

