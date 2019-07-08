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
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field(Hotkey;Hotkey)
                {
                }
                field("Hotkey Action";"Hotkey Action")
                {

                    trigger OnValidate()
                    begin
                        ApplicationPathEnabled := "Hotkey Action" = "Hotkey Action"::Application;
                        ObjectFieldsEnabled    := "Hotkey Action" = "Hotkey Action"::Object;
                    end;
                }
                field("Object Type";"Object Type")
                {
                    Enabled = ObjectFieldsEnabled;
                }
                field("Object ID";"Object ID")
                {
                    Enabled = ObjectFieldsEnabled;
                }
                field("Application Path";"Application Path")
                {
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
        ObjectFieldsEnabled    := "Hotkey Action" = "Hotkey Action"::Object;
    end;

    var
        ApplicationPathEnabled: Boolean;
        ObjectFieldsEnabled: Boolean;
}

