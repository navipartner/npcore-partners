codeunit 6014462 "NPR Sales-Post Action Mgt"
{
    var
        StdActionDisabledMsg: Label 'This Action is disabled by setup. Please use ''Post and Pdf2Nav''';
        Pdf2NavActionDisabledMsg1: Label 'This Action is disabled by setup. Please use ''Post and Print'' or ''Post and Email ''';
        Pdf2NavActionDisabledMsg2: Label 'This Action is disabled by setup. Please use ''Post and Send'', ''Post and Print'' or ''Post and Email ''';
        Pdf2NavActionDisabledMsg3: Label 'This Action is disabled by setup. Please use ''Post and Print''';

    [EventSubscriber(ObjectType::Page, 42, 'OnBeforeActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page42OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg1);
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnAfterActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page42OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, 43, 'OnBeforeActionEvent', 'PostAndSend', true, true)]
    local procedure Page43OnBeforeActionEventPostAndSend(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 43, 'OnBeforeActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page43OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg2);
    end;

    [EventSubscriber(ObjectType::Page, 43, 'OnAfterActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page43OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, 44, 'OnBeforeActionEvent', 'PostAndSend', true, true)]
    local procedure Page44OnBeforeActionEventPostAndSend(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 44, 'OnBeforeActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page44OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg2);
    end;

    [EventSubscriber(ObjectType::Page, 44, 'OnAfterActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page44OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, 6630, 'OnBeforeActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page6630OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg3);
    end;

    [EventSubscriber(ObjectType::Page, 6630, 'OnAfterActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page6630OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, 9301, 'OnBeforeActionEvent', 'PostAndSend', true, true)]
    local procedure Page9301OnBeforeActionEventPostAndSend(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 9301, 'OnBeforeActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page9301OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg2);
    end;

    [EventSubscriber(ObjectType::Page, 9301, 'OnAfterActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page9301OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, 9302, 'OnBeforeActionEvent', 'PostAndSend', true, true)]
    local procedure Page9302OnBeforeActionEventPostAndSend(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 9302, 'OnBeforeActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page9302OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg2);
    end;

    [EventSubscriber(ObjectType::Page, 9302, 'OnAfterActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page9302OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, 9304, 'OnBeforeActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page9304OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg1);
    end;

    [EventSubscriber(ObjectType::Page, 9304, 'OnAfterActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page9304OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, 9305, 'OnBeforeActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page9305OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg1);
    end;

    [EventSubscriber(ObjectType::Page, 9305, 'OnAfterActionEvent', 'NPR PostAndSendPdf2Nav', true, true)]
    local procedure Page9305OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, 6014518, 'OnBeforeActionEvent', 'PostAndPrint', true, true)]
    local procedure Page6014518OnBeforeActionEventPostAndPrint(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 6014518, 'OnBeforeActionEvent', 'PostAndEmail', true, true)]
    local procedure Page6014518OnBeforeActionEventPostAndEmail(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 6014518, 'OnBeforeActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page6014518OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "NPR SalesPost Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg1);
    end;

    [EventSubscriber(ObjectType::Page, 6014518, 'OnAfterActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page6014518OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    local procedure "---"()
    begin
    end;

    local procedure Pdf2NavPostingCodeunitID(): Integer
    begin
        exit(6014463);
    end;
}

