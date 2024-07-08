codeunit 6150957 "NPR POS Action: Zoom-B"
{
    Access = Internal;


    procedure ZoomLine(POSSession: Codeunit "NPR POS Session")
    var
        Line: Record "NPR POS Sale Line";
        SaleLine: Codeunit "NPR POS Sale Line";
        CurrentView: Codeunit "NPR POS View";
    begin
        POSSession.GetCurrentView(CurrentView);
        if (CurrentView.GetType() <> CurrentView.GetType() ::Sale) then
            exit;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(Line);
        if (Line."Line No." > 0) then
            Page.RunModal(Page::"NPR TouchScreen: SalesLineZoom", Line);
    end;
}
