codeunit 6060052 "NPR Item Wksht.Valid.Test Rnr."
{
    Subtype = TestRunner;
    TestIsolation = Codeunit;

    trigger OnRun()
    begin
        ItemWkshtValidateFields.SetGlobalItemWorksheetline(ItemWorksheetLine);
        ItemWkshtValidateFields.Run;
    end;

    var
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        ItemWkshtValidateFields: Codeunit "NPR Item Wksht.Valid. Process";
        Testrunno: Integer;
        Errormessage: Text;
        StartTime: Time;

    trigger OnBeforeTestRun(CodeunitID: Integer; CodeunitName: Text; FunctionName: Text; FunctionTestPermissions: TestPermissions): Boolean
    var
        Testresult: Record "CAL Test Result";
    begin
        if FunctionName = '' then
            exit(true);
        ClearLastError;
        exit(true)
    end;

    trigger OnAfterTestRun(CodeunitID: Integer; CodeunitName: Text; FunctionName: Text; FunctionTestPermissions: TestPermissions; Success: Boolean)
    var
        TestResult: Record "CAL Test Result";
    begin
        if FunctionName = '' then
            exit;
        if (FunctionName = 'OnRun') and Success then
            exit;
        Errormessage := GetLastErrorText;
    end;

    procedure GetErrormessage(): Text
    begin
        exit(Errormessage)
    end;

    procedure SetItemWorksheetLine(ParItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
        ItemWorksheetLine := ParItemWorksheetLine;
    end;
}

