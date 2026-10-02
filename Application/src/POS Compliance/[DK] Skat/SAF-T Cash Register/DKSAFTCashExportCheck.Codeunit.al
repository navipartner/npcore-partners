codeunit 6184671 "NPR DK SAF-T Cash Export Check"
{
    Access = Internal;
    TableNo = "NPR DK SAF-T Cash Exp. Header";

    trigger OnRun()
    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
        ErrorMessageManagement: Codeunit "Error Message Management";
    begin
        Rec.TestField("Starting Date");
        Rec.TestField("Ending Date");
        DKFiscalizationSetup.Get();
        If DKFiscalizationSetup."SAF-T Contact No." = '' then
            ErrorMessageManagement.LogErrorMessage(
                0, StrSubstNo(FieldValueIsNotSpecifiedErr, DKFiscalizationSetup.FieldCaption("SAF-T Contact No.")),
                DKFiscalizationSetup, DKFiscalizationSetup.FieldNo("SAF-T Contact No."), '');
    end;

    var
        FieldValueIsNotSpecifiedErr: Label '%1 is not specified';

}