codeunit 6150671 "NPR Sales Dimension Events"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeRunDimensionValueListModal(var DimensionValue: Record "Dimension Value")
    begin
    end;
}
