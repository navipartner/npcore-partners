codeunit 6059845 "NPR Dimension"
{
    Access = Public;

    procedure CreateSeatingDimForPOSEntry(var POSEntrySalesLine: Record "NPR POS Entry Sales Line"; POSEntry: Record "NPR POS Entry")
    var
        DimensionMgt: Codeunit "NPR Dimension Mgt.";
    begin
        DimensionMgt.CreateSeatingDimForPOSEntry(POSEntrySalesLine, POSEntry);
    end;

}