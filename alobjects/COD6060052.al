codeunit 6060052 "Item Wksht. Validate Test Rnr."
{
    // NPR5.25\BR \20160707 CASE 246088 New Codeunit
    // NPR5.29/BR /20161124 CASE 259274 Added FunctionTestPermissions to Function OnBeforeTestRun and OnAfterTestRun for NAV 2017

    Subtype = TestRunner;
    TestIsolation = Codeunit;

    trigger OnRun()
    begin
        ItemWkshtValidateFields.SetGlobalItemWorksheetline(ItemWorksheetLine);
        ItemWkshtValidateFields.Run;
    end;

    var
        ItemWkshtValidateFields: Codeunit "Item Wksht. Validate Process";
        ItemWorksheetLine: Record "Item Worksheet Line";
        Errormessage: Text;
        StartTime: Time;
        Testrunno: Integer;

    procedure SetItemWorksheetLine(ParItemWorksheetLine: Record "Item Worksheet Line")
    begin
        ItemWorksheetLine := ParItemWorksheetLine;
    end;

    procedure GetErrormessage(): Text
    begin
        exit(Errormessage)
    end;

    trigger OnBeforeTestRun(CodeunitID: Integer;CodeunitName: Text;FunctionName: Text;FunctionTestPermissions: TestPermissions): Boolean
    var
        Testresult: Record "CAL Test Result";
    begin
        if FunctionName  = '' then
          exit(true);
        ClearLastError;
        //Testresult.Initialize(Testrunno,CodeunitID,FunctionName,CURRENTDATETIME);

        exit(true)
    end;

    trigger OnAfterTestRun(CodeunitID: Integer;CodeunitName: Text;FunctionName: Text;FunctionTestPermissions: TestPermissions;Success: Boolean)
    var
        TestResult: Record "CAL Test Result";
    begin
        if FunctionName  = '' then
          exit;
        if (FunctionName  = 'OnRun') and Success then begin
          exit;
        end;
        Errormessage := GetLastErrorText;
    end;
}

