codeunit 6151297 "NPR NPRE Static Kitchen Print3"
{
    // Copy of codeunit 6248674 so the same kitchen print can go to another printer.
    // Temporary until print routing supports this. Keep the layout in 6248674. See CORE-2298.
    Access = Internal;
    TableNo = "NPR NPRE W.Pad.Line Out.Buffer";

    trigger OnRun()
    var
        StaticKitchenPrint: Codeunit "NPR NPRE Static Kitchen Print";
    begin
        StaticKitchenPrint.Print(Rec, Codeunit::"NPR NPRE Static Kitchen Print3");
    end;
}
