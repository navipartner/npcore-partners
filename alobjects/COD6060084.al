codeunit 6060084 "MCS Send POS Sale Line to MCS"
{
    // NPR5.30/BR  /20170302  CASE 252646 Object Created
    // NPR5.43/MHA /20180619  CASE 319425 Added OnAfterInsertSaleLine POS Sales Workflow
    // NPR5.46/CLVA/20190917  CASE 328581 Removed variable Marshal "CU 6014623 POS Event Marshal" from function MCSSaleLineUpload

    TableNo = "Sale Line POS";

    trigger OnRun()
    var
        MCSRecommendationsSetup: Record "MCS Recommendations Setup";
        MCSRecommendationsModel: Record "MCS Recommendations Model";
        SalePOS: Record "Sale POS";
        MCSRecommendationsHandler: Codeunit "MCS Recommendations Handler";
    begin
        if (not MCSRecommendationsSetup.Get ()) then
          exit;
        MCSRecommendationsModel.Get(MCSRecommendationsSetup."Online Recommendations Model");
        SalePOS.Get(Rec."Register No.",Rec."Sales Ticket No.");
        MCSRecommendationsHandler.InsertPOSSaleLineRecommendations(MCSRecommendationsModel,SalePOS,Rec);
    end;

    var
        Text000: Label 'Microsoft Recommendation Service upload';

    local procedure BackgroundSendPOSSaleLinetoMCS(SaleLinePOS: Record "Sale Line POS")
    var
        MCSRecommendationsSetup: Record "MCS Recommendations Setup";
        NewSession: Integer;
    begin
        if (not MCSRecommendationsSetup.Get ()) then
          exit;
        if not MCSRecommendationsSetup."Background Send POS Lines" then
          exit;
        MCSRecommendationsSetup.TestField("Online Recommendations Model");
        StartSession(NewSession,CODEUNIT::"MCS Send POS Sale Line to MCS",CompanyName,SaleLinePOS);
    end;

    local procedure DeleteRecommendationLines(SaleLinePOS: Record "Sale Line POS")
    var
        MCSRecommendationsModel: Record "MCS Recommendations Model";
        MCSRecommendationsSetup: Record "MCS Recommendations Setup";
        MCSRecommendationsHandler: Codeunit "MCS Recommendations Handler";
    begin
        if (not MCSRecommendationsSetup.Get ()) then
          exit;
        if MCSRecommendationsSetup."Online Recommendations Model" <> '' then
          if MCSRecommendationsModel.Get(MCSRecommendationsSetup."Online Recommendations Model") then
            MCSRecommendationsHandler.DeletePOSSaleLineRecommendations(MCSRecommendationsModel,SaleLinePOS);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnBeforeDeletePOSSaleLine', '', true, true)]
    local procedure OnBeforeDeletePOSSaleLineDeleteRecommendations(var Sender: Codeunit "POS Sale Line";SaleLinePOS: Record "Sale Line POS")
    var
        SaleLinePOS2: Record "Sale Line POS";
    begin
        SaleLinePOS2 := SaleLinePOS;
        DeleteRecommendationLines(SaleLinePOS2);
    end;

    local procedure "--- OnAfterInsertSaleLine Workflow"()
    begin
        //-NPR5.43 [319425]
        //+NPR5.43 [319425]
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "POS Sales Workflow Step";RunTrigger: Boolean)
    begin
        //-NPR5.43 [319425]
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
          exit;

        case Rec."Subscriber Function" of
          'MCSSaleLineUpload':
            begin
              Rec.Description := Text000;
              Rec."Sequence No." := 50;
            end;
        end;
        //+NPR5.43 [319425]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-NPR5.43 [319425]
        exit(CODEUNIT::"MCS Send POS Sale Line to MCS");
        //+NPR5.43 [319425]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnAfterInsertSaleLine', '', true, true)]
    local procedure MCSSaleLineUpload(POSSalesWorkflowStep: Record "POS Sales Workflow Step";SaleLinePOS: Record "Sale Line POS")
    var
        AuditRoll: Record "Audit Roll";
        NPRetailSetup: Record "NP Retail Setup";
        Register: Record Register;
        SaleLinePOS2: Record "Sale Line POS";
    begin
        //-NPR5.43 [319425]
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
          exit;

        if POSSalesWorkflowStep."Subscriber Function" <> 'MCSSaleLineUpload' then
          exit;

        SaleLinePOS2 := SaleLinePOS;
        DeleteRecommendationLines(SaleLinePOS2);
        //+NPR5.43 [319425]
    end;
}

