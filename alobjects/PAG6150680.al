page 6150680 "NPRE Print/Prod. Categories"
{
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Print/Prod. Categories';
    DataCaptionExpression = '';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPRE Print/Prod. Category";
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
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Print Tag"; "Print Tag")
                {
                    ApplicationArea = All;
                    Visible = ShowPrintTags;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        SetupProxy: Codeunit "NPRE Restaurant Setup Proxy";
        ServingStepDiscoveryMethod: Integer;
    begin
        ServingStepDiscoveryMethod := SetupProxy.ServingStepDiscoveryMethod();
        ShowPrintTags := ServingStepDiscoveryMethod = 0;
    end;

    var
        ShowPrintTags: Boolean;
}

