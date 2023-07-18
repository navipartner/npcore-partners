codeunit 85038 "NPR Library - RP Template Data"
{
    procedure CreateDummySalesReceipt(var TemplateHeader: Record "NPR RP Template Header")
    var
        LibraryRandom: Codeunit "Library - Random";
        DataItems: Record "NPR RP Data Items";
    begin
        TemplateHeader.Init();
        TemplateHeader.Code := LibraryRandom.RandText(20);
        TemplateHeader."Printer Device" := 'EPSON';
        TemplateHeader.Insert();

        DataItems.Init();
        DataItems.Code := TemplateHeader.Code;
        DataItems.Validate("Data Source", 'NPR POS Entry');
        DataItems.Insert();
    end;

    internal procedure ConfigureReportSelection(ReportType: Enum "NPR Report Selection Type"; TemplateHeader: Record "NPR RP Template Header")
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        ReportSelectionRetail.SetRange("Report Type", ReportType);
        ReportSelectionRetail.DeleteAll();

        ReportSelectionRetail.Init();
        ReportSelectionRetail."Report Type" := ReportType;
        ReportSelectionRetail."Print Template" := TemplateHeader.Code;
        ReportSelectionRetail.Insert();
    end;

    procedure CreateDummyExchangeLabelTemplate(var TemplateHeader: Record "NPR RP Template Header")
    var
        LibraryRandom: Codeunit "Library - Random";
        DataItems: Record "NPR RP Data Items";
    begin
        TemplateHeader.Init();
        TemplateHeader.Code := LibraryRandom.RandText(20);
        TemplateHeader."Printer Type" := TemplateHeader."Printer Type"::Matrix;
        TemplateHeader.Insert();

        DataItems.Init();
        DataItems.Code := TemplateHeader.Code;
        DataItems.Validate("Data Source", 'NPR Exchange Label');
        DataItems.Insert();
    end;
}