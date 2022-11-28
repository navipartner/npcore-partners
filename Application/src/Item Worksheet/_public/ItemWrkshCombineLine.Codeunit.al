codeunit 6059791 "NPR Item Wrksh. Combine Line"
{
    TableNo = "NPR Item Worksheet Line";

    trigger OnRun()
    begin
        CombineLine(Rec);
    end;
    
    procedure CombineLine(var ItemWrkshLine: Record "NPR Item Worksheet Line")
    var
        ItemWorksheetTemplate: Record "NPR Item Worksh. Template";
        ItemWkrshMgt: Codeunit "NPR Item Worksheet Mgt.";
        CombineBy: Option All,ItemNo,VendorItemNo,VendorBarCode,InternalBarCode;
    begin
        ItemWorksheetTemplate.Get(ItemWrkshLine."Worksheet Template Name");
        CombineBy := ItemWorksheetTemplate."Combine Variants to Item by";
        ItemWkrshMgt.CombineLine(ItemWrkshLine, CombineBy);
    end;

    procedure CanCreateTask(ItemWorksheetTemplate: Record "NPR Item Worksh. Template"): Boolean
    begin
        if not ItemWorksheetTemplate."Combine as Background Task" then
            exit;

        exit(TaskScheduler.CanCreateTask());
    end;
}