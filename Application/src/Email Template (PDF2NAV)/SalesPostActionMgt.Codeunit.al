codeunit 6014462 "NPR Sales-Post Action Mgt"
{
    var
        StdActionDisabledMsg: Label 'This Action is disabled by setup. Please use ''Post and Pdf2Nav''';
        Pdf2NavActionDisabledMsg1: Label 'This Action is disabled by setup. Please use ''Post and Print'' or ''Post and Email ''';
        Pdf2NavActionDisabledMsg2: Label 'This Action is disabled by setup. Please use ''Post and Send'', ''Post and Print'' or ''Post and Email ''';

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnBeforeActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page42OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get() then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg1);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnAfterActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page42OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice", 'OnBeforeActionEvent', 'PostAndSend', true, true)]
    local procedure Page43OnBeforeActionEventPostAndSend(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get() then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice", 'OnBeforeActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page43OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get() then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg2);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice", 'OnAfterActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page43OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Credit Memo", 'OnBeforeActionEvent', 'PostAndSend', true, true)]
    local procedure Page44OnBeforeActionEventPostAndSend(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get() then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice List", 'OnBeforeActionEvent', 'PostAndSend', true, true)]
    local procedure Page9301OnBeforeActionEventPostAndSend(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get() then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Credit Memos", 'OnBeforeActionEvent', 'PostAndSend', true, true)]
    local procedure Page9302OnBeforeActionEventPostAndSend(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get() then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order List", 'OnBeforeActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page9305OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get() then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg1);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order List", 'OnAfterActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page9305OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Sales Order Pick", 'OnBeforeActionEvent', 'PostAndPrint', true, true)]
    local procedure Page6014518OnBeforeActionEventPostAndPrint(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get() then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Sales Order Pick", 'OnBeforeActionEvent', 'PostAndEmail', true, true)]
    local procedure Page6014518OnBeforeActionEventPostAndEmail(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get() then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Sales Order Pick", 'OnBeforeActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page6014518OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get() then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg1);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Sales Order Pick", 'OnAfterActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page6014518OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    local procedure Pdf2NavPostingCodeunitID(): Integer
    begin
        exit(6014463);
    end;
}

