page 6060098 "NPR POS Input Box Setup Events"
{

    Caption = 'POS Input Box Setup Events';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Ean Box Setup Event";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Event Code"; "Event Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Code field';
                }
                field("Module Name"; "Module Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Module Name field';
                }
                field("Event Description"; "Event Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Description field';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field(Priority; Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Priority field';
                }
                field("Action Code"; "Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Action Code field';
                }
                field("Action Description"; "Action Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action Description field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Parameters)
            {
                Caption = 'Parameters';
                Image = List;
                ApplicationArea = All;
                ToolTip = 'Executes the Parameters action';

                trigger OnAction()
                var
                    EanBoxEvent: Record "NPR Ean Box Event";
                    EanBoxParameter: Record "NPR Ean Box Parameter";
                    EanBoxSetupMgt: Codeunit "NPR POS Input Box Setup Mgt.";
                begin
                    EanBoxSetupMgt.InitEanBoxSetupEventParameters(Rec);
                    EanBoxParameter.SetRange("Setup Code", "Setup Code");
                    EanBoxParameter.SetRange("Event Code", "Event Code");
                    PAGE.Run(0, EanBoxParameter);
                end;
            }
        }
    }
}

