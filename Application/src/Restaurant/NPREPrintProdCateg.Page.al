page 6150680 "NPR NPRE Print/Prod. Categ."
{
    Extensible = False;
    Caption = 'Print/Prod. Categories';
    DataCaptionExpression = '';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NPRE Print/Prod. Cat.";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Tag"; Rec."Print Tag")
                {

                    Visible = ShowPrintTags;
                    ToolTip = 'Specifies the value of the Print Tag field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        ServingStepDiscoveryMethod: Enum "NPR NPRE Serv.Step Discovery";
    begin
        ServingStepDiscoveryMethod := SetupProxy.ServingStepDiscoveryMethod();
        ShowPrintTags := ServingStepDiscoveryMethod = ServingStepDiscoveryMethod::"Legacy (using print tags)";
    end;

    var
        ShowPrintTags: Boolean;
}
