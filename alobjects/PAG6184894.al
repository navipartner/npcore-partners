page 6184894 "Storage Operation Parameters"
{
    // NPR5.54/ALST/20200311 CASE 394895 Object created

    Caption = 'Storage Operation Parameters';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    SourceTable = "Storage Operation Parameter";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Storage Type";"Storage Type")
                {
                    Visible = false;
                }
                field("Operation Code";"Operation Code")
                {
                    Visible = false;
                }
                field("Parameter Name";"Parameter Name")
                {
                }
                field("Parameter Value";"Parameter Value")
                {
                }
                field(Description;Description)
                {
                }
                field("Parameter Key";"Parameter Key")
                {
                    Visible = false;
                }
                field("Mandatory For Job Queue";"Mandatory For Job Queue")
                {
                    Editable = false;
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
        ExternalStorageInterface.OnDiscoverStorageOperationParameters(Rec);
    end;
}

