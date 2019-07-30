page 6014697 "Embedded Videos"
{
    // NPR5.37/MHA /20171009  CASE 289471 Object created - Display Embedded Videos

    Caption = 'Retail Demo Video';
    DataCaptionExpression = ModuleName;
    Editable = false;

    layout
    {
        area(content)
        {
            usercontrol(Bridge;Bridge)
            {

                trigger OnFrameworkReady()
                begin
                    BridgeReady := true;
                    JavaScriptBridgeMgt.Initialize(CurrPage.Bridge);
                    EmbedHtml();
                end;
            }
        }
    }

    actions
    {
    }

    var
        JavaScriptBridgeMgt: Codeunit "JavaScript Bridge Management";
        ModuleCode: Text;
        BridgeReady: Boolean;
        ModuleName: Text;
        Columns: Integer;

    local procedure EmbedHtml()
    var
        EmbeddedVideoBuffer: Record "Embedded Video Buffer" temporary;
        EmbeddedVideoMgt: Codeunit "Embedded Video Mgt.";
        Height: Integer;
        Width: Integer;
        Videohtml: Text;
        i: Integer;
    begin
        if not BridgeReady then
          exit;

        if not EmbeddedVideoMgt.FindEmbeddedVideos(ModuleCode,EmbeddedVideoBuffer) then begin
          JavaScriptBridgeMgt.EmbedHtml('');
          exit;
        end;

        ModuleName := EmbeddedVideoBuffer."Module Name";
        Columns := EmbeddedVideoBuffer.Columns;
        if Columns <= 0 then
          Columns := 1;

        Videohtml := '<div style="width: 100%;height: 100%;overflow: scroll;"><table><tr>';
        repeat
          i += 1;
          if (i mod Columns = 1) and (i > 1) then
            Videohtml += '</tr><tr>';

          Videohtml += '<td>' + EmbeddedVideoBuffer."Video Html" + '</td>';
        until EmbeddedVideoBuffer.Next = 0;
        Videohtml += '</tr></table></div>';

        JavaScriptBridgeMgt.EmbedHtml(Videohtml);
        JavaScriptBridgeMgt.SetSize('100%','100%');
    end;

    procedure SetModuleCode(NewModuleCode: Text)
    begin
        ModuleCode := NewModuleCode;
    end;
}

