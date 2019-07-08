codeunit 6060086 "MCS Send Sales Line to MCS"
{
    // NPR5.30/BR  /20170303  CASE 252646 Object Created
    // NPR5.30/NPKNAV/20170310  CASE 252646 Transport NPR5.30 - 26 January 2017

    TableNo = "Sales Line";

    trigger OnRun()
    var
        MCSRecommendationsSetup: Record "MCS Recommendations Setup";
        MCSRecommendationsModel: Record "MCS Recommendations Model";
        SalesHeader: Record "Sales Header";
        MCSRecommendationsHandler: Codeunit "MCS Recommendations Handler";
    begin
        if (not MCSRecommendationsSetup.Get ()) then
          exit;
        MCSRecommendationsModel.Get(MCSRecommendationsSetup."Online Recommendations Model");
        SalesHeader.Get(Rec."Document Type",Rec."Document No.");
        MCSRecommendationsHandler.InsertSalesLineRecommendations(MCSRecommendationsModel,SalesHeader,Rec);
    end;

    local procedure BackgroundSendSalesLinetoMCS(SalesLine: Record "Sales Line")
    var
        MCSRecommendationsSetup: Record "MCS Recommendations Setup";
        NewSession: Integer;
    begin
        if not MCSRecommendationsSetup.Get then
          exit;
        if not MCSRecommendationsSetup."Background Send Sales Lines" then
          exit;
        if SalesLine."Document Type" in [SalesLine."Document Type"::"Credit Memo",SalesLine."Document Type"::"Return Order"] then
          exit;
        if SalesLine.Type <> SalesLine.Type::Item then
          exit;
        if SalesLine."No." = '' then
          exit;
        MCSRecommendationsSetup.TestField("Online Recommendations Model");
        StartSession(NewSession,CODEUNIT::"MCS Send Sales Line to MCS",CompanyName,SalesLine);
    end;

    local procedure DeleteRecommendationLines(SalesLine: Record "Sales Line")
    var
        MCSRecommendationsModel: Record "MCS Recommendations Model";
        MCSRecommendationsSetup: Record "MCS Recommendations Setup";
        MCSRecommendationsHandler: Codeunit "MCS Recommendations Handler";
    begin
        if not MCSRecommendationsSetup.Get then
          exit;

        if MCSRecommendationsSetup."Online Recommendations Model" <> '' then
          if MCSRecommendationsModel.Get(MCSRecommendationsSetup."Online Recommendations Model") then
            MCSRecommendationsHandler.DeleteSalesLineRecommendations(MCSRecommendationsModel,SalesLine);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'No.', true, true)]
    local procedure OnAfterValidateSalesLineNoFieldSendToMCS(var Rec: Record "Sales Line";var xRec: Record "Sales Line";CurrFieldNo: Integer)
    var
        SalesLine: Record "Sales Line";
    begin
        if Rec."Line No."  = 0 then
          exit;
        if Rec."No." = xRec."No." then
          exit;
        SalesLine := Rec;
        DeleteRecommendationLines(SalesLine);
        BackgroundSendSalesLinetoMCS(SalesLine);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertSalesLineNoFieldSendToMCS(var Rec: Record "Sales Line";RunTrigger: Boolean)
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine := Rec;
        BackgroundSendSalesLinetoMCS(SalesLine);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeletePOSSaleLineDeleteRecommendations(var Rec: Record "Sales Line";RunTrigger: Boolean)
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine := Rec;
        DeleteRecommendationLines(SalesLine);
    end;
}

