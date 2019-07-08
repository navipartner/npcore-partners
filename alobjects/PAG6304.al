pageextension 70000457 pageextension70000457 extends "Power BI Report Selection" 
{

    //Unsupported feature: Code Modification on "LoadReportsList(PROCEDURE 6)".

    //procedure LoadReportsList();
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
        /*
        // Clears and retrieves a list of all reports in the user's Power BI account.
        Reset;
        DeleteAll;
        PowerBIServiceMgt.GetReports(Rec,ExceptionMessage,ExceptionDetails,Context);

        HasReports := not IsEmpty;
        if IsEmpty then
        #8..10
        SetCurrentKey(ReportName);
        FindFirst;
        FilterReports;
        */
    //end;
    //>>>> MODIFIED CODE:
    //begin
        /*
        #1..3
        PowerBIServiceMgt.GetReportsForUserContext(Rec,ExceptionMessage,ExceptionDetails,Context);
        #5..13
        */
    //end;
}

