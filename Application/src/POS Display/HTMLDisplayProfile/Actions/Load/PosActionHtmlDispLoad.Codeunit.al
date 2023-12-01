codeunit 6184539 "NPR POS Action: HD Load" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        HtmlReq: Codeunit "NPR POS HTML Disp. Req";
        ActionDescription: Label 'Html Display: Load profile or website onto the customer display.';
        Load_Name: Label 'LoadAction', Locked = true;
        Load_Options: Label 'Profile,Website', Locked = true;
        Load_Caption: Label 'Load option';
        Load_Description: Label 'Specifies what you want to load on the customer display.';
        Load_OptionsCaption: Label 'Profile, Website';
        ShouldDownload_Name: Label 'DownloadMedia', Locked = true;
        ShouldDownload_Caption: Label 'Download Media';
        ShouldDownload_Desc: Label 'Specify if the media should be downloaded again when the display loads the Profile.';
        Url_Name: Label 'WebsiteUrl', Locked = true;
        Url_Caption: Label 'Website Url';
        Url_Desc: Label 'Specify the url to be loaded on the display.';
        VK_plugin_Name: Label 'UseVirtualKeyboardPlugin', Locked = true;
        VK_plugin_Caption: Label 'Plugin: Virtual Keyboard';
        VK_plugin_Desc: Label 'Specify if the Virtual Keyboard Plugin should be used with the website.';

    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter(Load_Name, Load_Options, 'Profile', Load_Caption, Load_Description, Load_OptionsCaption);
        WorkflowConfig.AddBooleanParameter(ShouldDownload_Name, False, ShouldDownload_Caption, ShouldDownload_Desc);
        WorkflowConfig.AddTextParameter(Url_Name, '', Url_Caption, Url_Desc);
        WorkflowConfig.AddBooleanParameter(VK_plugin_Name, false, VK_plugin_Caption, VK_plugin_Desc);
        WorkflowConfig.AddLabel('HtmlDisplayVersion', Format(HtmlReq.HtmlDisplayVersion()));

    end;


    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        Request: JsonObject;
        Json: JsonObject;
        HtmlRequest: Codeunit "NPR POS Html Disp. Req";
    begin
        case Step of
            'LocalMediaInfo':
                begin
                    Request := HtmlRequest.LocalMediaObject();
                    FrontEnd.WorkflowResponse(Request);
                end;
            'ShouldUpdateReceipt':
                begin
                    if ((Context.HasProperty('IsSuccessfull')) and (Context.GetBoolean('IsSuccessfull'))) then begin
                        if (Context.GetString('LoadAction') = 'Profile') then begin
                            HtmlRequest.UpdateReceiptRequest(Request);
                            Json.Add('Request', Request);
                            Frontend.WorkflowResponse(Json);
                        end;
                        if (Context.GetString('LoadAction') = 'Website') then begin
                            Json.Add('Request', False);
                            FrontEnd.WorkflowResponse(Json);
                        end;
                    end;
                end;
        end;
    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:PosActionHtmlDispLoad.js### 
'let main=async({context:i,popup:r,captions:d,parameters:l})=>{i.HtmlDisplayVersion=Number.parseInt(d.HtmlDisplayVersion),i.IsNestedWorkflow||(i.LoadAction=String(l.LoadAction),i.DownloadMedia=l.DownloadMedia,i.WebsiteUrl=l.WebsiteUrl,i.UseVirtualKeyboardPlugin=l.UseVirtualKeyboardPlugin,i.IsNestedWorkflow=!1);let e={Version:i.HtmlDisplayVersion},a=null;try{i.LoadAction==="Profile"?(e.DisplayAction="LoadWebsite",e.Website="",l.DownloadMedia&&(e.LocalMediaInfo=await workflow.respond("LocalMediaInfo",a))):i.LoadAction==="Website"&&(e.DisplayAction="LoadWebsite",e.Website=i.WebsiteUrl,e.Plugins=[i.UseVirtualKeyboardPlugin?"VirtualKeyboard":""],e.Plugins.filter(s=>{})),a=await hwc.invoke("HTMLDisplay",e);let o=await workflow.respond("ShouldUpdateReceipt",a);o.Request&&await hwc.invoke("HTMLDisplay",o.Request)}catch(o){r.error(o)}return a};'
        );
    end;
}
