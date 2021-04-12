page 6060097 "NPR POS Input Box Events"
{

    Caption = 'POS Input Box Events';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Ean Box Event";
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
                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Module Name"; Rec."Module Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Module Name field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
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
                field("POS View"; Rec."POS View")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the POS View field';
                }
                field("Event Codeunit"; Rec."Event Codeunit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Codeunit field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
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
                    EanBoxSetupMgt.InitEanBoxEventParameters(Rec);

                    EanBoxParameter.SetRange("Setup Code", '');
                    EanBoxParameter.SetRange("Event Code", Rec.Code);
                    PAGE.Run(0, EanBoxParameter);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        POSAction: Record "NPR POS Action";
        EanBoxSetupMgt: Codeunit "NPR POS Input Box Setup Mgt.";
    begin
        POSAction.DiscoverActions();
        EanBoxSetupMgt.DiscoverEanBoxEvents(Rec);
        EanBoxSetupMgt.InitDefaultEanBoxSetup();
    end;
}

