page 6150721 "NPR POS Keyboard Bind. Setup"
{
    // NPR5.48/TJ  /20181204 CASE 323835 New object

    Caption = 'POS Keyboard Binding Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR POS Keyboard Bind. Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Action Code"; "Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Key Bind"; "Key Bind")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                }
                field("Default Key Bind"; "Default Key Bind")
                {
                    ApplicationArea = All;
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
                ApplicationArea=All;

                trigger OnAction()
                begin
                    POSKeyboardBindingMgt.RestoreDefaultKeyBind(Rec);
                end;
            }
        }
    }

    var
        POSKeyboardBindingMgt: Codeunit "NPR POS Keyboard Binding Mgt.";
}

