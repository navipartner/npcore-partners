codeunit 6184664 "NPR Label Library Public"
{
    [Obsolete('Use public API codeunit 6014413 "NPR Label Library"', '2023-11-28')]
    procedure ChooseLabel(VarRec: Variant)
    var
        LabelLibrary: Codeunit "NPR Label Library";
    begin
        LabelLibrary.ChooseLabel(VarRec);
    end;
}
