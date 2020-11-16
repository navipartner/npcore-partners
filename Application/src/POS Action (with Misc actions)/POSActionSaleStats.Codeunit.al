codeunit 6150805 "NPR POS Action - Sale Stats"
{

    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built in function reports on various turnover statistics';
        UNKNOWN_TYPE: Label 'Statisticstype %1 is unknown.';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('', 'respond();');
                RegisterWorkflow(false);
                RegisterOptionParameter('StatisticType', 'Report,Sale,Statistics', 'Report');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        StatisticType: Integer;
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('parameters', true);
        StatisticType := JSON.GetInteger('StatisticType', true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        case StatisticType of
            -1:
                ShowTurnoverReport(SalePOS);
            0:
                ShowTurnoverReport(SalePOS);
            1:
                ShowTurnoverSale(SalePOS);
            2:
                ShowTurnoverStatistics(SalePOS);
            else
                Error(UNKNOWN_TYPE, StatisticType);
        end;
        Handled := true;
    end;

    local procedure ShowTurnoverSale(SalePOS: Record "NPR Sale POS")
    var
        TempBuffer: Record "NPR TEMP Buffer" temporary;
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
        HeadingText: Text;
    begin

        TouchScreenFunctions.GetSalesStats(SalePOS, HeadingText, TempBuffer);
        PAGE.RunModal(PAGE::"NPR Touch Screen - Info", TempBuffer);
    end;

    local procedure ShowTurnoverReport(SalePOS: Record "NPR Sale POS")
    var
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
        TurnoverStats: Page "NPR Turnover Stats";
    begin

        TurnoverStats.SetTSMode(true);
        TurnoverStats.SetRecord(SalePOS);
        TurnoverStats.RunModal();
    end;

    local procedure ShowTurnoverStatistics(SalePOS: Record "NPR Sale POS")
    var
        TempBuffer: Record "NPR TEMP Buffer" temporary;
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
        HeadingText: Text;
    begin

        TouchScreenFunctions.GetTurnoverStats(SalePOS, HeadingText, TempBuffer);
        PAGE.RunModal(PAGE::"NPR Touch Screen - Info", TempBuffer);
    end;

    local procedure ActionCode(): Text
    begin
        exit('SALES_STATISTICS');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;
}

