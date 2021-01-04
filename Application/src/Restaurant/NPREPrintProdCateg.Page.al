page 6150680 "NPR NPRE Print/Prod. Categ."
{
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Print/Prod. Categories';
    DataCaptionExpression = '';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NPRE Print/Prod. Cat.";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Print Tag"; "Print Tag")
                {
                    ApplicationArea = All;
                    Visible = ShowPrintTags;
                    ToolTip = 'Specifies the value of the Print Tag field';
                }
            }
        }
    }

    actions
    {
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

