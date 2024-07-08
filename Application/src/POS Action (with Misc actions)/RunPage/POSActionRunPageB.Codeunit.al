codeunit 6059964 "NPR POS Action: Run Page-B"
{
    Access = Internal;
    procedure RunPage(PageId: Integer; RunModal: Boolean; TableID: Integer; TableView: Text)
    var
        RecRef: RecordRef;
        RecRefVar: Variant;
    begin
        if PageId = 0 then
            exit;

        if (TableID = 0) or (TableView = '') then begin
            if RunModal then
                Page.RunModal(PageId)
            else
                Page.Run(PageId);
        end else begin
            RecRef.Open(TableID);
            RecRef.SetView(TableView);
            if RecRef.FindFirst() then;
            RecRefVar := RecRef;
            if RunModal then
                Page.RunModal(PageId, RecRefVar)
            else
                Page.Run(PageId, RecRefVar);
        end;
    end;
}