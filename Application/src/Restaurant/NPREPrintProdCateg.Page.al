page 6150680 "NPR NPRE Print/Prod. Categ."
{
    Caption = 'Print/Prod. Categories';
    DataCaptionExpression = '';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NPRE Print/Prod. Cat.";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Print Tag"; Rec."Print Tag")
                {
                    ApplicationArea = All;
                    Visible = ShowPrintTags;
                    ToolTip = 'Specifies the value of the Print Tag field';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        ServingStepDiscoveryMethod: Integer;
    begin
        ServingStepDiscoveryMethod := SetupProxy.ServingStepDiscoveryMethod();
        ShowPrintTags := ServingStepDiscoveryMethod = 0;
    end;

    var
        ShowPrintTags: Boolean;
}