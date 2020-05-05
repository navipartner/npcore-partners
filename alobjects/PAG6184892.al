page 6184892 "Storage Types"
{
    // NPR5.54/ALST/20200311 CASE 394895 Object created

    Caption = 'Storage Types';
    Editable = false;
    PageType = List;
    SourceTable = "Storage Type";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Storage Type";"Storage Type")
                {
                }
                field(Description;Description)
                {
                }
                field("Codeunit";Codeunit)
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        ExternalStorageInterface: Codeunit "External Storage Interface";
    begin
        ExternalStorageInterface.OnDiscoverStorage(Rec);
    end;
}

