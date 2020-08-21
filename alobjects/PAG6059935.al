page 6059935 Hotkeys
{
    Caption = 'Hotkeys';
    PageType = List;
    SourceTable = Hotkey;

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
                field(Hotkey; Hotkey)
                {
                    ApplicationArea = All;
                }
                field("Hotkey Action"; "Hotkey Action")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        ApplicationPathEnabled := "Hotkey Action" = "Hotkey Action"::Application;
                        ObjectFieldsEnabled := "Hotkey Action" = "Hotkey Action"::Object;
                    end;
                }
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                    Enabled = ObjectFieldsEnabled;
                }
                field("Object ID"; "Object ID")
                {
                    ApplicationArea = All;
                    Enabled = ObjectFieldsEnabled;
                }
                field("Application Path"; "Application Path")
                {
                    ApplicationArea = All;
                    Enabled = ApplicationPathEnabled;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        ApplicationPathEnabled := "Hotkey Action" = "Hotkey Action"::Application;
        ObjectFieldsEnabled := "Hotkey Action" = "Hotkey Action"::Object;
    end;

    var
        ApplicationPathEnabled: Boolean;
        ObjectFieldsEnabled: Boolean;
}

