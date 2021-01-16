page 6060098 "NPR Ean Box Setup Events"
{
    // NPR5.32/NPKNAV/20170526  CASE 272577 Transport NPR5.32 - 26 May 2017
    // NPR5.40/VB  /20180307 CASE 306347 Force-invoking physical action discovery.
    // NPR5.45/MHA /20180814  CASE 319706 Reworked Identifier Dissociation to Ean Box Event Handler
    // NPR5.47/MHA /20181024  CASE 333512 Added field 10 Priority

    Caption = 'Ean Box Setup Events';
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
                    EanBoxSetupMgt: Codeunit "NPR Ean Box Setup Mgt.";
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

