page 6150721 "POS Keyboard Binding Setup"
{
    // NPR5.48/TJ  /20181204 CASE 323835 New object

    Caption = 'POS Keyboard Binding Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "POS Keyboard Binding Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Action Code";"Action Code")
                {
                    Editable = false;
                }
                field("Key Bind";"Key Bind")
                {
                }
                field(Description;Description)
                {
                    Editable = false;
                }
                field(Enabled;Enabled)
                {
                }
                field("Default Key Bind";"Default Key Bind")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RestoreDefaultKeyBind)
            {
                Caption = 'Restore Default Key Bind';
                Ellipsis = true;
                Image = Restore;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    POSKeyboardBindingMgt.RestoreDefaultKeyBind(Rec);
                end;
            }
        }
    }

    var
        POSKeyboardBindingMgt: Codeunit "POS Keyboard Binding Mgt.";
}

