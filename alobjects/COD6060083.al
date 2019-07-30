codeunit 6060083 "POS Action - MCS Select Recom."
{
    // NPR5.30/BR  /20170301  CASE 252646 Object Created
    // NPR5.38/MHA /20180105  CASE 301053 Updated subscriber OnInitializeCaptions() to match new signature of Publisher function


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for selecting and inserting a recommended item into the current transaction';
        ActionVersion: Label '1.0';
        TextNoItemGroupCaption: Label 'The item has no itemgroup, do you wish to edit the item?';
        TextNoItemGroupText: Label 'No item group.';
        TextComment: Label 'Comment';
        Type: Integer;
        NumberOfRecommendations: Integer;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode,
          ActionDescription,
          ActionVersion,
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Single)
        then begin
          Sender.RegisterWorkflowStep('sendsaledata','respond();');
          Sender.RegisterWorkflowStep('recommendeditem', 'respond();');
          Sender.RegisterWorkflowStep('handle', 'respond();');
          Sender.RegisterWorkflow(false);

          Sender.RegisterOptionParameter('Type','Offline,Online','Offline');
          Sender.RegisterIntegerParameter('NumberOfRecommendations',3);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        //-NPR5.38 [301053]
        // UI.AddActionCaption(Captions,ActionCode,'NoItemGroupCaption',TextNoItemGroupCaption);
        // UI.AddActionCaption(Captions,ActionCode,'NoItemGroupText',TextNoItemGroupText);
        // UI.AddActionCaption(Captions,ActionCode,'Comment',TextComment);
        Captions.AddActionCaption(ActionCode,'NoItemGroupCaption',TextNoItemGroupCaption);
        Captions.AddActionCaption(ActionCode,'NoItemGroupText',TextNoItemGroupText);
        Captions.AddActionCaption(ActionCode,'Comment',TextComment);
        //+NPR5.38 [301053]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: JsonObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        MCSRecommendationsSetup: Record "MCS Recommendations Setup";
        JSON: Codeunit "POS JSON Management";
        ControlId: Text;
        Value: Text;
        DoNotClearTextBox: Boolean;
        ItemNo: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope ('parameters', true);

        Type := JSON.GetInteger ('Type', true);
        if (Type = -1) then
          Type := 0;

        NumberOfRecommendations := JSON.GetInteger ('NumberOfRecommendations', true);
        if (NumberOfRecommendations < 1) then
          NumberOfRecommendations := 3;

        case WorkflowStep of
          'sendsaledata' :
            begin
              if Type = 1 then begin
                MCSRecommendationsSetup.Get;
                if not MCSRecommendationsSetup."Background Send POS Lines" then
                  SendSaleData (JSON, POSSession, FrontEnd);
              end;
            end;
          'recommendeditem' : SelectRecommendedItem (JSON, POSSession, FrontEnd);
          'handle' :
            begin
              JSON.SetScope ('/', true);
              ItemNo := JSON.GetString ('recommendeditemno', true);
              RegisterRecommendedItemSales(POSSession,ItemNo);
              POSSession.ChangeViewSale();
              POSSession.RequestRefreshData()
            end;
        end;

        Handled := true;
    end;

    local procedure SelectRecommendedItem(Context: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management") AccountNo: Code[20]
    var
        MCSRecommendationsLine: Record "MCS Recommendations Line";
        TempMCSRecommendationsLine: Record "MCS Recommendations Line" temporary;
        MCSRecommendationsModel: Record "MCS Recommendations Model";
        MCSRecommendationsSetup: Record "MCS Recommendations Setup";
        Item: Record Item;
        TempItem: Record Item temporary;
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        MCSRecommendationsHandler: Codeunit "MCS Recommendations Handler";
        POSSale: Codeunit "POS Sale";
        RetailItemList: Page "Retail Item List";
        ItemFilter: Text;
    begin

        //xx FrontEnd.PauseWorkflow ();

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        MCSRecommendationsHandler.GetRecommendationsLinesFromSalePOS(SalePOS,TempMCSRecommendationsLine);
        MCSRecommendationsHandler.GetItemListFromRecommendations(TempItem,TempMCSRecommendationsLine,NumberOfRecommendations);

        if PAGE.RunModal(PAGE::"Retail Item List",TempItem) = ACTION::LookupOK then begin
          TempMCSRecommendationsLine.SetRange("Item No.",TempItem."No.");
          if TempMCSRecommendationsLine.FindFirst then
            TempMCSRecommendationsLine.LogSelectRecommendedItem;
          Context.SetScope ('/', true);
          Context.SetContext ('recommendeditemno', TempItem."No.");
        end else
          Error('');

        FrontEnd.SetActionContext (ActionCode, Context);
        //xx FrontEnd.ResumeWorkflow ();
    end;

    local procedure SendSaleData(Context: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management") AccountNo: Code[20]
    var
        MCSRecommendationsModel: Record "MCS Recommendations Model";
        MCSRecommendationsSetup: Record "MCS Recommendations Setup";
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        MCSRecommendationsHandler: Codeunit "MCS Recommendations Handler";
        POSSale: Codeunit "POS Sale";
    begin
        //xx FrontEnd.PauseWorkflow ();
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        MCSRecommendationsSetup.Get;
        MCSRecommendationsSetup.TestField("Online Recommendations Model");
        MCSRecommendationsModel.Get(MCSRecommendationsSetup."Online Recommendations Model");
        MCSRecommendationsHandler.InsertPOSSaleRecommendations(MCSRecommendationsModel,SalePOS);
        //xx FrontEnd.ResumeWorkflow ();
    end;

    local procedure RegisterRecommendedItemSales(POSSession: Codeunit "POS Session";RecommendedItemNo: Code[20])
    var
        Line: Record "Sale Line POS";
        POSSaleLine: Codeunit "POS Sale Line";
        Item: Record Item;
    begin
        Item.Get(RecommendedItemNo);
        Line.Type := Line.Type::Item;
        Line."Sale Type" := Line."Sale Type"::Sale;
        Line."No." := RecommendedItemNo;
        Line.Quantity := 1;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.InsertLine(Line);

        POSSaleLine.RefreshCurrent ();
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit('RECOMM');
    end;
}

