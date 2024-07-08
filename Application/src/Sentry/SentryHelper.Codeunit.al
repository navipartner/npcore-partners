codeunit 6151396 "NPR Sentry Helper"
{
    Access = Internal;

    internal procedure ShouldUseSentryCron(): Boolean
    var
        Company: Record Company;
        NPREnvironmentInformation: Record "NPR Environment Information";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        // for now Sentry Cron should be used only for production SaaS environments for companies which are not Cronus or evaluation and the their last G/L Entry has been modified in the last 30 days
        if not EnvironmentInformation.IsSaaS() then
            exit(false);

        if not EnvironmentInformation.IsProduction() then
            exit(false);

        if CompanyName().ToUpper().Contains('CRONUS') then
            exit(false);

        if Company.Get(CompanyName()) then
            if Company."Evaluation Company" then
                exit(false);

        if NPREnvironmentInformation.Get() then
            if (NPREnvironmentInformation."Environment Type" <> NPREnvironmentInformation."Environment Type"::PROD) or not NPREnvironmentInformation."Environment Verified" then
                exit(false);

        if not IsThereRecentGLEntry(CreateDateTime(CalcDate('<-30D>', Today()), Time())) then
            exit(false);

        exit(true);
    end;

    local procedure IsThereRecentGLEntry(FromDateTime: DateTime): Boolean;
    var
        GLEntry: Record "G/L Entry";
    begin
        if not GLEntry.FindLast() then
            exit(false);

        exit(GLEntry."Last Modified DateTime" > FromDateTime);
    end;
}