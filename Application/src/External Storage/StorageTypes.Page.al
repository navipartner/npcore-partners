page 6184892 "NPR Storage Types"
{
    Caption = 'Storage Types';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Storage Type";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Storage Type"; "Storage Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Storage Type field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Codeunit"; Codeunit)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Codeunit ID field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        ExternalStorageInterface: Codeunit "NPR External Storage Interface";
    begin
        ExternalStorageInterface.OnDiscoverStorage(Rec);
    end;
}

