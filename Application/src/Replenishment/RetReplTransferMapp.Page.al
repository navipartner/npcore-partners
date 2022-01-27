page 6014635 "NPR Ret. Repl. Transfer Mapp."
{
    Extensible = False;
    ApplicationArea = All;
    Caption = 'Replenishment Transfer Mapping';
    PageType = List;
    SourceTable = "NPR Ret. Repl. Transfer Mapp.";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("From Location"; Rec."To Location")
                {
                    ToolTip = 'Specifies the value of the Location for which Iten was needed. This will be used/treated like "To Location" field when creating Transfer order.';
                    ApplicationArea = All;
                }
                field("To Location"; Rec."From Location")
                {
                    ToolTip = 'Specifies the value of the From Location field. This is the location From which Items will be transfered.';
                    ApplicationArea = All;
                }
                field(Priority; Rec.Priority)
                {
                    ToolTip = 'Specifies the value of the Priority field. By this field it will be defined which location will be taken first to provide needed quantity.';
                    ApplicationArea = All;
                }
            }
        }
    }

}
