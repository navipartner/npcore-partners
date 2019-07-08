codeunit 6150805 "POS Action - Sale Statistics"
{

    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built in function reports on various turnover statistics';
        UNKNOWN_TYPE: Label 'Statisticstype %1 is unknown.';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
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
            RegisterOptionParameter ('StatisticType', 'Report,Sale,Statistics', 'Report');
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        StatisticType: Integer;
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope('parameters',true);
        StatisticType := JSON.GetInteger ('StatisticType',true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        case StatisticType of
          -1 : ShowTurnoverReport (SalePOS);
           0 : ShowTurnoverReport (SalePOS);
           1 : ShowTurnoverSale (SalePOS);
           2 : ShowTurnoverStatistics (SalePOS);
          else
            Error (UNKNOWN_TYPE, StatisticType);
        end;
        Handled := true;
    end;

    local procedure ShowTurnoverSale(SalePOS: Record "Sale POS")
    var
        TempBuffer: Record "NPR - TEMP Buffer" temporary;
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        HeadingText: Text;
    begin

        TouchScreenFunctions.GetSalesStats (SalePOS, HeadingText, TempBuffer);
        PAGE.RunModal (PAGE::"Touch Screen - Info", TempBuffer);
    end;

    local procedure ShowTurnoverReport(SalePOS: Record "Sale POS")
    var
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        TurnoverStats: Page "Turnover Stats";
    begin

        TurnoverStats.SetTSMode (true);
        TurnoverStats.SetRecord (SalePOS);
        TurnoverStats.RunModal ();
    end;

    local procedure ShowTurnoverStatistics(SalePOS: Record "Sale POS")
    var
        TempBuffer: Record "NPR - TEMP Buffer" temporary;
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        HeadingText: Text;
    begin

        TouchScreenFunctions.GetTurnoverStats (SalePOS, HeadingText, TempBuffer);
        PAGE.RunModal (PAGE::"Touch Screen - Info", TempBuffer);
    end;

    local procedure ActionCode(): Text
    begin
        exit ('SALES_STATISTICS');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;
}

