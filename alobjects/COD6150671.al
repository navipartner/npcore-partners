codeunit 6150671 "POS Action - Edit Web Depen."
{
    // NPR5.47/MHA /20181026  CASE 326640 Object created - edit Web Client Dependency

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Edit Web Client Dependency';
        CurrWebClientDependency: Record "Web Client Dependency";
        [WithEvents]
        Model: DotNet Model;
        ActiveModelID: Guid;
        Text001: Label 'Save';
        Text002: Label 'Cancel';

    local procedure ActionCode(): Text
    begin
        exit ('EDIT_WEB_DEP');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('0.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do begin
          if DiscoverAction(
            ActionCode(),
            Text000,
            ActionVersion(),
            Type::Generic,
            "Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep('edit_web_dependency','respond();');
            RegisterWorkflow(false);

            RegisterOptionParameter('dependency_type','JavaScript,CSS,HTML,SVG,DataUri','CSS');
            RegisterTextParameter('dependency_code','');
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupDependencyCode(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        POSActionParameter: Record "POS Action Parameter";
        POSParameterValue2: Record "POS Parameter Value";
        WebClientDependency: Record "Web Client Dependency";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
          exit;
        if POSParameterValue.Name <> 'dependency_code' then
          exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
          exit;

        Handled := true;

        POSParameterValue2.SetRange("Table No.",POSParameterValue."Table No.");
        POSParameterValue2.SetRange(Code,POSParameterValue.Code);
        POSParameterValue2.SetRange(ID,POSParameterValue.ID);
        POSParameterValue2.SetRange("Record ID",POSParameterValue."Record ID");
        POSParameterValue2.SetRange(Name,'dependency_type');
        POSParameterValue2.SetRange("Action Code",POSParameterValue."Action Code");
        POSParameterValue2.SetRange("Data Type",POSParameterValue2."Data Type"::Option);
        POSParameterValue2.FindFirst;

        POSActionParameter.Get(POSParameterValue2."Action Code",POSParameterValue2.Name);
        WebClientDependency.SetRange(Type,POSActionParameter.GetOptionInt(POSParameterValue2.Value));
        if PAGE.RunModal(PAGE::"Web Client Dependencies",WebClientDependency) = ACTION::LookupOK then
          POSParameterValue.Value := WebClientDependency.Code;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        case WorkflowStep of
          'edit_web_dependency':
            OnActionEditWebDependency(JSON,FrontEnd);
        end;

        Handled := true;
    end;

    local procedure OnActionEditWebDependency(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        Type: Integer;
        "Code": Code[10];
    begin
        Type := JSON.GetIntegerParameter('dependency_type',true);
        Code := JSON.GetStringParameter('dependency_code',true);
        Init(Type,Code);

        CreateUserInterface();
        ActiveModelID := FrontEnd.ShowModel(Model);
    end;

    local procedure Init(Type: Integer;"Code": Code[10])
    begin
        if not CurrWebClientDependency.Get(Type,Code) then begin
          CurrWebClientDependency.Init;
          CurrWebClientDependency.Type := Type;
          CurrWebClientDependency.Code := Code;
          CurrWebClientDependency.Insert(true);
        end;
    end;

    local procedure "--- UI"()
    begin
    end;

    local procedure CreateUserInterface()
    begin
        Model := Model.Model();
        Model.AddHtml(InitHtml());
        Model.AddStyle(InitCss());
        Model.AddScript(InitScript());
    end;

    local procedure InitCss() Css: Text
    begin
        Css :=
          'html {' +
          '    touch-action: none;' +
          '}' +
          '' +
          'body' +
          '{' +
          '    margin: 0;' +
          '    padding: 0;' +
          '    height: 100vh !important;' +
          '    width: 100vw !important;' +
          '    -webkit-user-select: none;' +
          '    -khtml-user-select: none;' +
          '    -moz-user-select: none;' +
          '    -o-user-select: none;' +
          '    -ms-user-select: none;' +
          '    user-select: none;' +
          '    -webkit-touch-callout: none;' +
          '    -webkit-tap-highlight-color: rgba(0,0,0,0);' +
          '    cursor: default;' +
          '}' +
          '' +
          'body, input, textarea, keygen, select, button {' +
          '    font-family: Gill Sans, Segoe UI, Apple SD Gothic Neo, Verdana, Geneva, sans-serif;' +
          '    font-size: 16px;' +
          '}' +
          '' +
          '' +
          '.np-html, .np-head, th, thead, table, tbody, tr, div.subtotal {' +
          '    font-family: Gill Sans, Segoe UI, Apple SD Gothic Neo, Verdana, Geneva, sans-serif;' +
          '}' +
          '' +
          'th, thead, table, tbody, tr, div.subtotal {' +
          '    font-family: Gill Sans, Segoe UI, Apple SD Gothic Neo, Verdana, Geneva, sans-serif !important;' +
          '}' +
          '' +
          '* {' +
          '    box-sizing: border-box;' +
          '}' +
          '' +
          '' +
          '.np-container {' +
          '    display: block;' +
          '}' +
          '' +
          '.np-fontsize-x-small {' +
          '    font-size: 0.6em;' +
          '}' +
          '.np-fontsize-small {' +
          '    font-size: 0.8em;' +
          '}' +
          '.np-fontsize-normal {' +
          '    font-size: 1em;' +
          '}' +
          '.np-fontsize-medium {' +
          '    font-size: 1.2em;' +
          '}' +
          '.np-fontsize-semilarge {' +
          '    font-size: 1.4em;' +
          '}' +
          '.np-fontsize-large {' +
          '    font-size: 1.6em;' +
          '}' +
          '.np-fontsize-x-large {' +
          '    font-size: 2em;' +
          '}' +
          '.np-fontstyle-regular {' +
          '    font-weight: normal;' +
          '}' +
          '.np-fontstyle-semibold {' +
          '    font-weight: 600;' +
          '    font-family: Gill Sans, Segoe UI Semibold, Verdana;' +
          '}' +
          '.np-fontstyle-bold {' +
          '    font-weight: bold;' +
          '}' +
          '.np-fontstyle-uppercase {' +
          '    text-transform: uppercase;' +
          '}' +
          '' +
          '' +
          '.np-text-align-none {' +
          '    text-align: initial;' +
          '}' +
          '' +
          '.np-text-align-left {' +
          '    text-align: left;' +
          '}' +
          '' +
          '.np-text-align-right {' +
          '    text-align: right;' +
          '}' +
          '' +
          '.np-text-align-center {' +
          '    text-align: center;' +
          '}' +
          '' +
          '.np-text-align-justify {' +
          '    text-align: justify;' +
          '}' +
          '' +
          '.np-underline:hover {' +
          '    text-decoration: underline;' +
          '}' +
          '' +
          '.np-button {' +
          '    color: #fff;' +
          '    background-color: #6388ae;' +
          '    -ms-background-clip: padding-box !important;' +
          '    -moz-background-clip: padding-box !important;' +
          '    -webkit-background-clip: padding-box !important;' +
          '    background-clip: padding-box !important;' +
          '    cursor: pointer;' +
          '    margin-right: 0.3em;' +
          '    -webkit-transition: background-color 300ms ease-out;' +
          '    -moz-transition: background-color 300ms ease-out;' +
          '    -ms-transition: background-color 300ms ease-out;' +
          '    -o-transition: background-color 300ms ease-out;' +
          '    transition: background-color 300ms ease-out;' +
          '    -ms-touch-action: none;' +
          '    text-decoration: none;' +
          '    position: relative;' +
          '}' +
          '' +
          '.np-button {' +
          '    text-align: center;' +
          '    -webkit-box-align: center;' +
          '    -webkit-align-items: center;' +
          '    -ms-flex-align: center;' +
          '    align-items: center;' +
          '    display: -webkit-box;' +
          '    display: -webkit-flex;' +
          '    display: -ms-flexbox;' +
          '    display: flex;' +
          '    -webkit-box-flex: 1;' +
          '    -webkit-flex: 1 1 100%;' +
          '    -ms-flex: 1 1 100%;' +
          '    flex: 1 1 100%;' +
          '    -webkit-box-pack: center;' +
          '    -webkit-justify-content: center;' +
          '    -ms-flex-pack: center;' +
          '    justify-content: center;' +
          '    -webkit-box-orient: vertical;' +
          '    -webkit-box-direction: normal;' +
          '    -ms-flex-flow: column wrap;' +
          '    flex-flow: column wrap;' +
          '    min-width: 0;' +
          '}' +
          '' +
          '.np-button span {' +
          '    display: -webkit-box;' +
          '    display: -webkit-flex;' +
          '    display: -ms-flexbox;' +
          '    display: flex;' +
          '    -webkit-flex-flow: column wrap;' +
          '    -ms-flex-flow: column wrap;' +
          '    flex-flow: column wrap;' +
          '    width: 100%;' +
          '}' +
          '' +
          '.np-button .np-icon {' +
          '    height: 50%;' +
          '    -webkit-box-pack: center;' +
          '    -ms-flex-pack: center;' +
          '    justify-content: center;' +
          '    -webkit-box-flex: 1;' +
          '    -ms-flex: 1 1 50%;' +
          '    flex: 1 1 50%;' +
          '}' +
          '' +
          '.np-button .np-caption {' +
          '    height: 100%;' +
          '    display: -webkit-box;' +
          '    display: -webkit-flex;' +
          '    display: -ms-flexbox;' +
          '    display: flex;' +
          '    -webkit-box-pack: center;' +
          '    -ms-flex-pack: center;' +
          '    justify-content: center;' +
          '    -webkit-box-flex: 1;' +
          '    -ms-flex: 1 1 100%;' +
          '    flex: 1 1 100%;' +
          '' +
          '    padding-left: 0.5em;' +
          '    padding-right: 0.5em;' +
          '    width: 100%;' +
          '}' +
          '' +
          '.np-button .np-caption small {' +
          '    display: block;' +
          '    text-overflow: ellipsis;' +
          '    width: 100%;' +
          '    overflow: hidden;' +
          '}' +
          '' +
          '.np-button.has-icon .np-caption {' +
          '    height: 50%;' +
          '    -webkit-box-flex: 1;' +
          '    -ms-flex: 1 1 50%;' +
          '    flex: 1 1 50%;' +
          '}' +
          '' +
          '.np-button .np-caption .inner-content {' +
          '    overflow: hidden;' +
          '    white-space: nowrap;' +
          '    text-overflow: ellipsis;' +
          '    display: block;' +
          '    width: 100%;' +
          '}' +
          '' +
          '.np-button.multiline .np-caption .inner-content {' +
          '    white-space: normal;' +
          '}' +
          '' +
          '.np-button.singleline .np-caption .inner-content {' +
          '    white-space: nowrap;' +
          '    text-overflow: ellipsis;' +
          '}' +
          '' +
          '.np-button.image-below, ' +
          '.np-button.image-above {' +
          '    background-size: cover;' +
          '    background-position: center 0;' +
          '    background-repeat: no-repeat;' +
          '    position: relative;' +
          '}' +
          '' +
          '.np-button.image-below .np-caption,' +
          '.np-button.image-above .np-caption {' +
          '    text-overflow: ellipsis;' +
          '    white-space: nowrap;' +
          '    overflow: hidden;' +
          '    display: block;' +
          '    padding: 3px 3px 5px;' +
          '    position: absolute;' +
          '    top: 0;' +
          '    height: auto;' +
          '}' +
          '' +
          '.np-button.image-above .np-caption {' +
          '    bottom: 0;' +
          '    top: auto;' +
          '}' +
          '' +
          '/* on last element remove border-right */' +
          '.np-button:last-child {' +
          '    margin-right: 0;' +
          '}' +
          '.np-button:hover {' +
          '    background-color: #29578d;' +
          '}' +
          '' +
          '.np-button:active, .np-button.active {' +
          '    -webkit-transform: scale(0.95, 0.95);' +
          '    transform: scale(0.95, 0.95);' +
          '    -webkit-transition: none;' +
          '    -moz-transition: none;' +
          '    -ms-transition: none;' +
          '    -o-transition: none;' +
          '    transition: none;' +
          '}' +
          '' +
          '.np-style-disabled {' +
          '    background-color: #c1cddd !important;' +
          '    cursor: default !important;' +
          '}' +
          '' +
          '.np-style-disabled:active {' +
          '    -webkit-transform: scale(1, 1);' +
          '    transform: scale(1, 1);' +
          '}' +
          '' +
          '.np-style-disabled:hover, .np-style-disabled:focus {' +
          '    background-color: #c1cddd !important;' +
          '}' +
          '' +
          '.np-button-color-default,' +
          '.np-button.image-below.np-button-color-default .np-caption,' +
          '.np-button.image-above.np-button-color-default .np-caption {' +
          '    background-color: #6388ae;' +
          '}' +
          '' +
          '.np-button-color-default:hover,' +
          '.np-button.image-below.np-button-color-default:hover .np-caption,' +
          '.np-button.image-above.np-button-color-default:hover .np-caption {' +
          '    background-color: #29578d;' +
          '}' +
          '' +
          '.np-button-color-green,' +
          '.np-button.image-below.np-button-color-green .np-caption,' +
          '.np-button.image-above.np-button-color-green .np-caption {' +
          '    background-color: #5eb267;' +
          '}' +
          '' +
          '.np-button-color-green:hover,' +
          '.np-button.image-below.np-button-color-green:hover .np-caption,' +
          '.np-button.image-above.np-button-color-green:hover .np-caption {' +
          '    background-color: #34803c;' +
          '}' +
          '' +
          '.np-button-color-red,' +
          '.np-button.image-below.np-button-color-red .np-caption,' +
          '.np-button.image-above.np-button-color-red .np-caption {' +
          '    background-color: #db3439;' +
          '}' +
          '' +
          '.np-button-color-red:hover,' +
          '.np-button.image-below.np-button-color-red:hover .np-caption,' +
          '.np-button.image-above.np-button-color-red:hover .np-caption {' +
          '    background-color: #b30d13;' +
          '}' +
          '' +
          '.np-button-color-dark-red,' +
          '.np-button.image-below.np-button-color-dark-red .np-caption,' +
          '.np-button.image-above.np-button-color-dark-red .np-caption {' +
          '    background-color: #982420;' +
          '}' +
          '' +
          '.np-button-color-dark-red:hover,' +
          '.np-button.image-below.np-button-color-dark-red:hover .np-caption,' +
          '.np-button.image-above.np-button-color-dark-red:hover .np-caption {' +
          '    background-color: #6c1714;' +
          '}' +
          '' +
          '.np-button-color-gray,' +
          '.np-button.image-below.np-button-color-gray .np-caption,' +
          '.np-button.image-above.np-button-color-gray .np-caption {' +
          '    background-color: #a4b4c8;' +
          '}' +
          '' +
          '.np-button-color-gray:hover,' +
          '.np-button.image-below.np-button-color-gray:hover .np-caption,' +
          '.np-button.image-above.np-button-color-gray:hover .np-caption {' +
          '    background-color: #76889c;' +
          '}' +
          '' +
          '.np-button-color-purple,' +
          '.np-button.image-below.np-button-color-purple .np-caption,' +
          '.np-button.image-above.np-button-color-purple .np-caption {' +
          '    background-color: #80588c;' +
          '}' +
          '' +
          '.np-button-color-purple:hover,' +
          '.np-button.image-below.np-button-color-purple:hover .np-caption,' +
          '.np-button.image-above.np-button-color-purple:hover .np-caption {' +
          '    background-color: #5e3b69;' +
          '}' +
          '' +
          '.np-button-color-indigo,' +
          '.np-button.image-below.np-button-color-indigo .np-caption,' +
          '.np-button.image-above.np-button-color-indigo .np-caption {' +
          '    background-color: #655093;' +
          '}' +
          '' +
          '.np-button-color-indigo:hover,' +
          '.np-button.image-below.np-button-color-indigo:hover .np-caption,' +
          '.np-button.image-above.np-button-color-indigo:hover .np-caption {' +
          '    background-color: #45346a;' +
          '}' +
          '' +
          '.np-button-color-yellow,' +
          '.np-button.image-below.np-button-color-yellow .np-caption,' +
          '.np-button.image-above.np-button-color-yellow .np-caption {' +
          '    background-color: #e5d736;' +
          '}' +
          '' +
          '.np-button-color-yellow:hover,' +
          '.np-button.image-below.np-button-color-yellow:hover .np-caption,' +
          '.np-button.image-above.np-button-color-yellow:hover .np-caption {' +
          '    background-color: #aea115;' +
          '}' +
          '' +
          '.np-button-color-orange,' +
          '.np-button.image-below.np-button-color-orange .np-caption,' +
          '.np-button.image-above.np-button-color-orange .np-caption {' +
          '    background-color: #f0aa35;' +
          '}' +
          '' +
          '.np-button-color-orange:hover,' +
          '.np-button.image-below.np-button-color-orange:hover .np-caption,' +
          '.np-button.image-above.np-button-color-orange:hover .np-caption {' +
          '    background-color: #a76b07;' +
          '}' +
          '' +
          '.np-button-color-white,' +
          '.np-button.image-below.np-button-color-white .np-caption,' +
          '.np-button.image-above.np-button-color-white .np-caption {' +
          '    background-color: #D8D8D8;' +
          '}' +
          '' +
          '.np-button-color-white:hover,' +
          '.np-button.image-below.np-button-color-white:hover .np-caption,' +
          '.np-button.image-above.np-button-color-white:hover .np-caption {' +
          '    background-color: #9c9c9c;' +
          '}' +
          '' +
          '.np-button.image-below > .np-caption, .np-button.image-above > .np-caption {' +
          '    left: 0;' +
          '}' +
          '' +
          '.np-button.has-text-overlay > .np-caption {' +
          '    background-color: rgba(0, 0, 0, 0.2);' +
          '}' +
          '' +
          '' +
          '' +
          '@media only screen and (min-width:600px) {' +
          '    body, input, textarea, keygen, select, button, table, div {' +
          '        font-size: 8px;' +
          '    }' +
          '}' +
          '' +
          '@media only screen and (min-width:700px) {' +
          '    body, input, textarea, keygen, select, button, table, div {' +
          '        font-size: 9px;' +
          '    }' +
          '}' +
          '' +
          '@media only screen and (min-width:800px) {' +
          '    body, input, textarea, keygen, select, button, table, div {' +
          '        font-size: 10px;' +
          '    }' +
          '}' +
          '' +
          '@media only screen and (min-width:1000px) {' +
          '    body, input, textarea, keygen, select, button, table, div {' +
          '        font-size: 11px;' +
          '    }' +
          '}' +
          '' +
          '@media only screen and (min-width:1200px) {' +
          '    body, input, textarea, keygen, select, button, table, div {' +
          '        font-size: 13px;' +
          '    }' +
          '}' +
          '' +
          '@media only screen and (min-width:1400px) {' +
          '    body, input, textarea, keygen, select, button, table, div {' +
          '        font-size: 14px;' +
          '    }' +
          '}' +
          '' +
          '' +
          '@media only screen and (min-width:1600px) {' +
          '    body, input, textarea, keygen, select, button, table, div {' +
          '        font-size: 15px;' +
          '    }' +
          '}' +
          '' +
          '@media only screen and (min-width:1900px) {' +
          '    body, input, textarea, keygen, select, button, table, div {' +
          '        font-size: 16px;' +
          '    }' +
          '}' +
          '' +
          '@media only screen and (min-width:2200px) {' +
          '    body, input, textarea, keygen, select, button, table, div {' +
          '        font-size: 19px;' +
          '    }' +
          '}' +
          '' +
          '@media only screen and (min-width:2600px) {' +
          '    body, input, textarea, keygen, select, button, table, div {' +
          '        font-size: 22px;' +
          '    }' +
          '}' +
          '' +
          '@media only screen and (min-width:3000px) {' +
          '    body, input, textarea, keygen, select, button, table, div {' +
          '        font-size: 24px;' +
          '    }' +
          '}' +
          '' +
          '/* Non-mobile styles */' +
          '' +
          '@media not screen and (min-width : 320px) and (max-width : 768px) {' +
          '    .np-showbehavior-app {' +
          '        display: none;' +
          '    }' +
          '}' +
          '' +
          '/* Mobile styles */' +
          '' +
          '@media only screen and (min-width : 320px) and (max-width : 768px) {' +
          '' +
          '    body {' +
          '        font-size: 12px !important;' +
          '    }' +
          '' +
          '    .np-popup {' +
          '        width: 100% !important;' +
          '        height: 100% !important;' +
          '        top: 0 !important;' +
          '        left: 0 !important;' +
          '    }' +
          '' +
          '    .np-popup .np-container.body, .np-popup.searchbox .np-container.body {' +
          '        padding: 15px 0;' +
          '    }' +
          '' +
          '    .np-popup .np-container.content, .np-popup.functionspopup .np-container.content {' +
          '        padding: 0 15px;' +
          '    }' +
          '' +
          '    .np-popup .np-buttongrid {' +
          '        height: 100%;' +
          '    }' +
          '' +
          '    .np-popup .np-container.actions .buttons {' +
          '        -webkit-justify-content: space-around;' +
          '        -ms-flex-pack: distribute;' +
          '        justify-content: space-around;' +
          '    }' +
          '}' +
          '' +
          '' +
          '/*================================================================ */' +
          '/*         Defining number of buttons to show in one line          */' +
          '/* =============================================================== */' +
          '' +
          '@media only screen and (min-width : 320px) and (max-width : 479px) {' +
          '    .np-buttongrid.one-row .np-buttongridrow .np-button {        ' +
          '        width: calc(50% - 0.3em);' +
          '    }' +
          '}' +
          '' +
          '@media only screen and (min-width : 480px) and (max-width : 567px) {' +
          '    .np-buttongrid.one-row .np-buttongridrow .np-button {' +
          '        width: calc(33.3333% - 0.3em);' +
          '    }   ' +
          '}' +
          '' +
          '@media only screen and (min-width : 568px) and (max-width : 736px) {' +
          '    .np-buttongrid.one-row .np-buttongridrow .np-button {' +
          '        width: calc(25% - 0.3em);' +
          '    }   ' +
          '}' +
          '' +
          '@media not all and (min-resolution:.001dpcm) { @media {' +
          '    .np-button.has-icon span.np-caption, .np-button span.np-icon { ' +
          '        padding: 7% 0 0;' +
          '    }' +
          '}}' +
          '' +
          '@media screen and (max-width: 767px) {' +
          '    _::-webkit-full-page-media, _:future, :root .np-button.has-icon span.np-caption {' +
          '        padding: 8px 0 0;' +
          '    }' +
          '' +
          '    _::-webkit-full-page-media, _:future, :root .np-button span.np-icon {' +
          '        padding: 10px 0 0;' +
          '    }' +
          '}' +
          '.dummy {} /* Always start the file with this */' +
          '' +
          '/* Fix for mobile devices, case 306520 */' +
          '@media only screen and (max-width: 768px) and (min-width: 320px) {' +
          '   .np-layout {' +
          '     flex: 10000 10000;' +
          '   }' +
          '}' +
          '' +
          '/* iPad 2 */' +
          '@media only screen ' +
          'and (min-device-width : 768px) ' +
          'and (max-device-width : 1024px)' +
          'and (-webkit-min-device-pixel-ratio: 2) {' +
          '    body, input, textarea, keygen, select, button, table, div {' +
          '        font-size: 13px;' +
          '    }' +
          '' +
          '    .np-popup .titlebar span {' +
          '        font-size: 18px;' +
          '    }' +
          '' +
          '    .np-fontsize-semilarge {' +
          '        font-size: 18px;' +
          '    }' +
          '' +
          '    .np-icon-size-16:before {' +
          '        font-size: 14px;' +
          '    }' +
          '' +
          '    .np-icon-size-24:before {' +
          '        font-size: 20px;' +
          '    }' +
          '' +
          '    .np-icon-size-32:before {' +
          '        font-size: 20px;' +
          '    }' +
          '' +
          '    .np-icon-size-48:before {' +
          '        font-size: 32px;' +
          '    }' +
          '' +
          '    .np-icon-size-64:before {' +
          '        font-size: 48px;' +
          '    }' +
          '' +
          '    .np-button.np-fontsize-normal {' +
          '        font-size: 12px;' +
          '    }' +
          '' +
          '    .np-popup .np-fontsize-normal {' +
          '        font-size: 16px;' +
          '    }' +
          '}' +
          '' +
          '' +
          '/* iPhone 4, iPhone 5*/' +
          '@media only screen and (width : 320px) {' +
          '    .np-popup .titlebar span {' +
          '        font-size: 18px;' +
          '    }' +
          '' +
          '    .np-fontsize-semilarge {' +
          '        font-size: 18px;' +
          '    }' +
          '' +
          '    .np-icon-size-16:before {' +
          '        font-size: 10px;' +
          '    }' +
          '' +
          '    .np-icon-size-24:before {' +
          '        font-size: 14px;' +
          '    }' +
          '' +
          '    .np-icon-size-32:before {' +
          '        font-size: 18px;' +
          '    }' +
          '' +
          '    .np-icon-size-48:before {' +
          '        font-size: 24px;' +
          '    }' +
          '' +
          '    .np-icon-size-64:before {' +
          '        font-size: 32px;' +
          '    }' +
          '' +
          '    .np-button.np-fontsize-normal {' +
          '        font-size: 11px;' +
          '    }' +
          '' +
          '    .np-popup .np-fontsize-normal {' +
          '        font-size: 14px;' +
          '    }' +
          '}' +
          '' +
          '/* iPhone 5 */' +
          '@media only screen and (width : 320px) and (height: 568px) {' +
          '    .np-button.np-fontsize-normal {' +
          '        font-size: 12px;' +
          '    }' +
          '    .np-icon-size-32:before {' +
          '        font-size: 21px;' +
          '    }' +
          '}' +
          '' +
          '' +
          '' +
          '.np-overlay {' +
          '    background: #999;' +
          '    height: 100vh;    ' +
          '    width: 100vw;' +
          '    position: fixed;' +
          '    z-index: 1;' +
          '    -ms-opacity: 0.4;' +
          '    opacity: 0.4;' +
          '    top: 0;' +
          '    left: 0;' +
          '}' +
          '' +
          '' +
          '#container {' +
          'width: 1000px;' +
          'margin: 0 auto;' +
          'position: relative;' +
          'z-index: 2;' +
          '}' +
          '' +
          '.content-holder {' +
          '    display: flex;' +
          '}' +
          '' +
          '#container .content {' +
          '    width: 50%;' +
          '}' +
          '' +
          '' +
          '.np-popup .np-label.titlebar {' +
          '    height: 40px;' +
          '    background-color: #309ce6;' +
          '    color: #f3f8fb;' +
          '    margin-bottom: 8px;' +
          '    font-weight: 400;' +
          '    border: 0;' +
          '    padding: 0;' +
          '    text-align: left;' +
          '}' +
          '' +
          '.np-popup .titlebar span {' +
          '    display: -webkit-box;' +
          '    display: -webkit-flex;' +
          '    display: -ms-flexbox;' +
          '    display: flex;' +
          '    -webkit-flex-flow: column nowrap;' +
          '    -ms-flex-flow: column nowrap;' +
          '    flex-flow: column nowrap;' +
          '    font-size: 20px;' +
          '    font-weight: 400;' +
          '    height: 40px;' +
          '    -webkit-box-pack: center;' +
          '    -webkit-justify-content: center;' +
          '    -ms-flex-pack: center;' +
          '    justify-content: center;' +
          '    padding-left: 8px;' +
          '}' +
          '' +
          '.np-popup.np-container {' +
          '    background-color: white;' +
          '    padding: 0;' +
          '    -webkit-box-shadow: 0 0 30px 0 rgba(0,0,0,0.47);' +
          '    -ms-box-shadow: 0 0 30px 0 rgba(0,0,0,0.47);' +
          '    box-shadow: 0 0 30px 0 rgba(0,0,0,0.47);' +
          '}' +
          '' +
          '' +
          '' +
          '.np-popup .np-container.body .np-container.content {' +
          '    -webkit-box-align: center;' +
          '    -webkit-align-items: center;' +
          '    -ms-flex-align: center;' +
          '    align-items: center;' +
          '    display: -webkit-box;' +
          '    display: -webkit-flex;' +
          '    display: -ms-flexbox;' +
          '    display: flex;' +
          '    height: 100%;' +
          '    -webkit-box-pack: center;' +
          '    -webkit-justify-content: center;' +
          '    -ms-flex-pack: center;' +
          '    justify-content: center;' +
          '    width: 100%;' +
          '}' +
          '' +
          '.np-popup .np-container.actions {' +
          '    width: 100%;' +
          '    background: #e9edef;' +
          '}' +
          '' +
          '.np-popup .np-container.actions .buttons {' +
          '    padding: 15px;' +
          '    height: 80px;' +
          '    width: 100%;' +
          '    display: -webkit-box;' +
          'display: -webkit-flex;' +
          'display: -ms-flexbox;' +
          'display: flex;' +
          '    -webkit-box-pack: end;' +
          '    -webkit-justify-content: flex-end;' +
          '    -ms-flex-pack: end;' +
          '    justify-content: flex-end;' +
          '}' +
          '' +
          '.np-popup .np-container.actions .np-button {' +
          '-webkit-box-flex: 0;' +
          '-webkit-flex: 0 0 115px;' +
          '-ms-flex: 0 0 115px;' +
          'flex: 0 0 115px;' +
          '}' +
          '' +
          '' +
          '.np-popup .actions .np-button.ok, .np-popup .actions .np-button.yes {' +
          '    background: #5eb267;' +
          '}' +
          '' +
          '.np-popup .actions .np-button.ok:hover, .np-popup .actions .np-button.yes:hover, .np-popup .actions .np-button.ok:focus, .np-popup .actions .np-button.yes:focus {' +
          '    background: #34803c;' +
          '}' +
          '' +
          '.heading {' +
          '    background: #e9edef;' +
          '    text-align: center;' +
          '    display: -webkit-box;' +
          '    display: -webkit-flex;' +
          '    display: -ms-flexbox;' +
          '    display: flex;' +
          '    margin: 20px 20px 0 20px;' +
          '    border: 2px solid #b5cfe7;' +
          '    border-bottom: none;' +
          '    padding-right: 17px;' +
          '}' +
          '' +
          '.heading div {' +
          '    flex: 1 1 20%;' +
          '    display: -webkit-box;' +
          '    display: -webkit-flex;' +
          '    display: -ms-flexbox;' +
          '    display: flex;  ' +
          '    justify-content: center;' +
          '    padding: 5px 10px;' +
          '    border-right: 2px solid #b5cfe7;' +
          '    align-items: center;' +
          '    font-size: 16px;' +
          '}' +
          '#Section1 > div {' +
          '    width: 100%;' +
          '    clear: both;' +
          '    height: 100px;' +
          '}' +
          '.heading div:first-child {' +
          '    flex: 1 1 45%;' +
          '    justify-content: flex-start;' +
          '}' +
          '.heading div:last-child {' +
          '    border-right: none;' +
          '    padding-right: 0;' +
          '}' +
          '' +
          '.items-list {' +
          'border: 2px solid #b5cfe7;' +
          'margin: 0 20px 20px;' +
          'padding: 0;' +
          'overflow-y: scroll;' +
          '    max-height: 295px;' +
          '    min-height: 35px;' +
          '}' +
          '' +
          '.items-list li {' +
          'display: -webkit-box;' +
          '    display: -webkit-flex;' +
          '    display: -ms-flexbox;' +
          '    display: flex;  ' +
          'justify-content: space-between;' +
          '    border-bottom: 2px solid #b5cfe7;' +
          '    background: none;' +
          '}' +
          '' +
          '.items-list li:last-child {' +
          'border: none;' +
          '}' +
          '' +
          '.items-list li div {' +
          'flex: 1 1 20%;' +
          'display: -webkit-box;' +
          '    display: -webkit-flex;' +
          '    display: -ms-flexbox;' +
          '    display: flex;  ' +
          'justify-content: space-between;' +
          'padding: 0;' +
          '    border-right: 2px solid #b5cfe7;' +
          '    align-items: center;' +
          '    font-size: 16px;' +
          '    text-align: center;' +
          '}' +
          '' +
          '.items-list li div a {' +
          'text-decoration: none;' +
          'color: #fff;' +
          'display: block;' +
          'background: #a4b4c8;' +
          'width: 33%;' +
          'text-align: center;' +
          'padding: 10px 0;' +
          'font-size: 28px;' +
          'font-weight: normal;' +
          'line-height: 28px;' +
          '}' +
          '' +
          '.items-list li div span {' +
          'display: block;' +
          'padding: 5px 10px;' +
          '    width: 100%;' +
          '}' +
          '' +
          '.items-list li label {' +
          '    display: -webkit-box;' +
          '    display: -webkit-flex;' +
          '    display: -ms-flexbox;' +
          '    display: flex;  ' +
          '    width: 100%;' +
          '    height: 100%;' +
          '    padding: 5px 10px;' +
          '    justify-content: center;' +
          '    align-items: center;' +
          '}' +
          '' +
          '.items-list li div:first-child {' +
          'flex: 1 1 45%;' +
          '    text-align: left;' +
          '}' +
          '' +
          '' +
          '.items-list li div:last-child {' +
          '    border-right: none;' +
          '}' +
          '' +
          '.np-popup .text-area {' +
          '  width:100%;' +
          '  height:600px;' +
          '  border:none;' +
          '  resize: none' +
          '}';

        exit(Css);
    end;

    local procedure InitHtml() Html: Text
    begin
        Html :=
          '<!doctype html>' +
          '<html lang="en">' +
            '<head>' +
              '<meta charset="utf-8">' +
              '<title>Edit Web Client Dependency</title>' +
              '<meta name="description" content="UI test">' +
              '<meta name="author" content="mha">' +
            '</head>' +
            '' +
            '<body ng-app="navApp" ng-controller="navCtrl">' +
              '<div class="np-overlay"></div>' +
              '<div class="np-popup np-container" id="container">' +
                '<div class="np-label np-fontsize-normal titlebar">' +
                  '<span class="np-caption">Edit Web Client Dependency</span>' +
                '</div>' +
                '' +
                '<textarea class="flow-horizontal np-fontsize-normal content-holder text-area web">' +
                  '{{navContent}}' +
                '</textarea>' +
                '' +
                '<div class="np-container flow-horizontal np-fontsize-normal actions">' +
                  '<div class="np-container flow-horizontal np-fontsize-normal buttons">' +
                    '<div class="np-button np-fontsize-normal ok np-button-color-default save">' +
                      '<span class="np-caption">' +
                        '<span class="inner-content">' + Text001 + '</span>' +
                      '</span>' +
                    '</div>' +
                    '<div class="np-button np-fontsize-normal cancel np-button-color-default cancel">' +
                      '<span class="np-caption">' +
                        '<span class="inner-content">' + Text002 + '</span>' +
                      '</span>' +
                    '</div>' +
                  '</div>' +
                '</div>' +
              '</div>' +
              '' +
              '<script>' +
                '' +
                  '$(function () {' +
                    '$(''.save'').click(function () {' +
                      'var webContent = $(''.web'').val();' +
                      'n$.respondExplicit("save",webContent);' +
                    '});' +
                    '' +
                    '$(''.cancel'').click(function () {' +
                      'n$.respondExplicit("cancel", {});' +
                    '});' +
                  '});' +
              '</script>   ' +
            '</body>' +
          '</html>';
        exit(Html);
    end;

    local procedure InitScript() Script: Text
    var
        RetailModelScriptLibrary: Codeunit "Retail Model Script Library";
        NavContent: DotNet String;
        StreamReader: DotNet StreamReader;
        InStr: InStream;
    begin
        Script := RetailModelScriptLibrary.InitAngular();
        Script += RetailModelScriptLibrary.InitEscClose();

        NavContent := '';
        if CurrWebClientDependency.BLOB.HasValue then begin
          CurrWebClientDependency.CalcFields(BLOB);
          CurrWebClientDependency.BLOB.CreateInStream(InStr);
          StreamReader := StreamReader.StreamReader(InStr);
          NavContent := StreamReader.ReadToEnd();
        end;

        NavContent := NavContent.Replace('"','\"');
        NavContent := NavContent.Replace('/','\/');
        NavContent := NavContent.Replace(CR,'');
        NavContent := NavContent.Replace(LF,'\n');

        Script +=
          'var app = angular.module("navApp", []);' +
          'app.controller("navCtrl", function($scope) {' +
              '$scope.navContent = "' + NavContent.ToString() + '";' +
          '});';
        exit(Script);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', true, true)]
    local procedure OnProtocolUIResponse(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";ModelID: Guid;Sender: Text;EventName: Text;var Handled: Boolean)
    begin
        if ModelID <> ActiveModelID then
          exit;

        Handled := true;

        case Sender of
          'save':
            begin
              SaveNavContent(EventName,FrontEnd);
              FrontEnd.CloseModel(ModelID);
            end;
          'cancel','close':
            begin
              FrontEnd.CloseModel(ModelID);
            end;
        end;
    end;

    local procedure SaveNavContent(NavContentJson: Text;FrontEnd: Codeunit "POS Front End Management")
    var
        NavContent: DotNet String;
        OutStr: OutStream;
    begin
        NavContent := NavContentJson;
        NavContent := NavContent.Replace('\"','"');
        NavContent := NavContent.Replace('\/','/');
        NavContent := NavContent.Replace('\n',NewLine());
        NavContent := NavContent.Replace('\t',Tab());

        Clear(CurrWebClientDependency.BLOB);
        CurrWebClientDependency.BLOB.CreateOutStream(OutStr);
        OutStr.WriteText(NavContent.ToString());
        CurrWebClientDependency.Modify(true);
    end;

    local procedure "--- Chr"()
    begin
    end;

    local procedure Tab() TabChr: Text[1]
    begin
        TabChr[1] := 9;
        exit(TabChr);
    end;

    local procedure CR() CRChr: Text[1]
    begin
        CRChr[1] := 13;
        exit(CRChr);
    end;

    local procedure LF() LFChr: Text[1]
    begin
        LFChr[1] := 10;
        exit(LFChr);
    end;

    local procedure NewLine(): Text[2]
    begin
        exit(CR() + LF());
    end;

    trigger Model::OnModelControlEvent(control: DotNet Control;eventName: Text;data: DotNet Dictionary_Of_T_U)
    begin
    end;

    trigger Model::OnTimer()
    begin
    end;
}

