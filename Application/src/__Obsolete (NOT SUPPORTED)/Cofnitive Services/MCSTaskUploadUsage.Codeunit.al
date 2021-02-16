codeunit 6060089 "NPR MCS Task Upload Usage"
{
    // NPR5.35/BR  /20170822  CASE 286062  Object Created
    ObsoleteState = Pending;
    ObsoleteReason = 'On February 15, 2018, “Recommendations API is no longer under active development”';
    TableNo = "NPR Task Line";

    trigger OnRun()
    var
        MCSRecommendationsModelCode: Code[10];
        MCSRecommendationsModel: Record "NPR MCS Recomm. Model";
        MCSRecBuildModelData: Codeunit "NPR MCS Rec. Build Model Data";
    begin
        MCSRecommendationsModelCode := CopyStr(UpperCase(GetParameterText("Parameter.MCSRecommendationModel")), 1, MaxStrLen(MCSRecommendationsModel.Code));
        if MCSRecommendationsModelCode <> '' then
            MCSRecommendationsModel.SetRange(Code, MCSRecommendationsModelCode);
        MCSRecommendationsModel.SetRange(MCSRecommendationsModel.Enabled, true);
        if MCSRecommendationsModel.FindSet then begin
            repeat
                MCSRecBuildModelData.UploadUsageData(MCSRecommendationsModel);
            until MCSRecommendationsModel.Next = 0;
        end else
            Error(ErrNoActiveBuild, MCSRecommendationsModel.TableCaption);
    end;

    var
        ErrNoActiveBuild: Label 'No active %1 found.';

    local procedure "Parameter.MCSRecommendationModel"(): Code[20]
    begin
        exit('RECOMM_MODEL');
    end;
}

