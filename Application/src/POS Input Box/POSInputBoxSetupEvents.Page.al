page 6060098 "NPR POS Input Box Setup Events"
{
    Extensible = False;

    Caption = 'POS Input Box Setup Events';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Ean Box Setup Event";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Event Code"; Rec."Event Code")
                {

                    ToolTip = 'Specifies the value of the Event Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Module Name"; Rec."Module Name")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Module Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Event Description"; Rec."Event Description")
                {

                    ToolTip = 'Specifies the value of the Event Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field(Priority; Rec.Priority)
                {

                    ToolTip = 'Specifies the value of the Priority field';
                    ApplicationArea = NPRRetail;
                }
                field("Action Code"; Rec."Action Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Action Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Action Description"; Rec."Action Description")
                {

                    ToolTip = 'Specifies the value of the Action Description field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Parameters action';
                ApplicationArea = NPRRetail;

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

