codeunit 6151174 "NPR RS Report Substitution"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', false, false)]
    local procedure SubstituteSalesStatisticsReports(ReportId: Integer; RequestPageXml: Text; var NewReportId: Integer)
    var
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
    begin
        if not (ReportId in [Report::"NPR Sales Stats Per Variety", Report::"NPR Advanced Sales Stat.", Report::"NPR Sales Stat/Analysis"]) then
            exit;
        if (NewReportId <> ReportId) and (NewReportId <> -1) then
            exit;
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        case ReportId of
            Report::"NPR Sales Stats Per Variety":
                NewReportId := Report::"NPR RS Sales Stats Per Variety";
            Report::"NPR Advanced Sales Stat.":
                NewReportId := Report::"NPR RS Advanced Sales Stat.";
            Report::"NPR Sales Stat/Analysis":
                if (RequestPageXml = '') or IsRequestPageOfReport(RequestPageXml, Report::"NPR RS Retail Sales Statistics") then
                    NewReportId := Report::"NPR RS Retail Sales Statistics";
        end;
    end;

    local procedure IsRequestPageOfReport(RequestPageXml: Text; ReportId: Integer): Boolean
    var
        RequestPageDocument: XmlDocument;
        RootElement: XmlElement;
        IdAttribute: XmlAttribute;
        RequestPageReportId: Integer;
    begin
        if not XmlDocument.ReadFrom(RequestPageXml, RequestPageDocument) then
            exit(false);
        if not RequestPageDocument.GetRoot(RootElement) then
            exit(false);
        if not RootElement.Attributes().Get('id', IdAttribute) then
            exit(false);
        if not Evaluate(RequestPageReportId, IdAttribute.Value()) then
            exit(false);
        exit(RequestPageReportId = ReportId);
    end;
}
