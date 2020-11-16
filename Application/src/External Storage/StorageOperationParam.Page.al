page 6184894 "NPR Storage Operation Param."
{
    // NPR5.54/ALST/20200311 CASE 394895 Object created

    Caption = 'Storage Operation Parameters';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    UsageCategory = Administration;
    SourceTable = "NPR Storage Operation Param.";
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
                    Visible = false;
                }
                field("Operation Code"; "Operation Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Parameter Name"; "Parameter Name")
                {
                    ApplicationArea = All;
                }
                field("Parameter Value"; "Parameter Value")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Parameter Key"; "Parameter Key")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Mandatory For Job Queue"; "Mandatory For Job Queue")
                {
                    ApplicationArea = All;
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
        ExternalStorageInterface: Codeunit "NPR External Storage Interface";
    begin
        ExternalStorageInterface.OnDiscoverStorageOperationParameters(Rec);
    end;
}

