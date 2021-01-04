page 6184894 "NPR Storage Operation Param."
{
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
                    ToolTip = 'Specifies the value of the Storage Type field';
                }
                field("Operation Code"; "Operation Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Operation Code field';
                }
                field("Parameter Name"; "Parameter Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Parameter Value"; "Parameter Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Parametr Value field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Parameter Key"; "Parameter Key")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Key field';
                }
                field("Mandatory For Job Queue"; "Mandatory For Job Queue")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Mandatory For Job Queue field';
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

