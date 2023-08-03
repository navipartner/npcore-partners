codeunit 6151396 "NPR Sentry Helper"
{
    Access = Internal;

    internal procedure ShouldUseSentryCron(): Boolean
    var
        Company: Record Company;
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        // for now Sentry Cron should be used only for production SaaS environments for companies which are not Cronus or evaluation and have modified G/L Entries in the last 30 days
        if not EnvironmentInformation.IsSaaS() then
            exit(false);

        if not EnvironmentInformation.IsProduction() then
            exit(false);

        if CompanyName().ToUpper().Contains('CRONUS') then
            exit(false);

        if Company.Get(CompanyName()) then
            if Company."Evaluation Company" then
                exit(false);

        if not IsThereAnyGLEntriesInPeriod(CreateDateTime(CalcDate('<-30D>', Today()), Time()), CurrentDateTime()) then
            exit(false);

        exit(true);
    end;

    local procedure IsThereAnyGLEntriesInPeriod(FromDateTime: DateTime; ToDateTime: DateTime): Boolean;
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Last Modified DateTime", FromDateTime, ToDateTime);
        exit(not GLEntry.IsEmpty());
    end;
}