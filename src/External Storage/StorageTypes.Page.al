page 6184892 "NPR Storage Types"
{
    // NPR5.54/ALST/20200311 CASE 394895 Object created

    Caption = 'Storage Types';
    Editable = false;
    PageType = List;
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
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Codeunit"; Codeunit)
                {
                    ApplicationArea = All;
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

