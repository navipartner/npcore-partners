page 6060097 "NPR POS Input Box Events"
{
    Extensible = False;

    Caption = 'POS Input Box Events';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Ean Box Event";
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

                    Editable = false;
                    ToolTip = 'Specifies the event''s ID.';
                    ApplicationArea = NPRRetail;
                }
                field("Module Name"; Rec."Module Name")
                {

                    ToolTip = 'Specifies the name of the module to which the event is tied.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the description of the event.';
                    ApplicationArea = NPRRetail;
                }
                field("Action Code"; Rec."Action Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the POS action code associated with the event.';
                    ApplicationArea = NPRRetail;
                }
                field("Action Description"; Rec."Action Description")
                {

                    ToolTip = 'Specifies the description of the POS action.';
                    ApplicationArea = NPRRetail;
                }
                field("POS View"; Rec."POS View")
                {

                    Editable = false;
                    ToolTip = 'Specifies the type of view that the event is used on.';
                    ApplicationArea = NPRRetail;
                }
                field("Event Codeunit"; Rec."Event Codeunit")
                {

                    ToolTip = 'Specifies the number of the codeunit that contains this function.';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Parameters action';
                ApplicationArea = NPRRetail;

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

