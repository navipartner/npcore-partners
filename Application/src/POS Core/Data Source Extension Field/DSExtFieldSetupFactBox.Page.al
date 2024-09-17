page 6151285 "NPR DS Ext.Field Setup FactBox"
{
    Extensible = false;
    Caption = 'Extension Field Additional Parameters';
    PageType = CardPart;
    SourceTable = "NPR POS DS Exten. Field Setup";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            usercontrol(DSExtFldAddParamsUC; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
#ELSE
            usercontrol(DSExtFldAddParamsUC; WebPageViewer)
#ENDIF
            {
                ApplicationArea = NPRRetail;

                trigger ControlAddInReady(callbackUrl: Text)
                begin
                    IsReady := true;
                    FillAddIn();
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        DSExtFldAddParams := '';
        if IsReady then
            FillAddIn();
    end;

    trigger OnAfterGetRecord()
    begin
        DSExtFldAddParams := Rec.GetAdditionalParameterSet();
        if IsReady then
            FillAddIn();
    end;

    local procedure FillAddIn()
    begin
        CurrPage.DSExtFldAddParamsUC.SetContent(StrSubstNo('<textarea readonly Id="NPRPOSDSExtFldAdditParamsTextArea" style="width:100%;height:100%;resize: none;">%1</textarea>', DSExtFldAddParams));
    end;

    var
        DSExtFldAddParams: Text;
        IsReady: Boolean;
}