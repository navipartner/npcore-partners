table 6059935 Hotkey
{
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -field 18

    Caption = 'Hotkey';

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(10;Hotkey;Text[30])
        {
            Caption = 'Hotkey';

            trigger OnValidate()
            var
                Itt: Integer;
                "Key": Text[10];
                KeyActivate: Text[1];
                ControlPressed: Boolean;
                AltPressed: Boolean;
                ShiftPressed: Boolean;
            begin
                Hotkey := HotkeyManagement.FormatHotkey(Hotkey);
            end;
        }
        field(15;"Hotkey Action";Option)
        {
            Caption = 'Action';
            OptionCaption = 'Application,Object';
            OptionMembers = Application,"Object";
        }
        field(17;"Object Type";Option)
        {
            Caption = 'Object Type';
            OptionCaption = 'Report,Codeunit,Page';
            OptionMembers = "Report","Codeunit","Page";
        }
        field(18;"Object ID";Integer)
        {
            Caption = 'Object ID';
            TableRelation = IF ("Object Type"=CONST(Codeunit)) AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit))
                            ELSE IF ("Object Type"=CONST(Report)) AllObj."Object ID" WHERE ("Object Type"=CONST(Report))
                            ELSE IF ("Object Type"=CONST(Page)) AllObj."Object ID" WHERE ("Object Type"=CONST(Page));
        }
        field(19;"Application Path";Text[250])
        {
            Caption = 'Application Path';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        HotkeyManagement: Codeunit "Hotkey Management";
}

