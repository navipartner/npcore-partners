codeunit 6060010 "NPR SAF-T Cash Export Check"
{
    Access = Internal;
    TableNo = "NPR SAF-T Cash Export Header";

    trigger OnRun()
    var
        NOFiscalizationSetup: Record "NPR NO Fiscalization Setup";
        SAFTExportMgt: Codeunit "NPR SAF-T Cash Export Mgt.";
        ErrorMessageManagement: Codeunit "Error Message Management";
    begin
        Rec.TestField("Starting Date");
        Rec.TestField("Ending Date");
        SAFTExportMgt.CheckNoFilesInFolder(Rec);
        NOFiscalizationSetup.Get();
        If NOFiscalizationSetup."SAF-T Contact No." = '' then
            ErrorMessageManagement.LogErrorMessage(
                0, StrSubstNo(FieldValueIsNotSpecifiedErr, NOFiscalizationSetup.FieldCaption("SAF-T Contact No.")),
                NOFiscalizationSetup, NOFiscalizationSetup.FieldNo("SAF-T Contact No."), '');
    end;

    var
        FieldValueIsNotSpecifiedErr: Label '%1 is not specified';

}