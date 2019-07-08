table 6060011 "GIM - Process Flow"
{
    Caption = 'GIM - Process Flow';
    LookupPageID = "GIM - Process Flow";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(5;"Doc. Type Field ID";Integer)
        {
            Caption = 'Doc. Type Field ID';

            trigger OnLookup()
            var
                GIMBufferFields: Page "GIM - Fields List";
            begin
                TableField.SetRange(TableNo,DATABASE::"GIM - Document Type");
                GIMBufferFields.SetTableView(TableField);
                GIMBufferFields.LookupMode(true);
                GIMBufferFields.Editable(false);
                if GIMBufferFields.RunModal = ACTION::LookupOK then begin
                  GIMBufferFields.GetRecord(TableField);
                  Validate("Doc. Type Field ID",TableField."No.");
                end;
            end;

            trigger OnValidate()
            begin
                TableField.Get(DATABASE::"GIM - Document Type","Doc. Type Field ID");
            end;
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(20;Stage;Integer)
        {
            Caption = 'Stage';
        }
        field(30;Pause;Option)
        {
            Caption = 'Pause';
            OptionCaption = 'When Error,Allways';
            OptionMembers = "When Error",Allways;
        }
        field(50;"Notify When";Option)
        {
            Caption = 'Notify When';
            OptionCaption = 'When Error,Allways';
            OptionMembers = "When Error",Allways;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
        key(Key2;Stage)
        {
        }
    }

    fieldgroups
    {
    }

    var
        TableField: Record "Field";
}

