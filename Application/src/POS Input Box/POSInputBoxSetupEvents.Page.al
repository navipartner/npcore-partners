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
                field("Event Code"; Rec."Event Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Code field';
                }
                field("Module Name"; Rec."Module Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Module Name field';
                }
                field("Event Description"; Rec."Event Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Description field';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Priority field';
                }
                field("Action Code"; Rec."Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Action Code field';
                }
                field("Action Description"; Rec."Action Description")
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
                    EanBoxParameter: Record "NPR Ean Box Parameter";
                    EanBoxSetupMgt: Codeunit "NPR POS Input Box Setup Mgt.";
                begin
                    EanBoxSetupMgt.InitEanBoxSetupEventParameters(Rec);
                    EanBoxParameter.SetRange("Setup Code", Rec."Setup Code");
                    EanBoxParameter.SetRange("Event Code", Rec."Event Code");
                    PAGE.Run(0, EanBoxParameter);
                end;
            }
        }
    }
}

