codeunit 6150990 "NPR Group Code Utils"
{
    Access = Internal;

    #region LookUpGroupCode
    internal procedure LookUpGroupCodeValue(var GroupCodeValue: Text[250])
    var
        NPRGroupCode: Record "NPR Group Code";
    begin
        Clear(NPRGroupCode);
        if Page.RunModal(0, NPRGroupCode) <> Action::LookupOK then
            exit;

        GroupCodeValue := NPRGroupCode.Code;

    end;
    #endregion LookUpGroupCode

}